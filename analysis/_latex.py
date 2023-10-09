import abc

class _AbstractBuilder(abc.ABC):
    def __init__(self):
        self.graphix_collection = list()
        self.neo4j_collection = list()

    def accept(self, system, query_class, execution_time, error, **kwargs):
        if system == 'Graphix':
            self.graphix_collection.append({'executionTime': execution_time,
                                            'queryClass': query_class,
                                            'clusterSize': kwargs['cluster_size'],
                                            'error': error})
        else:
            self.neo4j_collection.append({'executionTime': execution_time,
                                          'queryClass': query_class,
                                          'error': error})

    @abc.abstractmethod
    def build(self, fp):
        pass

class BusinessIntelligencePlotBuilder(_AbstractBuilder):
    def build(self, fp):
        # Write our header.
        fp.write(r"""
        \begin{figure*}[p]
          \centering
          \begin{tikzpicture}
            \begin{groupplot}[%
              group style={group size=4 by 2},%
              width=0.25\linewidth,%
              xtick={1,16,32},%
              minor xtick={2,4,8},%
              xmin=0,%
              xmax=33,%
              clip limits=false,%
              scaled y ticks=false,%
              ymin=-10,%
              ytick style={draw=none}%
            ]
        """)

        # We use the following group-plot headers:
        headers = {
            'BI-1': r"\nextgroupplot[title={BI-1},ylabel={Execution Time (s)}]",
            'BI-2': r"\nextgroupplot[title={BI-2}]",
            'BI-5': r"\nextgroupplot[title={BI-5}]",
            'BI-7': r"\nextgroupplot[title={BI-7}]",
            'BI-8': r"\nextgroupplot[title={BI-8},ylabel={Execution Time (s)},xlabel={Number of Workers ($n$)}]",
            'BI-14': r"\nextgroupplot[title={BI-14},xlabel={Number of Workers ($n$)}]",
            'BI-16': r"\nextgroupplot[title={BI-16},xlabel={Number of Workers ($n$)}]",
            'BI-18': r"\nextgroupplot[title={BI-18},xlabel={Number of Workers ($n$)}]"
        }

        # Write our plots.
        for h in headers.keys():
            fp.write(headers[h] + '\n')
            fp.write(r"\addplot+[mark=asterisk] coordinates {")
            graphix_t = list(map(
                lambda x: f'({x["clusterSize"]}, {x["executionTime"]})',
                sorted(
                    list(x for x in self.graphix_collection if x['queryClass'] == h),
                    key=lambda x: x['clusterSize']
                )
            ))
            fp.write(' '.join(graphix_t))
            fp.write(r"};" + '\n')
            if any(x['queryClass'] == h for x in self.neo4j_collection):
                fp.write(r"\addplot+[mark=none,line width=2pt,dashed,YellowGreen] coordinates {")
                neo4j_t = str(list(x['executionTime'] for x in self.neo4j_collection if x['queryClass'] == h)[0])
                fp.write(r"(-1000, " + neo4j_t + r") (1000, " + neo4j_t + r")};")
            fp.write('\n')

        # Conclude with our footer.
        fp.write(r"""
            \end{groupplot}
          \end{tikzpicture}
          \caption{%
            Several plots showing a Graphix cluster of varying size (in blue) against a Neo4J instance (in green) for the business intelligence queries \lstinline{BI-}$\{{1,2,5,8,14,16,18}\}$.
            Neo4J did not finish under 5 hours for queries \lstinline{BI-\{2,8,14,16\}}.
          }
          \label{fig:biPlot}
        \end{figure*}
        """)

