import abc
import inspect

class _TableBuilderMixin:
    @staticmethod
    def _format_number(execution_time):
        rounder = lambda a: str(round(a, 1))
        if execution_time < 1.0:
            return r'\SI{' + rounder(execution_time * 1000) + r'}{\milli\s}'
        elif execution_time > 1000.0:
            return r'\SI{' + rounder(execution_time / 60.0) + r'}{\minute}'
        else:
            return r'\SI{' + rounder(execution_time) + r'}{\s}'

    @staticmethod
    def _write_header(file_pointer):
        file_pointer.write(inspect.cleandoc(r"""
            \begin{sidewaystable}[p]
            \setlength{\tabcolsep}{4pt}
            \centering
            \begin{tabularx}{\textwidth}{Xrrrrrrr} \toprule
            Query & Neo4j ($n{=}1$) & Graphix ($n{=}1$) &  Graphix ($n{=}2$) & Graphix ($n{=}4$) &
                Graphix ($n{=}8$) & Graphix ($n{=}16$) &  Graphix ($n{=}32$) \\
            \midrule
        """))

    @staticmethod
    def _write_row(file_pointer, g_collection, n_collection, query_class, timeout):
        if any(x['queryClass'] == query_class for x in n_collection):
            neo4j_t = list(x for x in n_collection if x['queryClass'] == query_class)[0]
            file_pointer.write(_TableBuilderMixin._format_number(neo4j_t['executionTime']) + ' & ')
        else:
            file_pointer.write(r' $>$' + timeout + r' (\codetext{T/O}) & ')
        graphix_t = list()
        for i in [1, 2, 4, 8, 16, 32]:
            if any(x['clusterSize'] == i and x['queryClass'] == query_class for x in g_collection):
                graphix_v = next(
                    x for x in g_collection if x['clusterSize'] == i and x['queryClass'] == query_class
                )
                graphix_v = _TableBuilderMixin._format_number(graphix_v['executionTime'])
            else:
                graphix_v = r' $>$' + timeout + r' (\codetext{T/O})'
            graphix_t.append(graphix_v)
        file_pointer.write(r' & '.join(graphix_t))
        file_pointer.write(r" \\ " + '\n')

    @staticmethod
    def _write_footer(file_pointer, short_caption, long_caption, label_name):
        file_pointer.write(inspect.cleandoc(r"""
            \bottomrule
            \end{tabularx}
            \caption[""" + short_caption + "]{" + long_caption + r"""}
            \label{tab:""" + label_name + r"""}
            \end{sidewaystable}
          """))

class _PlotBuilderMixin:
    @staticmethod
    def _write_header(file_pointer):
        file_pointer.write(inspect.cleandoc(r"""
            \begin{figure}[p]
            \centering
        """))

    @staticmethod
    def _write_group_start(file_pointer, arg_string):
        file_pointer.write(inspect.cleandoc(r"""
            \begin{tikzpicture}[inner frame sep=0pt]
            \begin{groupplot}[%
            """ + arg_string + r"""
            width=0.26\linewidth,%
            xtick={1,16,32},%
            minor xtick={2,4,8},%
            xmin=0,%
            xmax=33,%
            ticklabel style={font=\footnotesize},%
            clip limits=false,%
            ytick style={draw=none},%
            scaled y ticks=false,%
            yticklabel style={/pgf/number format/fixed, /pgf/number format/precision=2},%
            ylabel={\footnotesize Time (s)},%
            xlabel={\footnotesize Cluster Size ($n$)},%
            title style={yshift=-0.25cm}%
            ]
        """))

    @staticmethod
    def _write_group_end(file_pointer):
        file_pointer.write(inspect.cleandoc(r"""
            \end{groupplot}
            \end{tikzpicture}
        """))

    @staticmethod
    def _write_plot(g_collection, n_collection, file_pointer, query_class, timeout):
        graphix_t = list(map(
            lambda x: f'({x["clusterSize"]}, {x["executionTime"]})',
            sorted(
                list(x for x in g_collection if x['queryClass'] == query_class),
                key=lambda x: x['clusterSize']
            )
        ))
        if len(graphix_t) == 0 and all(x['queryClass'] != query_class for x in n_collection):
            file_pointer.write(r'\addplot+[mark=none] coordinates {(1,' + str(timeout) + r')};' + '\n')
        elif len(graphix_t) > 0:
            file_pointer.write(r"\addplot+[mark=asterisk] coordinates {")
            file_pointer.write(' '.join(graphix_t))
            file_pointer.write(r"};" + '\n')
        if any(x['queryClass'] == query_class for x in n_collection):
            file_pointer.write(r"\addplot+[mark=none,line width=2pt,dashed,YellowGreen] coordinates {")
            neo4j_t = str(list(x['executionTime'] for x in n_collection if x['queryClass'] == query_class)[0])
            file_pointer.write(r"(-50, " + neo4j_t + r") (50, " + neo4j_t + r")};")
        file_pointer.write('\n')

    @staticmethod
    def _write_footer(file_pointer, short_caption, long_caption, label_name):
        file_pointer.write(inspect.cleandoc(r"""
            \caption[""" + short_caption + "]{" + long_caption + r"""}
            \label{fig:""" + label_name + r"""}
            \end{figure}
        """))

