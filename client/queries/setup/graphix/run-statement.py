# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.

import requests
import argparse
import re

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Execute statement(s) on some AsterixDB / Graphix instance.')
    parser.add_argument('--file', type=str, required=True, help='Location of the statement file to read.')
    parser.add_argument('--uri', type=str, required=True, help='URI pointing to the CC.')
    parser.add_argument('--sub', nargs='+', type=lambda a: (a.split(',')[0], a.split(',')[1], ),
                        help='K,V pairs to perform raw string substitution with.')
    parser_args = parser.parse_args()

    # Read and compress our statements from the file.
    with open(parser_args.file) as fp:
        raw_statement_string = fp.read()
    no_comment_statement_string = re.sub(r'//.*?(\r\n?|\n)|/\*.*?\*/', '', raw_statement_string, flags=re.S)
    compressed_statement_string = ' '.join(no_comment_statement_string.split())

    # If there are any parameters to substitute, do these now.
    final_statement_string = compressed_statement_string
    if parser_args.sub is not None:
        for k, v in parser_args.sub:
            final_statement_string = final_statement_string.replace('$' + k.upper(), v)

    # Issue the query to our CC.
    query_endpoint = parser_args.uri + '/query/service'
    response = requests.post(query_endpoint, {'statement': final_statement_string})
    print(response.json())
