import logging.config
import datetime
import logging
import uuid
import os
import subprocess
import abc
import json
import pathlib
import tempfile


class AbstractBenchmarkRunnable(abc.ABC):
    """ Base class which facilitates our benchmark client.

    A child of this class must provide the following at instantiation as keyword arguments:
    :keyword resultDir: Relative location to write query results and logs to.
    :keyword queryDir: Relative location to read non-parameterized query files from.
    :keyword workingSystem: Name of the system we are working with.
    :keyword benchmarkDict: Dictionary that maps query filenames to repeats (integers).
    """

    def call_subprocess(self, command, is_log=True):
        """ Run a subprocess and return its output. """
        subprocess_pipe = subprocess.Popen(
            command,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            universal_newlines=True
        )

        resultant = ''
        for stdout_line in iter(subprocess_pipe.stdout.readline, ""):
            if stdout_line.strip() != '':
                resultant += stdout_line
                for line in resultant.strip().split('\n'):
                    if is_log:
                        self.logger.debug(line)
        subprocess_pipe.stdout.close()
        return resultant

    def __init__(self, **kwargs):
        # Create our results directory if it does not already exist.
        os.mkdir(os.getcwd() + '/' + kwargs['resultsDir'])

        # Initialize our logger.
        self.logger = logging.getLogger(__name__)
        self.logger.setLevel(logging.DEBUG)
        formatter = logging.Formatter("%(asctime)s - %(levelname)s - %(message)s")

        # We will log to the console and to a file.
        fh = logging.FileHandler(f"{kwargs['resultsDir']}/ldbc-snb.log")
        fh.setLevel(logging.DEBUG)
        ch = logging.StreamHandler()
        ch.setLevel(logging.INFO)
        fh.setFormatter(formatter)
        ch.setFormatter(formatter)
        self.logger.addHandler(fh)
        self.logger.addHandler(ch)

        # Results will be recorded to a separate file (in lines-JSON format).
        self.results_fp = open(kwargs['resultsDir'] + '/' + 'results.json', 'w')

        self.logger.info(f'Using the following configuration: {kwargs}')
        self.working_system = kwargs['workingSystem']
        self.execution_id = str(uuid.uuid4())
        self.config = kwargs

    def log_results(self, results):
        results['logTime'] = str(datetime.datetime.now())
        results['executionID'] = self.execution_id
        results['workingSystem'] = self.working_system
        results['runtimeNotes'] = self.config['runtimeNotes']

        # To the results file.
        self.logger.debug('Recording result to disk.')
        json.dump(results, self.results_fp)
        self.results_fp.write('\n')

        # To the console.
        self.logger.debug('Writing result to console.')
        self.logger.debug(json.dumps(results))

    @abc.abstractmethod
    def execute_query(self, query) -> dict:
        """ Execute a given query and return a dictionary of the results + statistics. """
        pass

    @abc.abstractmethod
    def materialize_query(self, query) -> str:
        """ Parameterize and return the given query. """
        pass

    def generate_queries(self) -> str:
        """ Generate a collection of directories containing query files. """
        benchmark_dict = self.config['benchmarkDict']
        while any(v['repeat'] > 0 for k, v in benchmark_dict):
            output_dir = tempfile.mkdtemp()

            # Iterate through all queries that have iterations left.
            for query_file, query_info in benchmark_dict:
                if query_info['repeat'] == 0:
                    continue
                else:
                    query_info['repeat'] = query_info['repeat'] - 1

                # Parameterize / materialize our query.
                with open(self.config['queryDir'] + '/' + query_file, 'r') as fp1, \
                     open(output_dir + '/' + query_file, 'w') as fp2:
                    fp2.write(self.materialize_query(fp1.read()))

            yield output_dir

    def __call__(self, *args, **kwargs):
        self.logger.info(f'Starting benchmark! (execution id: {self.execution_id}, '
                         f'working system: {self.working_system}).')

        for i, query_dir in enumerate(self.generate_queries()):
            self.logger.info(f'Entering iteration {i}.')

            # Populate our query file list.
            self.logger.info(f'Scanning {query_dir} for query files.')
            query_files = []
            for path, _, files in os.walk(query_dir):
                query_files += [pathlib.PurePath(path, n) for n in files]
            if len(query_files) == 0:
                self.logger.info('No queries found this iteration.')
                break
            self.logger.debug(f'Found query files: {query_files}.')

            # Execute each query in our query file list.
            for query_file in query_files:
                with open(query_file, 'r') as fp:
                    query = fp.read()
                    self.logger.info(f'Executing query: {query}')
                    self.log_results(self.execute_query(query))

        # Flush our loggers.
        self.logger.info('Flushing the logger.')
        [h.flush() for h in self.logger.handlers]

        self.results_fp.close()
        self.logger.info('Benchmark has finished executing.')