class _AbstractBuilder(abc.ABC):
    def __init__(self, sf, fp):
        self.graphix_collection = list()
        self.neo4j_collection = list()

        # Every builder requires a scale factor and a file pointer.
        self.scale_factor = sf
        self.file_pointer = fp

    def accept(self, system, query_class, execution_time, error, **kwargs):
        if system == 'Graphix':
            self.graphix_collection.append({
                'executionTime': execution_time,
                'queryClass': query_class,
                'clusterSize': kwargs['cluster_size'],
                'error': error
            })
        else:
            self.neo4j_collection.append({
                'executionTime': execution_time,
                'queryClass': query_class,
                'error': error
            })

    def __enter__(self):
        return self

    def __exit__(self, exc_type, exc_val, exc_tb):
        if exc_type is None and exc_val is None and exc_tb is None:
            self.build()
            print('File "' + self.file_pointer.name + '" is built!')
        else:
            print(f'Error building "' + self.file_pointer.name + '"!')
            print(f'exc_type: {exc_type}\nexc_val: {exc_val}\nexec_tb: {exc_tb}\n')

    @abc.abstractmethod
    def build(self):
        pass

class ShortPlotBuilder(_AbstractBuilder, _PlotBuilderMixin):
    HEADERS = {
        'short-1': r"\nextgroupplot[title={\footnotesize Query \codetext{IS-1}}]",
        'short-2': r"\nextgroupplot[title={\footnotesize Query \codetext{IS-2}}]",
        'short-3': r"\nextgroupplot[title={\footnotesize Query \codetext{IS-3}}]",
        'short-4': r"\nextgroupplot[title={\footnotesize Query \codetext{IS-4}}]",
        'short-5': r"\nextgroupplot[title={\footnotesize Query \codetext{IS-5}}]",
        'short-6': r"\nextgroupplot[title={\footnotesize Query \codetext{IS-6}}]",
        'short-7': r"\nextgroupplot[title={\footnotesize Query \codetext{IS-7}}]",
    }

    def build(self):
        self._write_header(self.file_pointer)
        self._write_group_start(self.file_pointer, r"""%
                    group style={%
                       group size=4 by 2,%
                       vertical sep=1.3cm,%
                       horizontal sep=1.2cm,%
                       xlabels at=edge bottom,%
                       ylabels at=edge left%
                    },%
                    ymin=0,%
                %""")
        for k, v in self.HEADERS.items():
            self.file_pointer.write(v + '\n')
            self._write_plot(
                g_collection=self.graphix_collection,
                n_collection=self.neo4j_collection,
                file_pointer=self.file_pointer,
                query_class=k,
                timeout=180
            )
        self._write_group_end(self.file_pointer)
        self._write_footer(
            file_pointer=self.file_pointer,
            short_caption=r"Plots comparing Graphix against Neo4j for the \codetext{IS-X} query suite at "
                          r"\codetext{SF=" + str(self.scale_factor) + r"}.",
            long_caption=r"Several plots showing a Graphix cluster of varying size (in blue) against a Neo4j instance "
                         r"(in green) for the \codetext{IS-X} query suite at \codetext{SF=" +
                         str(self.scale_factor) + r"}.",
            label_name="isXSF" + str(self.scale_factor)
        )

