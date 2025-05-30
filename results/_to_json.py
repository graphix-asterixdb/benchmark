import sys
import re
import json

if __name__ == '__main__':
    with open("cc.json", "w") as fp2:
        for file_path in sys.argv[1:]:
            with open(file_path, 'r') as fp1:
                for i, line in enumerate(fp1):
                    if match := re.match(r'.*handleRequest @ t=(\d+).*"statement":"(.*)","pretty(.*)"planFormat":"JSON.*"', line):
                        # print(i)
                        timestamp = int(match.group(1))
                        query = match.group(2)\
                            .replace(r'\\n', '\n')\
                            .replace(r'\\\"', '"')\
                            .replace(r'\\', '')
                        json.dump({
                            "timestamp": timestamp,
                            "query": query
                        }, fp2)
                        fp2.write('\n')
