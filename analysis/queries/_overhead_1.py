import requests
import json

if __name__ == '__main__':
    results = []
    for i in [1, 2, 4, 8, 16, 32]:
        response = requests.post(
            "http://127.0.0.1:19002/query/service",
            json={
                # "statement": f"""
                #     WITH
                #         RunOverheads AS (
                #           FROM
                #               SNB.Analysis.N{i}.QueryWindows qw,
                #               SNB.Analysis.N{i}.MarkerCounts mc
                #           WHERE
                #               mc.timestamp BETWEEN qw.startingTimestamp AND qw.endingTimestamp
                #           GROUP BY
                #               qw
                #               GROUP AS g
                #           LET
                #               mNum = ARRAY_COUNT(( FROM g gi WHERE gi.mc.kind = "marker" SELECT 1 )),
                #               dNum = ARRAY_COUNT(( FROM g gi WHERE gi.mc.kind <> "marker" SELECT 1 )),
                #               overhead = mNum / (mNum + dNum)
                #           SELECT
                #               qw.queryFile,
                #               mNum,
                #               dNum,
                #               overhead,
                #               COUNT(*) AS cnt
                #         )
                #     FROM
                #         RunOverheads ro
                #     SELECT
                #         {i} AS n,
                #         AVG(ro.overhead) AS overhead,
                #         1 - AVG(ro.overhead) AS work,
                #         AVG(ro.cnt) AS avg_cnt,
                #         MAX(ro.cnt) AS max_cnt,
                #         MIN(ro.cnt) AS min_cnt;
                # """
                # "statement": f"""
                #     LET
                #         mNum = ARRAY_COUNT((
                #             FROM
                #                 SNB.Analysis.N{i}.MarkerCounts mc
                #             WHERE
                #                 mc.kind = "marker"
                #             SELECT 1
                #         )),
                #         dNum = ARRAY_COUNT((
                #             FROM
                #                 SNB.Analysis.N{i}.MarkerCounts mc
                #             WHERE
                #                 mc.kind <> "marker"
                #             SELECT 1
                #         ))
                #     SELECT
                #         {i} AS n,
                #         mNum,
                #         dNum,
                #         mNum / (dNum + mNum) AS overhead,
                #         dNum / (dNum + mNum) AS work;
                # """
                "statement": f"""
                    WITH 
                        PerNodeMarkerCount AS (
                            FROM
                                SNB.Analysis.N{i}.MarkerCounts mc
                            GROUP BY
                                mc.pid
                                GROUP AS g
                            LET
                                mNum = ( 
                                    FROM 
                                        g gi 
                                    WHERE 
                                        gi.mc.kind = "marker"
                                    SELECT VALUE
                                        COUNT(*) 
                                )[0],
                                dNum = (
                                    FROM 
                                        g gi 
                                    WHERE 
                                        gi.mc.kind = "data"
                                    SELECT VALUE
                                        COUNT(*) 
                                )[0]
                            SELECT
                                mc.pid AS pid,
                                mNum AS mNum,
                                dNum AS dNum,
                                mNum / (dNum + mNum) AS overhead,
                                dNum / (dNum + mNum) AS work
                        )
                    FROM
                        PerNodeMarkerCount pmc
                    SELECT
                        {i} AS n,
                        AVG(pmc.overhead) AS overhead,
                        AVG(pmc.work) AS work,
                        AVG(pmc.mNum) AS avgMNum,
                        AVG(pmc.dNum) AS avgDNum 
                """
            }
        )
        results.append(response.json()["results"][0])
        print(json.dumps(results[-1], indent=1))

    overhead_coords = " ".join(f"({item['n']}, {item['overhead']})" for item in results)
    work_coords = " ".join(f"({item['n']}, {item['work']})" for item in results)
    result = (
        f"\\addplot coordinates {{{work_coords}}} \\closedcycle;\n"
        f"\\addplot coordinates {{{overhead_coords}}} \\closedcycle;\n"
    )
    print(result)