class ComplexPlotBuilder(_AbstractBuilder, _PlotBuilderMixin):
    HEADERS = {
        'complex-1': r"\nextgroupplot[title={\footnotesize Query \codetext{IC-1}}]",
        'complex-2': r"\nextgroupplot[title={\footnotesize Query \codetext{IC-2}}]",
        'complex-3a': r"\nextgroupplot[title={\footnotesize Query \codetext{IC-3a}}]",
        'complex-3b': r"\nextgroupplot[title={\footnotesize Query \codetext{IC-3b}}]",
        'complex-4': r"\nextgroupplot[title={\footnotesize Query \codetext{IC-4}}]",
        'complex-5': r"\nextgroupplot[title={\footnotesize Query \codetext{IC-5}}]",
        'complex-6': r"\nextgroupplot[title={\footnotesize Query \codetext{IC-6}}]",
        'complex-7': r"\nextgroupplot[title={\footnotesize Query \codetext{IC-7}}]",
        'complex-8': r"\nextgroupplot[title={\footnotesize Query \codetext{IC-8}}]",
        'complex-9': r"\nextgroupplot[title={\footnotesize Query \codetext{IC-9}}]",
        'complex-10': r"\nextgroupplot[title={\footnotesize Query \codetext{IC-10}}]",
        'complex-11': r"\nextgroupplot[title={\footnotesize Query \codetext{IC-11}}]",
        'complex-12': r"\nextgroupplot[title={\footnotesize Query \codetext{IC-12}}]",
        'complex-13a': r"\nextgroupplot[title={\footnotesize Query \codetext{IC-13}}]",
        'complex-14a': r"\nextgroupplot[title={\footnotesize Query \codetext{IC-14}}]",
    }

    def build(self):
        self._write_header(self.file_pointer)
        self._write_group_start(self.file_pointer, r"""%
                     group style={%
                       group size=4 by 4,%
                       vertical sep=1.3cm,%
                       horizontal sep=1.2cm,%
                       xlabels at=edge bottom,
                       ylabels at=edge left%
                     },%
                     ymin=0,%
                 %""")
        for k, v in self.HEADERS.items():
            self.file_pointer.write(v + '\n')
            self._write_plot(
                g_collection=self.graphix_collection,
                n_collection=self.neo4j_collection,
                file_pointer=self.file_pointer,
                query_class=k,
                timeout=1800
            )
        self._write_group_end(self.file_pointer)
        self._write_footer(
            file_pointer=self.file_pointer,
            short_caption=r"Plots comparing Graphix against Neo4j for the \codetext{IC-X} query suite at "
                          r"\codetext{SF=" + str(self.scale_factor) + r"}.",
            long_caption=r"Several plots showing a Graphix cluster of varying size (in blue) against a Neo4j instance "
                         r"(in green) for the \codetext{IC-X} query suite at \codetext{SF=" +
                         str(self.scale_factor) + r"}.",
            label_name="icXSF" + str(self.scale_factor)
        )

