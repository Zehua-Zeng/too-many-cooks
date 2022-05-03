tasks = [
    "retrieve_value",
    "filter",
    "compute_derived_value",
    "find_extremum",
    "find_maximum",
    "find_minimum",
    "sort",
    "compare_objects",
    "determine_range",
    "characterize_distribution",
    "find_anomalies",
    "cluster",
    "detect_number_of_clusters",
    "correlate",
    "detect_correlation",
    "estimate_correlation",
    "compare_derived_values",
    "detect_presence",
    "estimate_trend",
    "estimate_difference",
    "locate",
    "recognize",
    "explore_adjacency",
    "judge_similarity",
    "compare_chart_structure",
    "overall"
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

# results = []

# ## task - marktype correlations

# for task in tasks:
#     for mark in marks:
#         results.append("soft(" + task + "_" + mark + ") :- task(" + task + "), mark(" + mark + ").")

# ## task - channel correlations

# for task in tasks:
#     for cc in continuous_channels:
#         results.append("soft(" + task + "_continuous_" + cc + ",E) :- task(" + task + "), channel(E," + cc + "), continuous(E), enc_interesting(E).")
#     for dc in discrete_channels:
#         results.append("soft(" + task + "_discrete_" + dc + ",E) :- task(" + task + "), channel(E," + dc + "), discrete(E), enc_interesting(E).")

# fw = open("./too-many-cooks-modified/soft_with_tasks.lp", "w")
# fw.write("\n".join(results))


### auto generate task weights

results = []

## task - marktype correlations

for task in tasks:
    for mark in marks:
        results.append("#const " + task + "_" + mark + "_weight = 0.")

## task - channel correlations

for task in tasks:
    for cc in continuous_channels:
        results.append("#const " + task + "_continuous_" + cc + "_weight = 0.")
    for dc in discrete_channels:
        results.append("#const " + task + "_discrete_" + dc + "_weight = 0.")

fw = open("./too-many-cooks-modified/weight_with_tasks.lp", "w")
fw.write("\n".join(results))