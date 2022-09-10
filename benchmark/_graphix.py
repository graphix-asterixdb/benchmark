from benchmark import AbstractBenchmarkRunnable


class GraphixBenchmarkRunnable(AbstractBenchmarkRunnable):
    def __init__(self, **kwargs):
        super().__init__(**kwargs)

    def generate_queries(self):
        pass

    def execute_query(self, query):
        pass


if __name__ == '__main__':
    GraphixBenchmarkRunnable()()