class BusinessPlotBuilder(_AbstractBuilder, _PlotBuilderMixin):
    HEADERS = {
        'bi-1': r"\nextgroupplot[title={\footnotesize Query \codetext{BI-1}}]",
        'bi-2a': r"\nextgroupplot[title={\footnotesize Query \codetext{BI-2a}}]",
        'bi-2b': r"\nextgroupplot[title={\footnotesize Query \codetext{BI-2b}}]",
        'bi-3': r"\nextgroupplot[title={\footnotesize Query \codetext{BI-3}}]",
        'bi-5': r"\nextgroupplot[title={\footnotesize Query \codetext{BI-5}}]",
        # 'bi-6': r"\nextgroupplot[title={\footnotesize Query \codetext{BI-6}}]",
        'bi-7': r"\nextgroupplot[title={\footnotesize Query \codetext{BI-7}}]",
        'bi-8a': r"\nextgroupplot[title={\footnotesize Query \codetext{BI-8a}}]",
        'bi-8b': r"\nextgroupplot[title={\footnotesize Query \codetext{BI-8b}}]",
        'bi-9': r"\nextgroupplot[title={\footnotesize Query \codetext{BI-9}}]",
        'bi-10a': r"\nextgroupplot[title={\footnotesize Query \codetext{BI-10a}}]",
        'bi-10b': r"\nextgroupplot[title={\footnotesize Query \codetext{BI-10b}}]",
        # 'bi-11': r"\nextgroupplot[title={\footnotesize Query \codetext{BI-11}}]",
        # 'bi-12': r"\nextgroupplot[title={\footnotesize Query \codetext{BI-12}}]",
        'bi-13': r"\nextgroupplot[title={\footnotesize Query \codetext{BI-13}}]",
        'bi-14a': r"\nextgroupplot[title={\footnotesize Query \codetext{BI-14a}}]",
        'bi-14b': r"\nextgroupplot[title={\footnotesize Query \codetext{BI-14b}}]",
        'bi-16a': r"\nextgroupplot[title={\footnotesize Query \codetext{BI-16a}}]",
        'bi-16b': r"\nextgroupplot[title={\footnotesize Query \codetext{BI-16b}}]",
        'bi-17': r"\nextgroupplot[title={\footnotesize Query \codetext{BI-17}}]",
        'bi-18': r"\nextgroupplot[title={\footnotesize Query \codetext{BI-18}}]",
        'bi-19a': r"\nextgroupplot[title={\footnotesize Query \codetext{BI-19a}}]",
        'bi-19b': r"\nextgroupplot[title={\footnotesize Query \codetext{BI-19b}}]",
        'bi-20a': r"\nextgroupplot[title={\footnotesize Query \codetext{BI-20a}}]",
        'bi-20b': r"\nextgroupplot[title={\footnotesize Query \codetext{BI-20b}}]",
    }

    def build(self):
        self._write_header(self.file_pointer)
        self.file_pointer.write(r'\vspace{-1em}')
        self._write_group_start(self.file_pointer, r"""%
                     group style={%
                       group size=4 by 6,%
                       vertical sep=1.3cm,%
                       horizontal sep=1.2cm,%
                       xlabels at=edge bottom,
                       ylabels at=edge left%
                     },%
                     ymin=0,%
                 %""")
        for k, v in self.HEADERS.items():
            self.file_pointer.write(v + '\n')
            self._write_plot(
                g_collection=self.graphix_collection,
                n_collection=self.neo4j_collection,
                file_pointer=self.file_pointer,
                query_class=k,
                timeout=18000
            )
        self._write_group_end(self.file_pointer)
        self._write_footer(
            file_pointer=self.file_pointer,
            short_caption=r"Plots comparing Graphix against Neo4j for the \codetext{BI-X} query suite at "
                          r"\codetext{SF=" + str(self.scale_factor) + r"}.",
            long_caption=r"Several plots showing a Graphix cluster of varying size (in blue) against a Neo4j instance "
                         r"(in green) for the \codetext{BI-X} query suite at \codetext{SF=" +
                         str(self.scale_factor) + r"}.",
            label_name="biXSF" + str(self.scale_factor)
        )

