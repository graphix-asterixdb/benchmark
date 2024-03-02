import math
import glob
import numpy
import halstead

if __name__ == '__main__':
    all_languages = dict()
    for f in glob.glob('annotations/*.json'):
        print(f'Working with query: {f.removesuffix(".json")}')
        agg_stats = [s for s in halstead.analyze_annotation(f)]

        # Find the minimum and maximum values.
        min_v, min_d, min_e = math.inf, math.inf, math.inf
        max_v, max_d, max_e = 0, 0, 0
        for stat in agg_stats:
            min_v, min_d, min_e = min(min_v, stat.v), min(min_d, stat.d), min(min_e, stat.e)
            max_v, max_d, max_e = max(max_v, stat.v), max(max_d, stat.d), max(max_e, stat.e)
            if stat.language not in all_languages:
                all_languages[stat.language] = []

        # Normalize our statistics.
        norm_stats = []
        for stat in agg_stats:
            print(f'\tLanguage: {stat.language}')

            v = (stat.v - min_v) / (max_v - min_v)
            d = (stat.d - min_d) / (max_d - min_d)
            e = (stat.e - min_e) / (max_e - min_e)
            print(f'\t\tNormalized Volume: {v:.2f}')
            print(f'\t\tNormalized Difficulty: {d:.2f}')
            print(f'\t\tNormalized Effort: {e:.2f}')
            all_languages[stat.language].append({'v': v, 'd': d, 'e': e})

    # Summarize observations across all queries.
    print('--------------------------------------------')
    for k, v in all_languages.items():
        print(f'Language: {k}')
        for measure in ['v', 'd', 'e']:
            measure_axis = [s[measure] for s in v]
            min_m = numpy.min(measure_axis)
            perc_m_25 = numpy.percentile(measure_axis, 25)
            med_m = numpy.median(measure_axis)
            perc_m_75 = numpy.percentile(measure_axis, 75)
            max_m = numpy.max(measure_axis)
            print(f'\t{measure.upper()}: [{min_m:.2f}, {perc_m_25:.2f}, {med_m:.2f}, {perc_m_75:.2f}, {max_m:.2f}]')
