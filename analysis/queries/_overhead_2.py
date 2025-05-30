import requests
import json

if __name__ == '__main__':
    results = []
    for i in [1, 2, 4, 8, 16, 32]:
        response = requests.post(
            "http://127.0.0.1:19002/query/service",
            json={
                "statement": f"""
                    USE SNB.Analysis.N{i};
                    
                    FROM 
                        CoordinatorLogs cl,
                        QueryWindows qw
                    WHERE
                        cl.timestamp BETWEEN 
                            qw.startingTimestamp AND 
                            qw.endingTimestamp
                    GROUP BY
                        qw
                        GROUP AS g
                    SELECT 
                        {i} AS n,
                        qw.queryFile,
                        (
                          FROM
                            g gi
                          WHERE
                            gi.cl.`type` = "election" AND
                            gi.cl.status IS NOT UNKNOWN
                          GROUP BY
                            gi.cl.status
                          SELECT
                            gi.cl.status,
                            COUNT(*) AS cnt
                        ) AS election;
                """
            }
        )
        results.append(response.json()["results"])
        print(json.dumps(results[-1], indent=1))
