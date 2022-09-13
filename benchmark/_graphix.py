import datetime
import json
import argparse
import timeit
import requests
import time

from benchmark import AbstractBenchmarkRunnable


class GraphixBenchmarkRunnable(AbstractBenchmarkRunnable):
    @staticmethod
    def _collect_config(**kwargs):
        parser = argparse.ArgumentParser(description='Benchmark LDBC SNB queries on a Graphix instance.')
        parser.add_argument('--config', type=str, default='config/graphix.json', help='Path to the config file.')
        parser.add_argument('--notes', type=str, default='', help='Any notes to append to each log entry.')
        parser_args = parser.parse_args()

        # Load all configuration files into a single dictionary.
        with open(parser_args.config) as config_file:
            config_json = json.load(config_file)
        config_json['benchmarkDict'] = config_json['queries']

        # Specify the results directory.
        date_string = datetime.datetime.now().strftime('%Y-%m-%d-%H-%M-%S')
        config_json['resultsDir'] = f'out/GraphixSNB_{date_string}'

        # Return all relevant information to our caller.
        return {'workingSystem': 'AsterixDB', 'runtimeNotes': parser_args.notes, **config_json, **kwargs}

    def __init__(self, **kwargs):
        super().__init__(**self._collect_config(**kwargs))

        # Determine our API entry-point.
        self.nc_uri = self.config['clusterController']['address'] + ':' + \
                      str(self.config['clusterController']['port'])
        self.nc_uri = 'http://' + self.nc_uri + '/query/service'
        self.timeout = self.config['queryTimeout']

    def materialize_query(self, query) -> str:
        pass

    def execute_query(self, query):
        lean_query = ' '.join(query.split())
        api_parameters = {'statement': lean_query}

        # Retry the query until success.
        while True:
            try:
                self.logger.debug(f'Issuing query "{lean_query}" to cluster.')
                t_before = timeit.default_timer()
                response_json = requests.post(self.nc_uri, api_parameters, timeout=self.timeout).json()
                response_json['clientTime'] = timeit.default_timer() - t_before
                break
            except requests.exceptions.RequestException as e:
                if self.timeout is not None and isinstance(e, requests.exceptions.ReadTimeout):
                    self.logger.warning(f'Statement {query} has run longer than the specified timeout {self.timeout}.')
                    response_json = {'status': f'Timeout. Exception: {str(e)}'}
                    break
                else:
                    self.logger.warning(f'Exception caught: {str(e)}. Restarting the query in 5 seconds...')
                    time.sleep(5)

        if response_json['status'] != 'success':
            self.logger.warning(f'Status of executing statement {query} not successful, '
                                f'but instead {response_json["status"]}.')
            self.logger.warning(f'JSON dump: {response_json}')

        # Add the query to response.
        response_json['statement'] = lean_query
        return response_json


if __name__ == '__main__':
    GraphixBenchmarkRunnable()()
