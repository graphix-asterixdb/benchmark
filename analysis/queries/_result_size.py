import requests

if __name__ == '__main__':
    response = requests.post(
        "http://localhost:19002/query/service",
        json={
            "statement": f"""
                FROM ( 
                      FROM SNB.Analysis.N1.ExperimentLogs n1
                      SELECT VALUE n1
                      UNION ALL
                      FROM SNB.Analysis.N2.ExperimentLogs n2
                      SELECT VALUE n2
                      UNION ALL
                      FROM SNB.Analysis.N4.ExperimentLogs n4
                      SELECT VALUE n4
                      UNION ALL
                      FROM SNB.Analysis.N8.ExperimentLogs n8
                      SELECT VALUE n8
                      UNION ALL
                      FROM SNB.Analysis.N16.ExperimentLogs n16
                      SELECT VALUE n16
                      UNION ALL
                      FROM SNB.Analysis.N32.ExperimentLogs n32
                      SELECT VALUE n32
                ) el 
                GROUP BY 
                    el.queryFile 
                SELECT 
                    el.queryFile, 
                    AVG(ARRAY_LENGTH(el.results)) AS resultSize;
            """
        }
    )
    print(response.json()['results'])