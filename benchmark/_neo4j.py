from benchmark import AbstractBenchmarkRunnable


class Neo4JBenchmarkRunnable(AbstractBenchmarkRunnable):
    def __init__(self, **kwargs):
        super().__init__(**kwargs)

    def materialize_query(self, query) -> str:
        pass

    def execute_query(self, query):
        pass


if __name__ == '__main__':
    Neo4JBenchmarkRunnable()()
