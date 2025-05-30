import requests
import json

if __name__ == '__main__':
    response = requests.post(
        "http://127.0.0.1:19002/query/service",
        json={
            "statement": """
                USE SNB.Analysis.N8;
                FROM 
                    PathLengths pl 
                LET 
                    d = pl.`timestamp` - pl.startingTimestamp,
                    W = pl.endingTimestamp - pl.startingTimestamp,
                    t = ( d / W ),
                    qt = ROUND(t, 2)
                WHERE 
                    pl.`queryFile` = "bi-17-v2.sqlpp"
                    -- pl.`queryFile` = "short-2-v1.sqlpp"
                GROUP BY
                    qt
                SELECT
                    BIGINT(qt * 100) AS qt,
                    MIN(pl.`length`) AS `min`,
                    MAX(pl.`length`) AS `max`,
                    STDDEV_POP(pl.`length`) AS std,
                    AVG(pl.`length`) AS `avg`;
            """
        }
    )
    results = response.json()['results']
    print(results)
    print(max(r['std'] for r in results))

    min_values, max_values, avg_values = [], [], []
    for result in results:
        min_values += [(result['qt'], result['min'], )]
        max_values += [(result['qt'], result['max'], )]
        avg_values += [(result['qt'], result['avg'], )]

    print(' '.join(f"({v[0]}, {v[1]})" for v in min_values))
    print("---")
    print(' '.join(f"({v[0]}, {v[1]})" for v in avg_values))
    print("---")
    print(' '.join(f"({v[0]}, {v[1]})" for v in max_values))
    print("---")
