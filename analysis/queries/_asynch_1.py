import requests
import json

if __name__ == '__main__':
    results = []
    # for i in [1, 2, 4, 8, 16, 32]:
    for i in [8]:
        response = requests.post(
            "http://127.0.0.1:19002/query/service",
            json={
                "statement": f"""
                    USE SNB.Analysis.N{i};
                    
                    WITH 
                        PathLengthsWithGroup AS (
                            FROM
                                PathLengths pl
                            LET 
                                d = pl.`timestamp` - pl.startingTimestamp,
                                W = pl.endingTimestamp - pl.startingTimestamp,
                                t = ( d / W ),
                                qt = ROUND(t, 1) * 10
                            WHERE
                                qt > 0
                            SELECT
                                qt           AS timeGrouping,
                                pl.pid       AS pid,
                                pl.queryFile AS queryFile,
                                pl.`length`  AS ell,
                                ROW_NUMBER() OVER (
                                    PARTITION BY qt
                                    ORDER BY pl.`timestamp` ASC
                                ) AS rn,
                                COUNT(*)     OVER (
                                    PARTITION BY qt
                                ) AS cnt
                        )
                    FROM
                        PathLengthsWithGroup plwg
                    LET 
                        lwn  = 1,
                        lbn  = ROUND(0.25 * plwg.cnt),
                        medn = ROUND(0.50 * plwg.cnt),
                        ubn  = ROUND(0.75 * plwg.cnt),
                        uwn  = plwg.cnt
                    WHERE
                        plwg.rn IN [lwn, lbn, medn, ubn, uwn]
                    SELECT
                        plwg.timeGrouping AS t,
                        plwg.ell          AS ell, 
                        CASE
                            WHEN plwg.rn = lwn
                            THEN "Lower Whisker"
                            WHEN plwg.rn = lbn
                            THEN "Lower Box"
                            WHEN plwg.rn = medn
                            THEN "Median"
                            WHEN plwg.rn = ubn
                            THEN "Upper Box"
                            WHEN plwg.rn = uwn
                            THEN "Upper Whisker"
                        END AS stat;
                """
            }
        )
        results.append(response.json()["results"])
        print(json.dumps(results[-1], indent=1))

    for result in results:
        by_t = dict()
        for i in result:
            if i["t"] not in by_t:
                by_t[i["t"]] = dict()
            by_t[i["t"]][i["stat"]] = i["ell"]
        for t in sorted(list(by_t.keys())):
            lw = by_t[t]["Lower Whisker"]
            lb = by_t[t]["Lower Box"]
            m = by_t[t]["Median"]
            ub = by_t[t]["Upper Box"]
            uw = by_t[t]["Upper Whisker"]
            print(
                r'\addplot+ [boxplot prepared={'
                f'lower whisker={lw},'
                f'lower quartile={lb},'
                f'median={m},'
                f'upper quartile={ub},'
                f'upper whisker={uw}'
                r'}] coordinates {};'
            )