class ComplexPlotBuilder(_AbstractBuilder):
    def build(self, fp):
        # Write our header.
        fp.write(r"""
        \begin{figure*}[p]
          \centering
          \begin{tikzpicture}
            \begin{groupplot}[%
              group style={group size=4 by 2},%
              width=0.25\linewidth,%
              xtick={1,16,32},%
              minor xtick={2,4,8},%
              xmin=0,%
              xmax=33,%
              clip limits=false,%
              scaled y ticks=false,%
              ytick style={draw=none}%
            ]
        """)

        # We use the following group-plot headers:
        headers = {
            'C-2': r"\nextgroupplot[title={C-2},ylabel={Execution Time (s)},xlabel={Number of Workers ($n$)},ymin=-5]",
            'C-4': r"\nextgroupplot[title={C-4},xlabel={Number of Workers ($n$)},ymin=-2]",
            'C-7': r"\nextgroupplot[title={C-7},xlabel={Number of Workers ($n$)},ymin=-0.1]",
            'C-8': r"\nextgroupplot[title={C-8},xlabel={Number of Workers ($n$)},ymin=-0.1]"
        }

        # Write our plots.
        for h in headers.keys():
            fp.write(headers[h] + '\n')
            fp.write(r"\addplot+[mark=asterisk] coordinates {")
            graphix_t = list(map(
                lambda x: f'({x["clusterSize"]}, {x["executionTime"]})',
                sorted(
                    list(x for x in self.graphix_collection if x['queryClass'] == h),
                    key=lambda x: x['clusterSize']
                )
            ))
            fp.write(' '.join(graphix_t))
            fp.write(r"};" + '\n')
            if any(x['queryClass'] == h for x in self.neo4j_collection):
                fp.write(r"\addplot+[mark=none,line width=2pt,dashed,YellowGreen] coordinates {")
                neo4j_t = str(list(x['executionTime'] for x in self.neo4j_collection if x['queryClass'] == h)[0])
                fp.write(r"(-1000, " + neo4j_t + r") (1000, " + neo4j_t + r")};")
            fp.write('\n')

        # Conclude with our footer.
        fp.write(r"""
            \end{groupplot}
          \end{tikzpicture}
          \caption{Several plots showing a Graphix cluster of varying size (in blue) against a Neo4J instance (in green) for the complex-interactive workload queries \lstinline{C-}$\{{2,4,7,8}\}$.}
          \label{fig:ciResults}
        \end{figure*}
        """)

class TableBuilder(_AbstractBuilder):
    @staticmethod
    def _format_number(execution_time, error):
        rounder = lambda a: str(round(a, 1))
        if execution_time < 1.0:
            return r'\SI{' + rounder(execution_time * 1000) + '(' + rounder(error * 1000) + r')}{\milli\s}'
        elif execution_time > 1000.0:
            return r'\SI{' + rounder(execution_time / 60.0) + '(' + rounder(error / 60.0) + r')}{\minute}'
        else:
            return r'\SI{' + rounder(execution_time) + '(' + rounder(error) + r')}{\s}'

    def build(self, fp):
        # Write our header.
        fp.write(r"""
        \begin{table*}[p]
          \setlength{\tabcolsep}{4pt}
          \centering
          \begin{tabularx}{\textwidth}{Xrrrrrrr} \toprule
          Query & Neo4J ($n=1$) & Graphix ($n=1$) &  Graphix ($n=2$) & Graphix ($n=4$) &  Graphix ($n=8$) &  Graphix ($n=16$) &  Graphix ($n=32$) \\
          \midrule
        """)

        # We use the following 'headers':
        bi_headers = {
            'BI-1': r"\lstinline{BI-1}",
            'BI-2': r"\lstinline{BI-2}",
            'BI-5': r"\lstinline{BI-5}",
            'BI-7': r"\lstinline{BI-7}",
            'BI-8': r"\lstinline{BI-8}",
            'BI-16': r"\lstinline{BI-16}",
            'BI-14': r"\lstinline{BI-14}",
            'BI-18': r"\lstinline{BI-18}"
        }
        complex_headers = {
            'C-2': r"\lstinline{C-2}",
            'C-4': r"\lstinline{C-4}",
            'C-7': r"\lstinline{C-7}",
            'C-8': r"\lstinline{C-8}"
        }

        # Write our table rows.
        for j, d in enumerate([bi_headers, complex_headers]):
            for h in d.keys():
                fp.write(d[h] + ' & ')
                if any(x['queryClass'] == h for x in self.neo4j_collection):
                    neo4j_t = list(x for x in self.neo4j_collection if x['queryClass'] == h)[0]
                    fp.write(self._format_number(neo4j_t['executionTime'], neo4j_t['error']) + ' & ')
                elif h == 'BI-11':
                    fp.write(r' \lstinline{N/A} (\lstinline{OOM}) & ')
                else:
                    fp.write(r' $>$\SI{5}{\hour} (\lstinline{T/O}) & ')
                graphix_t = list()
                for i in [1, 2, 4, 8, 16, 32]:
                    if any(x['clusterSize'] == i and x['queryClass'] == h for x in self.graphix_collection):
                        graphix_v = next(
                            x for x in self.graphix_collection if x['clusterSize'] == i and x['queryClass'] == h
                        )
                        graphix_v = self._format_number(graphix_v['executionTime'], graphix_v['error'])
                    else:
                        graphix_v = r' $>$ \SI{5}{\hour} (\lstinline{T/O})'
                    graphix_t.append(graphix_v)
                fp.write(r' & '.join(graphix_t))
                fp.write(r" \\ " + '\n')
            if j == 0:
                fp.write(r'\midrule' + '\n')

        # Finish with our footer.
        fp.write(r"""
            \bottomrule
          \end{tabularx}
          \caption{Table showing execution times of business intelligence queries (\lstinline{BI-X}) and complex interactive queries (\lstinline{C-X}) with different Graphix cluster configurations.}
          \label{tab:scaleUpTable}
        \end{table*}
        """)
