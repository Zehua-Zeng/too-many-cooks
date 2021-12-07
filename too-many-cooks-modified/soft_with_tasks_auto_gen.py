tasks = [
    "retrieve-value",
    "filter",
    "compute-derived-value",
    "find-extremum",
    "find-maximum",
    "find-minimum",
    "sort",
    "compare-objects",
    "determine-range",
    "characterize-distribution",
    "find-anomalies",
    "cluster",
    "detect-number-of-clusters",
    "correlate",
    "detect-correlation",
    "estimate-correlation",
    "compare-derived-values",
    "detect-presence",
    "estimate-trend",
    "estimate-difference",
    "locate",
    "recognize",
    "explore-adjacency",
    "judge-similarity",
    "compare-chart-structure"
]

marks = [
    "point",
    "bar",
    "line",
    "area",
    "text",
    "tick",
    "rect"
]

continuous_channels = [
    "x",
    "y",
    "color",
    "size",
    "text",
    "radius",
    "theta"
]

discrete_channels = [
    "x",
    "y",
    "color",
    "shape",
    "size",
    "text",
    "row",
    "column"
]

### auto generate soft constraints

results = []

## task - marktype correlations

for task in tasks:
    for mark in marks:
        results.append("soft(" + task + "_" + mark + ") :- task(" + task + "), mark(" + mark + ").")

## task - channel correlations

for task in tasks:
    for cc in continuous_channels:
        results.append("soft(" + task + "_continuous_" + cc + ",E) :- task(" + task + "), channel(E," + cc + "), continuous(E), enc_interesting(E).")
    for dc in discrete_channels:
        results.append("soft(" + task + "_discrete_" + dc + ",E) :- task(" + task + "), channel(E," + dc + "), discrete(E), enc_interesting(E).")

fw = open("./too-many-cooks-modified/soft_with_tasks.lp", "w")
fw.write("\n".join(results))
