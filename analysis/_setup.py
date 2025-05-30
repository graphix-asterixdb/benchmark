import requests

if __name__ == '__main__':
    # print("...Creating Dataverse and Types...")
    # for n in [1, 2, 4, 8, 16, 32]:
    #     response = requests.post(
    #         "http://localhost:19002/query/service",
    #         json={
    #             "statement": f"""
    #                 DROP DATAVERSE SNB.Analysis.N{n} IF EXISTS;
    #                 CREATE DATAVERSE SNB.Analysis.N{n} IF NOT EXISTS;
    #                 USE SNB.Analysis.N{n};
    #
    #                 CREATE TYPE GenericType AS {{ _id: uuid }};
    #                 CREATE TYPE NoType AS {{  }};
    #             """
    #         }
    #     )
    #     print(response.text)
    #
    # print("...Creating CC Datasets...")
    # for n in [1, 2, 4, 8, 16, 32]:
    #     response = requests.post(
    #         "http://localhost:19002/query/service",
    #         json={
    #             "statement": f"""
    #                 USE SNB.Analysis.N{n};
    #
    #                 CREATE EXTERNAL DATASET CCLogs (NoType) USING localfs (
    #                     ("path"="localhost:///Users/glenn.galvizo/Projects/AsterixDB/graphix-experiments/results/n={n}/cc.json"),
    #                     ("format"="json")
    #                 );
    #             """
    #         },
    #     )
    #     print(response.text)
    #
    # print("...Creating Experiment Datasets...")
    # for n in [1, 2, 4, 8, 16, 32]:
    #     response = requests.post(
    #         "http://localhost:19002/query/service",
    #         json={
    #             "statement": f"""
    #                 USE SNB.Analysis.N{n};
    #
    #                 CREATE EXTERNAL DATASET ExperimentLogs (NoType) USING localfs (
    #                     ("path"="localhost:///Users/glenn.galvizo/Projects/AsterixDB/graphix-experiments/results/n={n}/graphix.json"),
    #                     ("format"="json")
    #                 );
    #             """
    #         },
    #     )
    #     print(response.text)
    #
    # print("...Creating QueryWindows Views...")
    # for n in [1, 2, 4, 8, 16, 32]:
    #     response = requests.post(
    #         "http://localhost:19002/query/service",
    #         json={
    #             "statement": f"""
    #                 USE SNB.Analysis.N{n};
    #
    #                 CREATE VIEW QueryWindows AS
    #                     FROM
    #                         SNB.Analysis.N{n}.ExperimentLogs el,
    #                         (
    #                           FROM
    #                             SNB.Analysis.N{n}.CCLogs ccli
    #                           SELECT
    #                             ccli.*,
    #                             LEAD(ccli.timestamp) OVER (
    #                               PARTITION BY ccli._id
    #                               ORDER BY ccli.timestamp ASC
    #                             ) AS endingTimestamp
    #                         ) ccl
    #                     WHERE
    #                         el.query = ccl.query
    #                     SELECT
    #                         ccl.timestamp AS startingTimestamp,
    #                         COALESCE(ccl.endingTimestamp, 9223372036854775806) AS endingTimestamp,
    #                         el.queryFile;
    #             """
    #         },
    #     )
    #     print(response.text)
    #
    # print("...Creating MarkerCount Datasets...")
    # for n in [1, 2, 4, 8, 16, 32]:
    #     path_string = ",".join(f"localhost:///Users/glenn.galvizo/Projects/AsterixDB/graphix-experiments/results/n={n}/"
    #                            f"logs/markerCount.{i}.log" for i in range(1, n+1))
    #     response = requests.post(
    #         "http://localhost:19002/query/service",
    #         json={
    #             "statement": f"""
    #                 USE SNB.Analysis.N{n};
    #
    #                 CREATE TYPE MarkerCountType AS {{ timestamp: bigint, pid: int }};
    #                 CREATE DATASET MarkerCounts (MarkerCountType) PRIMARY KEY timestamp, pid;
    #                 LOAD DATASET MarkerCounts USING localfs (
    #                     ("path"="{path_string}"),
    #                     ("format"="json")
    #                 );
    #             """
    #         },
    #     )
    #     print(response.text)
    #
    # print("...Creating CoordinatorLogs Datasets...")
    # for n in [1, 2, 4, 8, 16, 32]:
    #     response = requests.post(
    #         "http://localhost:19002/query/service",
    #         json={
    #             "statement": f"""
    #                 USE SNB.Analysis.N{n};
    #
    #                 CREATE EXTERNAL DATASET AllCoordinatorLogs (NoType) USING localfs (
    #                     ("path"="localhost:///Users/glenn.galvizo/Projects/AsterixDB/graphix-experiments/results/n={n}/logs/coordinator.1.log"),
    #                     ("format"="json")
    #                 );
    #
    #                 CREATE TYPE CoordinatorLogType AS {{ timestamp: bigint }};
    #                 CREATE DATASET CoordinatorLogs (CoordinatorLogType) PRIMARY KEY timestamp;
    #
    #                 -- We originally filtered here, but for now we'll just take all logs. --
    #                 INSERT INTO CoordinatorLogs
    #                     FROM
    #                         AllCoordinatorLogs acl
    #                     SELECT VALUE
    #                         acl;
    #             """
    #         },
    #     )
    #     print(response.text)

    print("...Creating PathLength Datasets...")
    # for n in [1, 2, 4, 8, 16, 32]:
    for n in [8]:
        path_string = ",".join(
            f"localhost:///Users/glenn.galvizo/Projects/AsterixDB/graphix-experiments/results/n={n}/"
            f"logs/pathLength.{i}.log"
            for i in range(1, n + 1)
        )
        response = requests.post(
            "http://localhost:19002/query/service",
            json={
                "statement": f"""
                            USE SNB.Analysis.N{n};
    
                            CREATE EXTERNAL DATASET AllPathLengths (NoType) USING localfs (
                                ("path"="{path_string}"),
                                ("format"="json")
                            );

                            CREATE TYPE PathLengthType AS {{ _id: uuid }};
                            CREATE DATASET PathLengths (PathLengthType) PRIMARY KEY _id AUTOGENERATED;
                            INSERT INTO PathLengths
                                FROM 
                                    QueryWindows qw,
                                    AllPathLengths apl
                                WHERE
                                    apl.`timestamp` > qw.startingTimestamp AND
                                    apl.`timestamp` < qw.endingTimestamp
                                SELECT DISTINCT
                                    qw.queryFile,
                                    qw.startingTimestamp,
                                    qw.endingTimestamp,
                                    apl.`length`,
                                    apl.`timestamp`,
                                    apl.pid;
                        """
            },
        )
        print(response.text)