class InteractiveTableBuilder(_AbstractBuilder, _TableBuilderMixin):
    SHORT_HEADERS = {
        'short-1': r"\codetext{IS-1}",
        'short-2': r"\codetext{IS-2}",
        'short-3': r"\codetext{IS-3}",
        'short-4': r"\codetext{IS-4}",
        'short-5': r"\codetext{IS-5}",
        'short-6': r"\codetext{IS-6}",
        'short-7': r"\codetext{IS-7}",
    }

    COMPLEX_HEADERS = {
        'complex-1': r"\codetext{IC-1}",
        'complex-2': r"\codetext{IC-2}",
        'complex-3a': r"\codetext{IC-3a}",
        'complex-3b': r"\codetext{IC-3b}",
        'complex-4': r"\codetext{IC-4}",
        'complex-5': r"\codetext{IC-5}",
        'complex-6': r"\codetext{IC-6}",
        'complex-7': r"\codetext{IC-7}",
        'complex-8': r"\codetext{IC-8}",
        'complex-9': r"\codetext{IC-9}",
        'complex-10': r"\codetext{IC-10}",
        'complex-11': r"\codetext{IC-11}",
        'complex-12': r"\codetext{IC-12}",
        'complex-13a': r"\codetext{IC-13}",
        'complex-14a': r"\codetext{IC-14}",
    }

    def build(self):
        self._write_header(self.file_pointer)
        for j, d in enumerate([self.SHORT_HEADERS, self.COMPLEX_HEADERS]):
            for h in d.keys():
                self.file_pointer.write(d[h] + ' & ')
                self._write_row(
                    file_pointer=self.file_pointer,
                    g_collection=self.graphix_collection,
                    n_collection=self.neo4j_collection,
                    query_class=h,
                    timeout=(r'\SI{3}{\minute}' if j == 0 else r'\SI{30}{\minute}')
                )
            if j == 0:
                self.file_pointer.write(r'\midrule' + '\n')
        self._write_footer(
            file_pointer=self.file_pointer,
            short_caption=r"Graphix vs.\ Neo4j: LDBC SNB \codetext{IS-X} and \codetext{IC-X} results for "
                          r"\codetext{SF=" + str(self.scale_factor) + r"}.",
            long_caption=r"Table comparing the median execution times of \codetext{IS-X} and \codetext{IC-X} "
                         r"queries at scale factor \codetext{SF=" + str(self.scale_factor) +
                         r"} for Neo4j and different Graphix cluster configurations.",
            label_name="itXSF" + str(self.scale_factor)
        )

class BusinessTableBuilder(_AbstractBuilder, _TableBuilderMixin):
    BI_HEADERS = {
        'bi-1': r"\codetext{BI-1}",
        'bi-2a': r"\codetext{BI-2a}",
        'bi-2b': r"\codetext{BI-2b}",
        'bi-3': r"\codetext{BI-3}",
        'bi-5': r"\codetext{BI-5}",
        'bi-6': r"\codetext{BI-6}",
        'bi-7': r"\codetext{BI-7}",
        'bi-8a': r"\codetext{BI-8a}",
        'bi-8b': r"\codetext{BI-8b}",
        'bi-9': r"\codetext{BI-9}",
        'bi-10a': r"\codetext{BI-10a}",
        'bi-10b': r"\codetext{BI-10b}",
        'bi-11': r"\codetext{BI-11}",
        'bi-12': r"\codetext{BI-12}",
        'bi-13': r"\codetext{BI-13}",
        'bi-14a': r"\codetext{BI-14a}",
        'bi-14b': r"\codetext{BI-14b}",
        'bi-16a': r"\codetext{BI-16a}",
        'bi-16b': r"\codetext{BI-16b}",
        'bi-17': r"\codetext{BI-17}",
        'bi-18': r"\codetext{BI-18}",
        'bi-19a': r"\codetext{BI-19a}",
        'bi-19b': r"\codetext{BI-19b}",
        'bi-20a': r"\codetext{BI-20a}",
        'bi-20b': r"\codetext{BI-20b}",
    }

    def build(self):
        self._write_header(self.file_pointer)
        for k, v in self.BI_HEADERS.items():
            self.file_pointer.write(v + ' & ')
            self._write_row(
                file_pointer=self.file_pointer,
                g_collection=self.graphix_collection,
                n_collection=self.neo4j_collection,
                query_class=k,
                timeout=r'\SI{5}{\hour}'
            )
        self._write_footer(
            file_pointer=self.file_pointer,
            short_caption=r"Graphix vs.\ Neo4j: LDBC SNB \codetext{BI-X} results for "
                          r"\codetext{SF=" + str(self.scale_factor) + r"}.",
            long_caption=r"Table comparing the median execution times of \codetext{BI-X} queries at scale factor "
                         r"\codetext{SF=" + str(self.scale_factor) +
                         r"} for Neo4j and different Graphix cluster configurations.",
            label_name="biXSF" + str(self.scale_factor)
        )
