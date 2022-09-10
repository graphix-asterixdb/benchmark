from benchmark import AbstractBenchmarkRunnable


class Neo4JBenchmarkRunnable(AbstractBenchmarkRunnable):
    def __init__(self, **kwargs):
        super().__init__(**kwargs)

    def generate_queries(self):
        pass

    def execute_query(self, query):
        pass


if __name__ == '__main__':
    Neo4JBenchmarkRunnable()()
