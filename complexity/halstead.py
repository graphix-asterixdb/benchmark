import argparse
import json
import collections
import numpy

HalsteadMeasure = collections.namedtuple('HalsteadMeasure', ['language', 'eta', 'n', 'n_hat', 'v', 'd', 'e'])

def gather_operators(operators_list, working_v):
    if type(working_v) == list:
        for i in working_v:
            gather_operators(operators_list, i)
    elif type(working_v) == dict:
        operators_list.append(working_v['operator'])
        gather_operators(operators_list, working_v['operands'])

def gather_operands(operands_list, working_v):
    if type(working_v) == list:
        for i in working_v:
            gather_operands(operands_list, i)
    elif type(working_v) == dict:
        for i in working_v['operands']:
            if type(i) == str:
                operands_list.append(i)
        gather_operands(operands_list, working_v['operands'])

def validate_annotation(working_v):
    if type(working_v) == list:
        for i in working_v:
            validate_annotation(i)
    elif type(working_v) == dict:
        for k in working_v.keys():
            if k != 'operator' and k != 'operands':
                raise ValueError('Only operands and operators should be allowed in dictionaries! Encountered: ' + k)
        validate_annotation(working_v['operands'])
    elif type(working_v) != str:
        raise ValueError('Only strings are allowed to be leaf nodes! Encountered: ' + str(working_v))

def analyze_annotation(query_file):
    with open(query_file, 'r') as qf:
        annotation_list = json.load(qf)

    # Iterate over each entry.
    for query_impl in annotation_list:
        validate_annotation(query_impl['query'])
        all_operators, all_operands = list(), list()
        gather_operators(all_operators, query_impl['query'])
        gather_operands(all_operands, query_impl['query'])

        # Find our base numbers.
        eta_1 = len(set(all_operators))
        eta_2 = len(set(all_operands))
        n_1 = len(all_operators)
        n_2 = len(all_operands)

        # Compute our measures.
        eta = eta_1 + eta_2
        n = n_1 + n_2
        v = n * numpy.log2(eta)
        d = (eta_1 / 2.0) * (n_2 / eta_2)

        # Yield a result.
        yield HalsteadMeasure(**{
            'language': query_impl['language'],
            'eta': eta,
            'n': n,
            'n_hat': (eta_1 * numpy.log2(eta_1)) + (eta_2 * numpy.log2(eta_2)),
            'v': v,
            'd': d,
            'e': d * v
        })

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Return the Halstead measures of some query.')
    parser.add_argument('--queryFile', type=str, required=True, help='Query annotation file to analyze.')
    parser_args = parser.parse_args()

    for stat in analyze_annotation(parser_args.queryFile):
        print(f'Language: {stat.language}')

        # Print our statistics.
        print(f'\tProgram Vocabulary: {stat.eta}')
        print(f'\tProgram Length: {stat.n}')
        print(f'\tEstimated Program Length: {stat.n_hat}')
        print(f'\tVolume: {stat.v}')
        print(f'\tDifficulty: {stat.d}')
        print(f'\tEffort: {stat.e}')
