# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.

import argparse
import datetime
import json
import logging
import multiprocessing
import numbers
import os
import re
import typing
import dotenv
import neo4j
import neo4j.exceptions

from client import AbstractBenchmarkClient, ClientQuerySpecification

LOGGER = logging.getLogger(__name__)
FORMATTER = logging.Formatter("%(asctime)s - %(levelname)s - %(message)s")
STREAM_HANDLER = logging.StreamHandler()
STREAM_HANDLER.setFormatter(FORMATTER)
LOGGER.addHandler(STREAM_HANDLER)

class Neo4jBenchmarkClient(AbstractBenchmarkClient):
    def __init__(self):
        parser = argparse.ArgumentParser(description='Benchmark LDBC SNB queries on a Neo4j instance.')
        parser.add_argument('--queryDir', type=str, required=True, help='Location of the queries to execute.')
        parser.add_argument('--parametersDir', type=str, required=True, help='Location of the parameters to use.')
        parser.add_argument('--resultsDir', type=str, default='results', help='Location to hold the results.')
        parser.add_argument('--logDir', type=str, default='logs', help='Location to hold the log files.')
        parser.add_argument('--restartCmd', type=str, required=True, help='Command to execute when a timeout occurs.')
        parser.add_argument('--uri', type=str, default='bolt://localhost:7687',
                            help='URI pointing to the Neo4J bolt endpoint.')
        parser.add_argument('--seed', type=int, default=0, help='Seed to use for random number generator.')
        parser.add_argument('--config', type=str, default='config/neo4j.json',
                            help='Path to the (benchmark) configuration file.')
        parser.add_argument('--notes', type=str, default='', help='Any notes to append to each log entry.')
        parser.add_argument('--notify', default=False, action='store_true', help='Toggle to notify on finish.')
        parser.add_argument('--debug', default=False, action='store_true', help='Toggle to enable debug mode.')
        parser_args = parser.parse_args()
        dotenv.load_dotenv()

        # Create our "results" file and our "log" file.
        date_string = datetime.datetime.now().strftime('%Y%m%dT%H%M%S')
        result_file = parser_args.resultsDir + f'/neo4j_{date_string}.json'
        log_file = parser_args.logDir + f'/neo4j_{date_string}.log'

        # Load our client configuration.
        client_config = {
            'isDebug': parser_args.debug,
            'isNotify': parser_args.notify,
            'queryDir': parser_args.queryDir,
            'parametersDir': parser_args.parametersDir,
            'restartCmd': parser_args.restartCmd,
            'notes': parser_args.notes,
            'seed': parser_args.seed,
            'logFile': log_file,
            'resultFile': result_file,
            'bolt': parser_args.uri
        }
        with open(parser_args.config) as config_file:
            config_file_json = json.load(config_file)

        # Build our "results" and "log" directories if they do not exist.
        try:
            os.makedirs(parser_args.resultsDir)
        except FileExistsError:
            pass
        try:
            os.makedirs(parser_args.logDir)
        except FileExistsError:
            pass

        # We will log to the console and to a file.
        fh = logging.FileHandler(log_file)
        fh.setFormatter(FORMATTER)
        LOGGER.addHandler(fh)
        LOGGER.setLevel(logging.DEBUG if parser_args.debug else logging.INFO)
        LOGGER.info(f'Results being logged to: {result_file}')
        LOGGER.info(f'Console log being copied to: {log_file}')

        # Walk our query directory and gather each query filename.
        query_files = list()
        for directory_path, directories, files in os.walk(parser_args.queryDir):
            for filename in files:
                if not filename.endswith('.cypher'):
                    LOGGER.warning(f'File {filename} is not a query file! Skipping.')
                else:
                    query_files.append(os.path.join(directory_path, filename))

        # Same for our parameters: walk our parameter directory and gather each parameter filename.
        parameter_files = list()
        for directory_path, directories, files in os.walk(parser_args.parametersDir):
            for filename in files:
                if not filename.endswith('.parquet') and not filename.endswith('.csv'):
                    LOGGER.warning(f'File {filename} is not an expected parameter file! Skipping.')
                else:
                    parameter_files.append(os.path.join(directory_path, filename))

        # Build our workload specification.
        specification = list()
        for query_spec in config_file_json['workload']:
            specification.append(ClientQuerySpecification(
                parameter_files=query_spec['parameterFiles'],
                query_file=query_spec['queryFile'],
                repeat=query_spec['repeat'],
                timeout=query_spec['timeout']
            ))
        super().__init__(query_files, parameter_files, result_file, log_file, parser_args.restartCmd, specification,
                         parser_args.seed, parser_args.notify, parser_args.debug, client_config)

    def _execute_request(self, query: str, is_profile: bool = False, is_explain: bool = False) -> typing.Dict:
        try:
            auth_tuple = (os.getenv('NEO4J_USERNAME'), os.getenv('NEO4J_PASSWORD'),)
            driver = neo4j.GraphDatabase.driver(self.config['bolt'], auth=auth_tuple, max_connection_lifetime=36000)
            with driver.session() as session:
                explain_query, profile_query = f'EXPLAIN {query}', f'PROFILE {query}'
                response = session.run(explain_query if is_explain else profile_query if is_profile else query)

                # Handle our results. Different fields show up in our result depending on the execution mode.
                json_f = lambda j: json.dumps(j, default=lambda d: str(d))
                results = {'results': json_f(response.data())}
                result_summary = response.consume()
                results = {**results, 'metadata': json_f(result_summary.metadata), 'status': 'success'}
                if is_profile or is_explain:
                    results = {
                        **results,
                        'profile': json_f(result_summary.profile),
                        'plan': json_f(result_summary.plan),
                    }
                return results

        except neo4j.exceptions.TransientError as e:
            LOGGER.error(f'Transient exception thrown by Neo4J:\n{str(e)}')
            return {'status': 'non-fatal', 'messages': str(e)}

        # noinspection PyBroadException
        except Exception as e:
            LOGGER.error(f'Exception thrown by Neo4J:\n{str(e)}')
            if 'java.lang.OutOfMemoryError' in str(e):
                return {'status': 'non-fatal', 'messages': str(e)}
            else:
                return {'status': 'error', 'message': str(e)}

    def explain_query(self, query: str) -> typing.Dict:
        response = self._execute_request(query, is_explain=True)
        if response['status'] != 'error' and 'plan' in response:
            return response['plan']
        else:
            return response

    def execute_query(self, query: str, output: multiprocessing.Queue) -> None:
        output.put(self._execute_request(query, is_profile=self.is_debug))

    def construct_query(self, raw_query: str, parameters: typing.Dict[str, typing.Any]) -> str:
        # Perform parameter substitution on the query above.
        query_variables = re.findall(r'\$\w+', raw_query)
        output_query_string = raw_query
        for variable in query_variables:
            value = parameters[variable.lower().replace('$', '')]
            if value is None:
                raise LookupError(f'Could not find parameter for query:\n{raw_query}')

            # Format our value (if necessary).
            formatted_value = str(value)
            if type(value) == str:
                formatted_value = f'"{value}"'
            elif type(value) == datetime.datetime:
                formatted_value = f'DATETIME("{value.isoformat()}")'
            elif type(value) == list and all(type(v) == str for v in value):
                quoted_items = [f'"{v}"' for v in value]
                formatted_value = f'[{",".join(quoted_items)}]'
            elif not isinstance(value, numbers.Number):
                raise ValueError(f'Given type is not string, datetime, list(str), or numeric, but: {type(value)}')
            output_query_string = output_query_string.replace(variable, formatted_value)

        return output_query_string

if __name__ == '__main__':
    Neo4jBenchmarkClient()()
