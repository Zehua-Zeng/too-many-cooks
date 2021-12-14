% After adding a soft constraint to this file, make sure to update `weights.lp` and run `process_softs.py`..

% ====== Preferences ======

% @constraint Prefer to use raw (no aggregate).
soft(aggregate,E) :- aggregate(E,_).

% @constraint Prefer to not bin.
soft(bin,E) :- bin(E,_).

% @constraint Prefer binning with at most 12 buckets.
soft(bin_high,E) :- bin(E,B), B > 12.

% @constraint Prefer binning with more than 7 buckets.
soft(bin_low,E) :- bin(E,B), B <= 7.

% @constraint Prefer to use fewer encodings.
soft(encoding,E) :- encoding(E).

% @constraint Prefer to use fewer encodings with fields (count does not have a field).
soft(encoding_field,E) :- encoding(E), field(E,_).

% @constraint Prefer not to use the same field twice.
soft(same_field_2,F) :- field(F), { field(_,F) } = 2.

% @constraint Prefer not to use the same field three or more times.
% @weight {16}
soft(same_field_gte3,F) :- field(F), { field(_,F) } >= 3.
% @end

% @constraint Prefer not to use count more than once.
soft(count_twice) :- { aggregate(_,count) } = 2.

% @constraint Shape channel should not have too high cardinality.
soft(shape_cardinality,E) :- channel(E,shape), discrete_cardinality(E,C), C > 5.

% @constraint Numbers should not be nominal.
soft(number_nominal,E) :- type(E,nominal), field(E,F), fieldtype(F,number).

% @constraint Binned quantitative field should not have too low cardinality.
soft(bin_cardinality,E) :- type(E,quantitative), bin(E,_), enc_cardinality(E,C), C < 15.

% @constraint Prefer quantitative for bin.
soft(quant_bin,E) :- bin(E,_), not type(E,quantitative).

% @constraint Plots with only nominal, ordinal, binned q, or t with time unit should add either an aggregation (e.g. count) or a quantitative field.
soft(only_discrete) :- not continuous(_).

% @constraint Prefer not to use multiple non-positional encoding channels.
soft(multiple_non_pos) :- {channel(_,C): non_positional(C)} > 1.

% @constraint Prefer not to use non-positional channels until all positional channels are used.
soft(non_positional_pref) :- channel(_,C), non_positional(C), not channel(_,(x;y)).

% @constraint Aggregate plots should not use raw continuous as group by.
soft(aggregate_group_by_raw,E) :- aggregate(_,_), continuous(E), not aggregate(E,_).

% @constraint Aggregate should also have a discrete encoding to group by.
soft(agg_dim) :- aggregate(_,_), not discrete(_).

% @constraint Prefer not to use plot with both x and y discrete and no aggregate as it leads to occlusion.
soft(x_y_raw,E) :- channel(EX,x), discrete(EX), channel(EY,y), discrete(EY), not aggregate(E,_), continuous(E).

% @constraint Prefer not to use log scale.
soft(log,E) :- log(E).

% @constraint Prefer to include zero for continuous (binned doesn't need zero).
soft(zero,E) :- continuous(E), not zero(E).

% @constraint Prefer zero size (even when binned).
soft(zero_size) :- channel(E,size), not zero(E).

% @constraint Prefer zero positional.
soft(zero_positional) :- continuous(E), channel(E,(x;y)), not zero(E).

% @constraint Prefer not to use zero when the difference between min and max is larger than distance to 0.
soft(zero_skew) :- enc_extent(E,MIN,MAX), EX = MAX - MIN, |MAX| > EX, |MIN| > EX, zero(E).

% @constraint Do not include zero when the range of data includes zero.
soft(includes_zero) :- zero(E), extent(E,MIN,MAX), MIN < 0, MAX > 0.

% @constraint Prefer to use only x instead of only y.
soft(only_x) :- channel(_,y), not channel(_,x).

% @constraint Chart orientation for bar and tick (with and without bin). Binned fields have short labels if they are quantitative while otherwise labels can be long.
soft(orientation_binned) :- bin(E,_), type(E,quantitative), not channel(E,x).

% @constraint Prefer not to use ordinal for fields with high cardinality.
soft(high_cardinality_ordinal,E) :- type(E,ordinal), discrete_cardinality(E,C), C > 30.

% @constraint Prefer not to use nominal for fields with high cardinality.
soft(high_cardinality_nominal,E) :- type(E,nominal), enc_cardinality(E,C), C > 12.

% @constraint Prefer not to use high cardinality nominal for color.
soft(high_cardinality_nominal_color,E) :- type(E,nominal), channel(E,color), enc_cardinality(E,C), C > 10.

% @constraint Avoid high cardinality on x or column as it causes horizontal scrolling.
soft(horizontal_scrolling,E) :- channel(E,x), discrete_cardinality(E,C), C > 50.
soft(horizontal_scrolling,E) :- channel(E,columm), discrete_cardinality(E,C), C > 5.

% @constraint Prefer to use temporal type with dates.
soft(temporal_date,E) :- field(E,F), fieldtype(F,datetime), not type(E,temporal).

% @constraint Prefer quantitative for numbers with high cardinality.
soft(quantitative_numbers) :- field(E,F), fieldtype(F,number), cardinality(F,C), C > 20, not bin(E,_), not type(E,quantitative).

% @constraint Overplotting. Prefer not to use x and y for continuous with high cardinality and low entropy without aggregation because the points will overplot.
soft(position_entropy,E) :- channel(E,(x;y)), continuous(E), enc_cardinality(E,C), C > 100, enc_entropy(E,EN), EN <= 12, not aggregate(E,_).

% @constraint Prefer not to use size when the cardinality is large on x or y.
soft(high_cardinality_size,E) :- continuous(E), channel(_,size), enc_cardinality(E,C), C > 100, channel(E,(x;y)).

% @constraint Positional interactions as suggested by Kim et al.
soft(x_row) :- channel(_,x), channel(_,row).

% @constraint Positional interactions as suggested by Kim et al.
soft(y_row) :- channel(_,y), channel(_,row).

% @constraint Positional interactions as suggested by Kim et al.
soft(x_column) :- channel(_,x), channel(_,column).

% @constraint Positional interactions as suggested by Kim et al.
soft(y_column) :- channel(_,y), channel(_,column).

% @constraint Entropy, primary quantitaty interactions as suggested by Kim et al.
soft(color_entropy_high, E) :- channel(E,color), enc_entropy(E,EN), EN > 12, type(E,quantitative), enc_interesting(E).

% @constraint Entropy, primary quantitaty interactions as suggested by Kim et al.
soft(color_entropy_low, E) :- channel(E,color), enc_entropy(E,EN), EN <= 12, type(E,quantitative), enc_interesting(E).

% @constraint Entropy, primary quantitaty interactions as suggested by Kim et al.
soft(size_entropy_high, E) :- channel(E,size), enc_entropy(E,EN), EN > 12, type(E,quantitative), enc_interesting(E).

% @constraint Entropy, primary quantitaty interactions as suggested by Kim et al.
soft(size_entropy_low, E) :- channel(E,size), enc_entropy(E,EN), EN <= 12, type(E,quantitative), enc_interesting(E).

% @constraint Prefer not to use continuous on x, discrete on y, and column.
soft(c_d_column) :- channel_continuous(x), channel_discrete(y), channel(_,column).

% @constraint Prefer time on x.
soft(temporal_y) :- type(E,temporal), not channel(E,x).

% @constraint Prefer not to overlap with DxD.
soft(d_d_overlap) :- is_d_d, overlap.

% ====== Rankings ======
% === Data Types ===

% @constraint Prefer quantitative > ordinal > nominal.
soft(type_q,E) :- type(E,quantitative).

% @constraint Prefer quantitative > ordinal > nominal.
soft(type_o,E) :- type(E,ordinal).

% @constraint Prefer quantitative > ordinal > nominal.
soft(type_n,E) :- type(E,nominal).

% === Mark types ===

% @constraint Continuous by continuous for point mark.
soft(c_c_point) :- is_c_c, mark(point).

% @constraint Continuous by continuous for line mark.
soft(c_c_line) :- is_c_c, mark(line).

% @constraint Continuous by continuous for area mark.
soft(c_c_area) :- is_c_c, mark(area).

% @constraint Continuous by continuous for text mark.
soft(c_c_text) :- is_c_c, mark(text).

% @constraint Continuous by continuous for tick mark.
soft(c_c_tick) :- is_c_c, mark(tick).

% @constraint Continuous by discrete for point mark.
soft(c_d_point) :- is_c_d, not no_overlap, mark(point).

% @constraint Continuous by discrete for bar mark.
soft(c_d_bar) :- is_c_d, not no_overlap, mark(bar).

% @constraint Continuous by discrete for line mark.
soft(c_d_line) :- is_c_d, not no_overlap, mark(line).

% @constraint Continuous by discrete for area mark.
soft(c_d_area) :- is_c_d, not no_overlap, mark(area).

% @constraint Continuous by discrete for text mark.
soft(c_d_text) :- is_c_d, not no_overlap, mark(text).

% @constraint Continuous by discrete for tick mark.
soft(c_d_tick) :- is_c_d, not no_overlap, mark(tick).

% @constraint Continuous by discrete for point mark with no overlap.
soft(c_d_no_overlap_point) :- is_c_d, no_overlap, mark(point).

% @constraint Continuous by discrete for bar mark with no overlap.
soft(c_d_no_overlap_bar) :- is_c_d, no_overlap, mark(bar).

% @constraint Continuous by discrete for line mark with no overlap.
soft(c_d_no_overlap_line) :- is_c_d, no_overlap, mark(line).

% @constraint Continuous by discrete for area mark with no overlap.
soft(c_d_no_overlap_area) :- is_c_d, no_overlap, mark(area).

% @constraint Continuous by discrete for text mark with no overlap.
soft(c_d_no_overlap_text) :- is_c_d, no_overlap, mark(text).

% @constraint Continuous by discrete for tick mark with no overlap.
soft(c_d_no_overlap_tick) :- is_c_d, no_overlap, mark(tick).

% @constraint Discrete by discrete for point mark.
soft(d_d_point) :- is_d_d, mark(point).

% @constraint Discrete by discrete for point mark.
soft(d_d_text) :- is_d_d, mark(text).

% @constraint Discrete by discrete for point mark.
soft(d_d_rect) :- is_d_d, mark(rect).

% === Channel rankings à la APT ===

% @constraint Continuous on x channel.
soft(continuous_x,E) :- channel(E,x), continuous(E).

% @constraint Continuous on y channel.
soft(continuous_y,E) :- channel(E,y), continuous(E).

% @constraint Continuous on color channel.
soft(continuous_color,E) :- channel(E,color), continuous(E).

% @constraint Continuous on size channel.
soft(continuous_size,E) :- channel(E,size), continuous(E).

% @constraint Continuous on text channel.
soft(continuous_text,E) :- channel(E,text), continuous(E).

% @constraint Ordered on x channel.
soft(ordered_x,E) :- channel(E,x), discrete(E), not type(E,nominal).

% @constraint Ordered on y channel.
soft(ordered_y,E) :- channel(E,y), discrete(E), not type(E,nominal).

% @constraint Ordered on color channel.
soft(ordered_color,E) :- channel(E,color), discrete(E), not type(E,nominal).

% @constraint Ordered on size channel.
soft(ordered_size,E) :- channel(E,size), discrete(E), not type(E,nominal).

% @constraint Ordered on text channel.
soft(ordered_text,E) :- channel(E,text), discrete(E), not type(E,nominal).

% @constraint Ordered on row channel.
soft(ordered_row,E) :- channel(E,row), discrete(E), not type(E,nominal).

% @constraint Ordered on column channel.
soft(ordered_column,E) :- channel(E,column), discrete(E), not type(E,nominal).

% @constraint Nominal on x channel.
soft(nominal_x,E) :- channel(E,x), type(E,nominal).

% @constraint Nominal on y channel.
soft(nominal_y,E) :- channel(E,y), type(E,nominal).

% @constraint Nominal on color channel.
soft(nominal_color,E) :- channel(E,color), type(E,nominal).

% @constraint Nominal on shape channel.
soft(nominal_shape,E) :- channel(E,shape), type(E,nominal).

% @constraint Nominal on text channel.
soft(nominal_text,E) :- channel(E,text), type(E,nominal).

% @constraint Nominal on row channel.
soft(nominal_row,E) :- channel(E,row), type(E,nominal).

% @constraint Nominal on column channel.
soft(nominal_column,E) :- channel(E,column), type(E,nominal).

% @constraint Nominal on detail channel.
soft(nominal_detail,E) :- channel(E,detail), type(E,nominal).

% @constraint Interesting on x channel.
soft(interesting_x,E) :- channel(E,x), enc_interesting(E).

% @constraint Interesting on y channel.
soft(interesting_y,E) :- channel(E,y), enc_interesting(E).

% @constraint Interesting on color channel.
soft(interesting_color,E) :- channel(E,color), enc_interesting(E).

% @constraint Interesting on size channel.
soft(interesting_size,E) :- channel(E,size), enc_interesting(E).

% @constraint Interesting on shape channel.
soft(interesting_shape,E) :- channel(E,shape), enc_interesting(E).

% @constraint Interesting on text channel.
soft(interesting_text,E) :- channel(E,text), enc_interesting(E).

% @constraint Interesting on row channel.
soft(interesting_row,E) :- channel(E,row), enc_interesting(E).

% @constraint Interesting on column channel.
soft(interesting_column,E) :- channel(E,column), enc_interesting(E).

% @constraint Interesting on detail channel.
soft(interesting_detail,E) :- channel(E,detail), enc_interesting(E).

% === Aggregations ===

% @constraint Count as aggregate op.
soft(aggregate_count,E) :- aggregate(E,count).

% @constraint Sum as aggregate op.
soft(aggregate_sum,E) :- aggregate(E,sum).

% @constraint Mean as aggregate op.
soft(aggregate_mean,E) :- aggregate(E,mean).

% @constraint Median as aggregate op.
soft(aggregate_median,E) :- aggregate(E,median).

% @constraint Min as aggregate op.
soft(aggregate_min,E) :- aggregate(E,min).

% @constraint Max as aggregate op.
soft(aggregate_max,E) :- aggregate(E,max).

% @constraint Standard Deviation as aggregate op.
soft(aggregate_stdev,E) :- aggregate(E,stdev).

% === Stack ===

% @constraint Zero base for stack op.
soft(stack_zero) :- stack(zero).

% @constraint Normalize between groupbys as stack op.
soft(stack_normalize) :- stack(normalize).

% === Tasks ===

soft(retrieve_value_point) :- task(retrieve_value), mark(point).
soft(retrieve_value_bar) :- task(retrieve_value), mark(bar).
soft(retrieve_value_line) :- task(retrieve_value), mark(line).
soft(retrieve_value_area) :- task(retrieve_value), mark(area).
soft(retrieve_value_text) :- task(retrieve_value), mark(text).
soft(retrieve_value_tick) :- task(retrieve_value), mark(tick).
soft(retrieve_value_rect) :- task(retrieve_value), mark(rect).
soft(filter_point) :- task(filter), mark(point).
soft(filter_bar) :- task(filter), mark(bar).
soft(filter_line) :- task(filter), mark(line).
soft(filter_area) :- task(filter), mark(area).
soft(filter_text) :- task(filter), mark(text).
soft(filter_tick) :- task(filter), mark(tick).
soft(filter_rect) :- task(filter), mark(rect).
soft(compute_derived_value_point) :- task(compute_derived_value), mark(point).
soft(compute_derived_value_bar) :- task(compute_derived_value), mark(bar).
soft(compute_derived_value_line) :- task(compute_derived_value), mark(line).
soft(compute_derived_value_area) :- task(compute_derived_value), mark(area).
soft(compute_derived_value_text) :- task(compute_derived_value), mark(text).
soft(compute_derived_value_tick) :- task(compute_derived_value), mark(tick).
soft(compute_derived_value_rect) :- task(compute_derived_value), mark(rect).
soft(find_extremum_point) :- task(find_extremum), mark(point).
soft(find_extremum_bar) :- task(find_extremum), mark(bar).
soft(find_extremum_line) :- task(find_extremum), mark(line).
soft(find_extremum_area) :- task(find_extremum), mark(area).
soft(find_extremum_text) :- task(find_extremum), mark(text).
soft(find_extremum_tick) :- task(find_extremum), mark(tick).
soft(find_extremum_rect) :- task(find_extremum), mark(rect).
soft(find_maximum_point) :- task(find_maximum), mark(point).
soft(find_maximum_bar) :- task(find_maximum), mark(bar).
soft(find_maximum_line) :- task(find_maximum), mark(line).
soft(find_maximum_area) :- task(find_maximum), mark(area).
soft(find_maximum_text) :- task(find_maximum), mark(text).
soft(find_maximum_tick) :- task(find_maximum), mark(tick).
soft(find_maximum_rect) :- task(find_maximum), mark(rect).
soft(find_minimum_point) :- task(find_minimum), mark(point).
soft(find_minimum_bar) :- task(find_minimum), mark(bar).
soft(find_minimum_line) :- task(find_minimum), mark(line).
soft(find_minimum_area) :- task(find_minimum), mark(area).
soft(find_minimum_text) :- task(find_minimum), mark(text).
soft(find_minimum_tick) :- task(find_minimum), mark(tick).
soft(find_minimum_rect) :- task(find_minimum), mark(rect).
soft(sort_point) :- task(sort), mark(point).
soft(sort_bar) :- task(sort), mark(bar).
soft(sort_line) :- task(sort), mark(line).
soft(sort_area) :- task(sort), mark(area).
soft(sort_text) :- task(sort), mark(text).
soft(sort_tick) :- task(sort), mark(tick).
soft(sort_rect) :- task(sort), mark(rect).
soft(compare_objects_point) :- task(compare_objects), mark(point).
soft(compare_objects_bar) :- task(compare_objects), mark(bar).
soft(compare_objects_line) :- task(compare_objects), mark(line).
soft(compare_objects_area) :- task(compare_objects), mark(area).
soft(compare_objects_text) :- task(compare_objects), mark(text).
soft(compare_objects_tick) :- task(compare_objects), mark(tick).
soft(compare_objects_rect) :- task(compare_objects), mark(rect).
soft(determine_range_point) :- task(determine_range), mark(point).
soft(determine_range_bar) :- task(determine_range), mark(bar).
soft(determine_range_line) :- task(determine_range), mark(line).
soft(determine_range_area) :- task(determine_range), mark(area).
soft(determine_range_text) :- task(determine_range), mark(text).
soft(determine_range_tick) :- task(determine_range), mark(tick).
soft(determine_range_rect) :- task(determine_range), mark(rect).
soft(characterize_distribution_point) :- task(characterize_distribution), mark(point).
soft(characterize_distribution_bar) :- task(characterize_distribution), mark(bar).
soft(characterize_distribution_line) :- task(characterize_distribution), mark(line).
soft(characterize_distribution_area) :- task(characterize_distribution), mark(area).
soft(characterize_distribution_text) :- task(characterize_distribution), mark(text).
soft(characterize_distribution_tick) :- task(characterize_distribution), mark(tick).
soft(characterize_distribution_rect) :- task(characterize_distribution), mark(rect).
soft(find_anomalies_point) :- task(find_anomalies), mark(point).
soft(find_anomalies_bar) :- task(find_anomalies), mark(bar).
soft(find_anomalies_line) :- task(find_anomalies), mark(line).
soft(find_anomalies_area) :- task(find_anomalies), mark(area).
soft(find_anomalies_text) :- task(find_anomalies), mark(text).
soft(find_anomalies_tick) :- task(find_anomalies), mark(tick).
soft(find_anomalies_rect) :- task(find_anomalies), mark(rect).
soft(cluster_point) :- task(cluster), mark(point).
soft(cluster_bar) :- task(cluster), mark(bar).
soft(cluster_line) :- task(cluster), mark(line).
soft(cluster_area) :- task(cluster), mark(area).
soft(cluster_text) :- task(cluster), mark(text).
soft(cluster_tick) :- task(cluster), mark(tick).
soft(cluster_rect) :- task(cluster), mark(rect).
soft(detect_number_of_clusters_point) :- task(detect_number_of_clusters), mark(point).
soft(detect_number_of_clusters_bar) :- task(detect_number_of_clusters), mark(bar).
soft(detect_number_of_clusters_line) :- task(detect_number_of_clusters), mark(line).
soft(detect_number_of_clusters_area) :- task(detect_number_of_clusters), mark(area).
soft(detect_number_of_clusters_text) :- task(detect_number_of_clusters), mark(text).
soft(detect_number_of_clusters_tick) :- task(detect_number_of_clusters), mark(tick).
soft(detect_number_of_clusters_rect) :- task(detect_number_of_clusters), mark(rect).
soft(correlate_point) :- task(correlate), mark(point).
soft(correlate_bar) :- task(correlate), mark(bar).
soft(correlate_line) :- task(correlate), mark(line).
soft(correlate_area) :- task(correlate), mark(area).
soft(correlate_text) :- task(correlate), mark(text).
soft(correlate_tick) :- task(correlate), mark(tick).
soft(correlate_rect) :- task(correlate), mark(rect).
soft(detect_correlation_point) :- task(detect_correlation), mark(point).
soft(detect_correlation_bar) :- task(detect_correlation), mark(bar).
soft(detect_correlation_line) :- task(detect_correlation), mark(line).
soft(detect_correlation_area) :- task(detect_correlation), mark(area).
soft(detect_correlation_text) :- task(detect_correlation), mark(text).
soft(detect_correlation_tick) :- task(detect_correlation), mark(tick).
soft(detect_correlation_rect) :- task(detect_correlation), mark(rect).
soft(estimate_correlation_point) :- task(estimate_correlation), mark(point).
soft(estimate_correlation_bar) :- task(estimate_correlation), mark(bar).
soft(estimate_correlation_line) :- task(estimate_correlation), mark(line).
soft(estimate_correlation_area) :- task(estimate_correlation), mark(area).
soft(estimate_correlation_text) :- task(estimate_correlation), mark(text).
soft(estimate_correlation_tick) :- task(estimate_correlation), mark(tick).
soft(estimate_correlation_rect) :- task(estimate_correlation), mark(rect).
soft(compare_derived_values_point) :- task(compare_derived_values), mark(point).
soft(compare_derived_values_bar) :- task(compare_derived_values), mark(bar).
soft(compare_derived_values_line) :- task(compare_derived_values), mark(line).
soft(compare_derived_values_area) :- task(compare_derived_values), mark(area).
soft(compare_derived_values_text) :- task(compare_derived_values), mark(text).
soft(compare_derived_values_tick) :- task(compare_derived_values), mark(tick).
soft(compare_derived_values_rect) :- task(compare_derived_values), mark(rect).
soft(detect_presence_point) :- task(detect_presence), mark(point).
soft(detect_presence_bar) :- task(detect_presence), mark(bar).
soft(detect_presence_line) :- task(detect_presence), mark(line).
soft(detect_presence_area) :- task(detect_presence), mark(area).
soft(detect_presence_text) :- task(detect_presence), mark(text).
soft(detect_presence_tick) :- task(detect_presence), mark(tick).
soft(detect_presence_rect) :- task(detect_presence), mark(rect).
soft(estimate_trend_point) :- task(estimate_trend), mark(point).
soft(estimate_trend_bar) :- task(estimate_trend), mark(bar).
soft(estimate_trend_line) :- task(estimate_trend), mark(line).
soft(estimate_trend_area) :- task(estimate_trend), mark(area).
soft(estimate_trend_text) :- task(estimate_trend), mark(text).
soft(estimate_trend_tick) :- task(estimate_trend), mark(tick).
soft(estimate_trend_rect) :- task(estimate_trend), mark(rect).
soft(estimate_difference_point) :- task(estimate_difference), mark(point).
soft(estimate_difference_bar) :- task(estimate_difference), mark(bar).
soft(estimate_difference_line) :- task(estimate_difference), mark(line).
soft(estimate_difference_area) :- task(estimate_difference), mark(area).
soft(estimate_difference_text) :- task(estimate_difference), mark(text).
soft(estimate_difference_tick) :- task(estimate_difference), mark(tick).
soft(estimate_difference_rect) :- task(estimate_difference), mark(rect).
soft(locate_point) :- task(locate), mark(point).
soft(locate_bar) :- task(locate), mark(bar).
soft(locate_line) :- task(locate), mark(line).
soft(locate_area) :- task(locate), mark(area).
soft(locate_text) :- task(locate), mark(text).
soft(locate_tick) :- task(locate), mark(tick).
soft(locate_rect) :- task(locate), mark(rect).
soft(recognize_point) :- task(recognize), mark(point).
soft(recognize_bar) :- task(recognize), mark(bar).
soft(recognize_line) :- task(recognize), mark(line).
soft(recognize_area) :- task(recognize), mark(area).
soft(recognize_text) :- task(recognize), mark(text).
soft(recognize_tick) :- task(recognize), mark(tick).
soft(recognize_rect) :- task(recognize), mark(rect).
soft(explore_adjacency_point) :- task(explore_adjacency), mark(point).
soft(explore_adjacency_bar) :- task(explore_adjacency), mark(bar).
soft(explore_adjacency_line) :- task(explore_adjacency), mark(line).
soft(explore_adjacency_area) :- task(explore_adjacency), mark(area).
soft(explore_adjacency_text) :- task(explore_adjacency), mark(text).
soft(explore_adjacency_tick) :- task(explore_adjacency), mark(tick).
soft(explore_adjacency_rect) :- task(explore_adjacency), mark(rect).
soft(judge_similarity_point) :- task(judge_similarity), mark(point).
soft(judge_similarity_bar) :- task(judge_similarity), mark(bar).
soft(judge_similarity_line) :- task(judge_similarity), mark(line).
soft(judge_similarity_area) :- task(judge_similarity), mark(area).
soft(judge_similarity_text) :- task(judge_similarity), mark(text).
soft(judge_similarity_tick) :- task(judge_similarity), mark(tick).
soft(judge_similarity_rect) :- task(judge_similarity), mark(rect).
soft(compare_chart_structure_point) :- task(compare_chart_structure), mark(point).
soft(compare_chart_structure_bar) :- task(compare_chart_structure), mark(bar).
soft(compare_chart_structure_line) :- task(compare_chart_structure), mark(line).
soft(compare_chart_structure_area) :- task(compare_chart_structure), mark(area).
soft(compare_chart_structure_text) :- task(compare_chart_structure), mark(text).
soft(compare_chart_structure_tick) :- task(compare_chart_structure), mark(tick).
soft(compare_chart_structure_rect) :- task(compare_chart_structure), mark(rect).
soft(overall_point) :- task(overall), mark(point).
soft(overall_bar) :- task(overall), mark(bar).
soft(overall_line) :- task(overall), mark(line).
soft(overall_area) :- task(overall), mark(area).
soft(overall_text) :- task(overall), mark(text).
soft(overall_tick) :- task(overall), mark(tick).
soft(overall_rect) :- task(overall), mark(rect).
soft(retrieve_value_continuous_x,E) :- task(retrieve_value), channel(E,x), continuous(E), enc_interesting(E).
soft(retrieve_value_continuous_y,E) :- task(retrieve_value), channel(E,y), continuous(E), enc_interesting(E).
soft(retrieve_value_continuous_color,E) :- task(retrieve_value), channel(E,color), continuous(E), enc_interesting(E).
soft(retrieve_value_continuous_size,E) :- task(retrieve_value), channel(E,size), continuous(E), enc_interesting(E).
soft(retrieve_value_continuous_text,E) :- task(retrieve_value), channel(E,text), continuous(E), enc_interesting(E).
soft(retrieve_value_continuous_radius,E) :- task(retrieve_value), channel(E,radius), continuous(E), enc_interesting(E).
soft(retrieve_value_continuous_theta,E) :- task(retrieve_value), channel(E,theta), continuous(E), enc_interesting(E).
soft(retrieve_value_discrete_x,E) :- task(retrieve_value), channel(E,x), discrete(E), enc_interesting(E).
soft(retrieve_value_discrete_y,E) :- task(retrieve_value), channel(E,y), discrete(E), enc_interesting(E).
soft(retrieve_value_discrete_color,E) :- task(retrieve_value), channel(E,color), discrete(E), enc_interesting(E).
soft(retrieve_value_discrete_shape,E) :- task(retrieve_value), channel(E,shape), discrete(E), enc_interesting(E).
soft(retrieve_value_discrete_size,E) :- task(retrieve_value), channel(E,size), discrete(E), enc_interesting(E).
soft(retrieve_value_discrete_text,E) :- task(retrieve_value), channel(E,text), discrete(E), enc_interesting(E).
soft(retrieve_value_discrete_row,E) :- task(retrieve_value), channel(E,row), discrete(E), enc_interesting(E).
soft(retrieve_value_discrete_column,E) :- task(retrieve_value), channel(E,column), discrete(E), enc_interesting(E).
soft(filter_continuous_x,E) :- task(filter), channel(E,x), continuous(E), enc_interesting(E).
soft(filter_continuous_y,E) :- task(filter), channel(E,y), continuous(E), enc_interesting(E).
soft(filter_continuous_color,E) :- task(filter), channel(E,color), continuous(E), enc_interesting(E).
soft(filter_continuous_size,E) :- task(filter), channel(E,size), continuous(E), enc_interesting(E).
soft(filter_continuous_text,E) :- task(filter), channel(E,text), continuous(E), enc_interesting(E).
soft(filter_continuous_radius,E) :- task(filter), channel(E,radius), continuous(E), enc_interesting(E).
soft(filter_continuous_theta,E) :- task(filter), channel(E,theta), continuous(E), enc_interesting(E).
soft(filter_discrete_x,E) :- task(filter), channel(E,x), discrete(E), enc_interesting(E).
soft(filter_discrete_y,E) :- task(filter), channel(E,y), discrete(E), enc_interesting(E).
soft(filter_discrete_color,E) :- task(filter), channel(E,color), discrete(E), enc_interesting(E).
soft(filter_discrete_shape,E) :- task(filter), channel(E,shape), discrete(E), enc_interesting(E).
soft(filter_discrete_size,E) :- task(filter), channel(E,size), discrete(E), enc_interesting(E).
soft(filter_discrete_text,E) :- task(filter), channel(E,text), discrete(E), enc_interesting(E).
soft(filter_discrete_row,E) :- task(filter), channel(E,row), discrete(E), enc_interesting(E).
soft(filter_discrete_column,E) :- task(filter), channel(E,column), discrete(E), enc_interesting(E).
soft(compute_derived_value_continuous_x,E) :- task(compute_derived_value), channel(E,x), continuous(E), enc_interesting(E).
soft(compute_derived_value_continuous_y,E) :- task(compute_derived_value), channel(E,y), continuous(E), enc_interesting(E).
soft(compute_derived_value_continuous_color,E) :- task(compute_derived_value), channel(E,color), continuous(E), enc_interesting(E).
soft(compute_derived_value_continuous_size,E) :- task(compute_derived_value), channel(E,size), continuous(E), enc_interesting(E).
soft(compute_derived_value_continuous_text,E) :- task(compute_derived_value), channel(E,text), continuous(E), enc_interesting(E).
soft(compute_derived_value_continuous_radius,E) :- task(compute_derived_value), channel(E,radius), continuous(E), enc_interesting(E).
soft(compute_derived_value_continuous_theta,E) :- task(compute_derived_value), channel(E,theta), continuous(E), enc_interesting(E).
soft(compute_derived_value_discrete_x,E) :- task(compute_derived_value), channel(E,x), discrete(E), enc_interesting(E).
soft(compute_derived_value_discrete_y,E) :- task(compute_derived_value), channel(E,y), discrete(E), enc_interesting(E).
soft(compute_derived_value_discrete_color,E) :- task(compute_derived_value), channel(E,color), discrete(E), enc_interesting(E).
soft(compute_derived_value_discrete_shape,E) :- task(compute_derived_value), channel(E,shape), discrete(E), enc_interesting(E).
soft(compute_derived_value_discrete_size,E) :- task(compute_derived_value), channel(E,size), discrete(E), enc_interesting(E).
soft(compute_derived_value_discrete_text,E) :- task(compute_derived_value), channel(E,text), discrete(E), enc_interesting(E).
soft(compute_derived_value_discrete_row,E) :- task(compute_derived_value), channel(E,row), discrete(E), enc_interesting(E).
soft(compute_derived_value_discrete_column,E) :- task(compute_derived_value), channel(E,column), discrete(E), enc_interesting(E).
soft(find_extremum_continuous_x,E) :- task(find_extremum), channel(E,x), continuous(E), enc_interesting(E).
soft(find_extremum_continuous_y,E) :- task(find_extremum), channel(E,y), continuous(E), enc_interesting(E).
soft(find_extremum_continuous_color,E) :- task(find_extremum), channel(E,color), continuous(E), enc_interesting(E).
soft(find_extremum_continuous_size,E) :- task(find_extremum), channel(E,size), continuous(E), enc_interesting(E).
soft(find_extremum_continuous_text,E) :- task(find_extremum), channel(E,text), continuous(E), enc_interesting(E).
soft(find_extremum_continuous_radius,E) :- task(find_extremum), channel(E,radius), continuous(E), enc_interesting(E).
soft(find_extremum_continuous_theta,E) :- task(find_extremum), channel(E,theta), continuous(E), enc_interesting(E).
soft(find_extremum_discrete_x,E) :- task(find_extremum), channel(E,x), discrete(E), enc_interesting(E).
soft(find_extremum_discrete_y,E) :- task(find_extremum), channel(E,y), discrete(E), enc_interesting(E).
soft(find_extremum_discrete_color,E) :- task(find_extremum), channel(E,color), discrete(E), enc_interesting(E).
soft(find_extremum_discrete_shape,E) :- task(find_extremum), channel(E,shape), discrete(E), enc_interesting(E).
soft(find_extremum_discrete_size,E) :- task(find_extremum), channel(E,size), discrete(E), enc_interesting(E).
soft(find_extremum_discrete_text,E) :- task(find_extremum), channel(E,text), discrete(E), enc_interesting(E).
soft(find_extremum_discrete_row,E) :- task(find_extremum), channel(E,row), discrete(E), enc_interesting(E).
soft(find_extremum_discrete_column,E) :- task(find_extremum), channel(E,column), discrete(E), enc_interesting(E).
soft(find_maximum_continuous_x,E) :- task(find_maximum), channel(E,x), continuous(E), enc_interesting(E).
soft(find_maximum_continuous_y,E) :- task(find_maximum), channel(E,y), continuous(E), enc_interesting(E).
soft(find_maximum_continuous_color,E) :- task(find_maximum), channel(E,color), continuous(E), enc_interesting(E).
soft(find_maximum_continuous_size,E) :- task(find_maximum), channel(E,size), continuous(E), enc_interesting(E).
soft(find_maximum_continuous_text,E) :- task(find_maximum), channel(E,text), continuous(E), enc_interesting(E).
soft(find_maximum_continuous_radius,E) :- task(find_maximum), channel(E,radius), continuous(E), enc_interesting(E).
soft(find_maximum_continuous_theta,E) :- task(find_maximum), channel(E,theta), continuous(E), enc_interesting(E).
soft(find_maximum_discrete_x,E) :- task(find_maximum), channel(E,x), discrete(E), enc_interesting(E).
soft(find_maximum_discrete_y,E) :- task(find_maximum), channel(E,y), discrete(E), enc_interesting(E).
soft(find_maximum_discrete_color,E) :- task(find_maximum), channel(E,color), discrete(E), enc_interesting(E).
soft(find_maximum_discrete_shape,E) :- task(find_maximum), channel(E,shape), discrete(E), enc_interesting(E).
soft(find_maximum_discrete_size,E) :- task(find_maximum), channel(E,size), discrete(E), enc_interesting(E).
soft(find_maximum_discrete_text,E) :- task(find_maximum), channel(E,text), discrete(E), enc_interesting(E).
soft(find_maximum_discrete_row,E) :- task(find_maximum), channel(E,row), discrete(E), enc_interesting(E).
soft(find_maximum_discrete_column,E) :- task(find_maximum), channel(E,column), discrete(E), enc_interesting(E).
soft(find_minimum_continuous_x,E) :- task(find_minimum), channel(E,x), continuous(E), enc_interesting(E).
soft(find_minimum_continuous_y,E) :- task(find_minimum), channel(E,y), continuous(E), enc_interesting(E).
soft(find_minimum_continuous_color,E) :- task(find_minimum), channel(E,color), continuous(E), enc_interesting(E).
soft(find_minimum_continuous_size,E) :- task(find_minimum), channel(E,size), continuous(E), enc_interesting(E).
soft(find_minimum_continuous_text,E) :- task(find_minimum), channel(E,text), continuous(E), enc_interesting(E).
soft(find_minimum_continuous_radius,E) :- task(find_minimum), channel(E,radius), continuous(E), enc_interesting(E).
soft(find_minimum_continuous_theta,E) :- task(find_minimum), channel(E,theta), continuous(E), enc_interesting(E).
soft(find_minimum_discrete_x,E) :- task(find_minimum), channel(E,x), discrete(E), enc_interesting(E).
soft(find_minimum_discrete_y,E) :- task(find_minimum), channel(E,y), discrete(E), enc_interesting(E).
soft(find_minimum_discrete_color,E) :- task(find_minimum), channel(E,color), discrete(E), enc_interesting(E).
soft(find_minimum_discrete_shape,E) :- task(find_minimum), channel(E,shape), discrete(E), enc_interesting(E).
soft(find_minimum_discrete_size,E) :- task(find_minimum), channel(E,size), discrete(E), enc_interesting(E).
soft(find_minimum_discrete_text,E) :- task(find_minimum), channel(E,text), discrete(E), enc_interesting(E).
soft(find_minimum_discrete_row,E) :- task(find_minimum), channel(E,row), discrete(E), enc_interesting(E).
soft(find_minimum_discrete_column,E) :- task(find_minimum), channel(E,column), discrete(E), enc_interesting(E).
soft(sort_continuous_x,E) :- task(sort), channel(E,x), continuous(E), enc_interesting(E).
soft(sort_continuous_y,E) :- task(sort), channel(E,y), continuous(E), enc_interesting(E).
soft(sort_continuous_color,E) :- task(sort), channel(E,color), continuous(E), enc_interesting(E).
soft(sort_continuous_size,E) :- task(sort), channel(E,size), continuous(E), enc_interesting(E).
soft(sort_continuous_text,E) :- task(sort), channel(E,text), continuous(E), enc_interesting(E).
soft(sort_continuous_radius,E) :- task(sort), channel(E,radius), continuous(E), enc_interesting(E).
soft(sort_continuous_theta,E) :- task(sort), channel(E,theta), continuous(E), enc_interesting(E).
soft(sort_discrete_x,E) :- task(sort), channel(E,x), discrete(E), enc_interesting(E).
soft(sort_discrete_y,E) :- task(sort), channel(E,y), discrete(E), enc_interesting(E).
soft(sort_discrete_color,E) :- task(sort), channel(E,color), discrete(E), enc_interesting(E).
soft(sort_discrete_shape,E) :- task(sort), channel(E,shape), discrete(E), enc_interesting(E).
soft(sort_discrete_size,E) :- task(sort), channel(E,size), discrete(E), enc_interesting(E).
soft(sort_discrete_text,E) :- task(sort), channel(E,text), discrete(E), enc_interesting(E).
soft(sort_discrete_row,E) :- task(sort), channel(E,row), discrete(E), enc_interesting(E).
soft(sort_discrete_column,E) :- task(sort), channel(E,column), discrete(E), enc_interesting(E).
soft(compare_objects_continuous_x,E) :- task(compare_objects), channel(E,x), continuous(E), enc_interesting(E).
soft(compare_objects_continuous_y,E) :- task(compare_objects), channel(E,y), continuous(E), enc_interesting(E).
soft(compare_objects_continuous_color,E) :- task(compare_objects), channel(E,color), continuous(E), enc_interesting(E).
soft(compare_objects_continuous_size,E) :- task(compare_objects), channel(E,size), continuous(E), enc_interesting(E).
soft(compare_objects_continuous_text,E) :- task(compare_objects), channel(E,text), continuous(E), enc_interesting(E).
soft(compare_objects_continuous_radius,E) :- task(compare_objects), channel(E,radius), continuous(E), enc_interesting(E).
soft(compare_objects_continuous_theta,E) :- task(compare_objects), channel(E,theta), continuous(E), enc_interesting(E).
soft(compare_objects_discrete_x,E) :- task(compare_objects), channel(E,x), discrete(E), enc_interesting(E).
soft(compare_objects_discrete_y,E) :- task(compare_objects), channel(E,y), discrete(E), enc_interesting(E).
soft(compare_objects_discrete_color,E) :- task(compare_objects), channel(E,color), discrete(E), enc_interesting(E).
soft(compare_objects_discrete_shape,E) :- task(compare_objects), channel(E,shape), discrete(E), enc_interesting(E).
soft(compare_objects_discrete_size,E) :- task(compare_objects), channel(E,size), discrete(E), enc_interesting(E).
soft(compare_objects_discrete_text,E) :- task(compare_objects), channel(E,text), discrete(E), enc_interesting(E).
soft(compare_objects_discrete_row,E) :- task(compare_objects), channel(E,row), discrete(E), enc_interesting(E).
soft(compare_objects_discrete_column,E) :- task(compare_objects), channel(E,column), discrete(E), enc_interesting(E).
soft(determine_range_continuous_x,E) :- task(determine_range), channel(E,x), continuous(E), enc_interesting(E).
soft(determine_range_continuous_y,E) :- task(determine_range), channel(E,y), continuous(E), enc_interesting(E).
soft(determine_range_continuous_color,E) :- task(determine_range), channel(E,color), continuous(E), enc_interesting(E).
soft(determine_range_continuous_size,E) :- task(determine_range), channel(E,size), continuous(E), enc_interesting(E).
soft(determine_range_continuous_text,E) :- task(determine_range), channel(E,text), continuous(E), enc_interesting(E).
soft(determine_range_continuous_radius,E) :- task(determine_range), channel(E,radius), continuous(E), enc_interesting(E).
soft(determine_range_continuous_theta,E) :- task(determine_range), channel(E,theta), continuous(E), enc_interesting(E).
soft(determine_range_discrete_x,E) :- task(determine_range), channel(E,x), discrete(E), enc_interesting(E).
soft(determine_range_discrete_y,E) :- task(determine_range), channel(E,y), discrete(E), enc_interesting(E).
soft(determine_range_discrete_color,E) :- task(determine_range), channel(E,color), discrete(E), enc_interesting(E).
soft(determine_range_discrete_shape,E) :- task(determine_range), channel(E,shape), discrete(E), enc_interesting(E).
soft(determine_range_discrete_size,E) :- task(determine_range), channel(E,size), discrete(E), enc_interesting(E).
soft(determine_range_discrete_text,E) :- task(determine_range), channel(E,text), discrete(E), enc_interesting(E).
soft(determine_range_discrete_row,E) :- task(determine_range), channel(E,row), discrete(E), enc_interesting(E).
soft(determine_range_discrete_column,E) :- task(determine_range), channel(E,column), discrete(E), enc_interesting(E).
soft(characterize_distribution_continuous_x,E) :- task(characterize_distribution), channel(E,x), continuous(E), enc_interesting(E).
soft(characterize_distribution_continuous_y,E) :- task(characterize_distribution), channel(E,y), continuous(E), enc_interesting(E).
soft(characterize_distribution_continuous_color,E) :- task(characterize_distribution), channel(E,color), continuous(E), enc_interesting(E).
soft(characterize_distribution_continuous_size,E) :- task(characterize_distribution), channel(E,size), continuous(E), enc_interesting(E).
soft(characterize_distribution_continuous_text,E) :- task(characterize_distribution), channel(E,text), continuous(E), enc_interesting(E).
soft(characterize_distribution_continuous_radius,E) :- task(characterize_distribution), channel(E,radius), continuous(E), enc_interesting(E).
soft(characterize_distribution_continuous_theta,E) :- task(characterize_distribution), channel(E,theta), continuous(E), enc_interesting(E).
soft(characterize_distribution_discrete_x,E) :- task(characterize_distribution), channel(E,x), discrete(E), enc_interesting(E).
soft(characterize_distribution_discrete_y,E) :- task(characterize_distribution), channel(E,y), discrete(E), enc_interesting(E).
soft(characterize_distribution_discrete_color,E) :- task(characterize_distribution), channel(E,color), discrete(E), enc_interesting(E).
soft(characterize_distribution_discrete_shape,E) :- task(characterize_distribution), channel(E,shape), discrete(E), enc_interesting(E).
soft(characterize_distribution_discrete_size,E) :- task(characterize_distribution), channel(E,size), discrete(E), enc_interesting(E).
soft(characterize_distribution_discrete_text,E) :- task(characterize_distribution), channel(E,text), discrete(E), enc_interesting(E).
soft(characterize_distribution_discrete_row,E) :- task(characterize_distribution), channel(E,row), discrete(E), enc_interesting(E).
soft(characterize_distribution_discrete_column,E) :- task(characterize_distribution), channel(E,column), discrete(E), enc_interesting(E).
soft(find_anomalies_continuous_x,E) :- task(find_anomalies), channel(E,x), continuous(E), enc_interesting(E).
soft(find_anomalies_continuous_y,E) :- task(find_anomalies), channel(E,y), continuous(E), enc_interesting(E).
soft(find_anomalies_continuous_color,E) :- task(find_anomalies), channel(E,color), continuous(E), enc_interesting(E).
soft(find_anomalies_continuous_size,E) :- task(find_anomalies), channel(E,size), continuous(E), enc_interesting(E).
soft(find_anomalies_continuous_text,E) :- task(find_anomalies), channel(E,text), continuous(E), enc_interesting(E).
soft(find_anomalies_continuous_radius,E) :- task(find_anomalies), channel(E,radius), continuous(E), enc_interesting(E).
soft(find_anomalies_continuous_theta,E) :- task(find_anomalies), channel(E,theta), continuous(E), enc_interesting(E).
soft(find_anomalies_discrete_x,E) :- task(find_anomalies), channel(E,x), discrete(E), enc_interesting(E).
soft(find_anomalies_discrete_y,E) :- task(find_anomalies), channel(E,y), discrete(E), enc_interesting(E).
soft(find_anomalies_discrete_color,E) :- task(find_anomalies), channel(E,color), discrete(E), enc_interesting(E).
soft(find_anomalies_discrete_shape,E) :- task(find_anomalies), channel(E,shape), discrete(E), enc_interesting(E).
soft(find_anomalies_discrete_size,E) :- task(find_anomalies), channel(E,size), discrete(E), enc_interesting(E).
soft(find_anomalies_discrete_text,E) :- task(find_anomalies), channel(E,text), discrete(E), enc_interesting(E).
soft(find_anomalies_discrete_row,E) :- task(find_anomalies), channel(E,row), discrete(E), enc_interesting(E).
soft(find_anomalies_discrete_column,E) :- task(find_anomalies), channel(E,column), discrete(E), enc_interesting(E).
soft(cluster_continuous_x,E) :- task(cluster), channel(E,x), continuous(E), enc_interesting(E).
soft(cluster_continuous_y,E) :- task(cluster), channel(E,y), continuous(E), enc_interesting(E).
soft(cluster_continuous_color,E) :- task(cluster), channel(E,color), continuous(E), enc_interesting(E).
soft(cluster_continuous_size,E) :- task(cluster), channel(E,size), continuous(E), enc_interesting(E).
soft(cluster_continuous_text,E) :- task(cluster), channel(E,text), continuous(E), enc_interesting(E).
soft(cluster_continuous_radius,E) :- task(cluster), channel(E,radius), continuous(E), enc_interesting(E).
soft(cluster_continuous_theta,E) :- task(cluster), channel(E,theta), continuous(E), enc_interesting(E).
soft(cluster_discrete_x,E) :- task(cluster), channel(E,x), discrete(E), enc_interesting(E).
soft(cluster_discrete_y,E) :- task(cluster), channel(E,y), discrete(E), enc_interesting(E).
soft(cluster_discrete_color,E) :- task(cluster), channel(E,color), discrete(E), enc_interesting(E).
soft(cluster_discrete_shape,E) :- task(cluster), channel(E,shape), discrete(E), enc_interesting(E).
soft(cluster_discrete_size,E) :- task(cluster), channel(E,size), discrete(E), enc_interesting(E).
soft(cluster_discrete_text,E) :- task(cluster), channel(E,text), discrete(E), enc_interesting(E).
soft(cluster_discrete_row,E) :- task(cluster), channel(E,row), discrete(E), enc_interesting(E).
soft(cluster_discrete_column,E) :- task(cluster), channel(E,column), discrete(E), enc_interesting(E).
soft(detect_number_of_clusters_continuous_x,E) :- task(detect_number_of_clusters), channel(E,x), continuous(E), enc_interesting(E).
soft(detect_number_of_clusters_continuous_y,E) :- task(detect_number_of_clusters), channel(E,y), continuous(E), enc_interesting(E).
soft(detect_number_of_clusters_continuous_color,E) :- task(detect_number_of_clusters), channel(E,color), continuous(E), enc_interesting(E).
soft(detect_number_of_clusters_continuous_size,E) :- task(detect_number_of_clusters), channel(E,size), continuous(E), enc_interesting(E).
soft(detect_number_of_clusters_continuous_text,E) :- task(detect_number_of_clusters), channel(E,text), continuous(E), enc_interesting(E).
soft(detect_number_of_clusters_continuous_radius,E) :- task(detect_number_of_clusters), channel(E,radius), continuous(E), enc_interesting(E).
soft(detect_number_of_clusters_continuous_theta,E) :- task(detect_number_of_clusters), channel(E,theta), continuous(E), enc_interesting(E).
soft(detect_number_of_clusters_discrete_x,E) :- task(detect_number_of_clusters), channel(E,x), discrete(E), enc_interesting(E).
soft(detect_number_of_clusters_discrete_y,E) :- task(detect_number_of_clusters), channel(E,y), discrete(E), enc_interesting(E).
soft(detect_number_of_clusters_discrete_color,E) :- task(detect_number_of_clusters), channel(E,color), discrete(E), enc_interesting(E).
soft(detect_number_of_clusters_discrete_shape,E) :- task(detect_number_of_clusters), channel(E,shape), discrete(E), enc_interesting(E).
soft(detect_number_of_clusters_discrete_size,E) :- task(detect_number_of_clusters), channel(E,size), discrete(E), enc_interesting(E).
soft(detect_number_of_clusters_discrete_text,E) :- task(detect_number_of_clusters), channel(E,text), discrete(E), enc_interesting(E).
soft(detect_number_of_clusters_discrete_row,E) :- task(detect_number_of_clusters), channel(E,row), discrete(E), enc_interesting(E).
soft(detect_number_of_clusters_discrete_column,E) :- task(detect_number_of_clusters), channel(E,column), discrete(E), enc_interesting(E).
soft(correlate_continuous_x,E) :- task(correlate), channel(E,x), continuous(E), enc_interesting(E).
soft(correlate_continuous_y,E) :- task(correlate), channel(E,y), continuous(E), enc_interesting(E).
soft(correlate_continuous_color,E) :- task(correlate), channel(E,color), continuous(E), enc_interesting(E).
soft(correlate_continuous_size,E) :- task(correlate), channel(E,size), continuous(E), enc_interesting(E).
soft(correlate_continuous_text,E) :- task(correlate), channel(E,text), continuous(E), enc_interesting(E).
soft(correlate_continuous_radius,E) :- task(correlate), channel(E,radius), continuous(E), enc_interesting(E).
soft(correlate_continuous_theta,E) :- task(correlate), channel(E,theta), continuous(E), enc_interesting(E).
soft(correlate_discrete_x,E) :- task(correlate), channel(E,x), discrete(E), enc_interesting(E).
soft(correlate_discrete_y,E) :- task(correlate), channel(E,y), discrete(E), enc_interesting(E).
soft(correlate_discrete_color,E) :- task(correlate), channel(E,color), discrete(E), enc_interesting(E).
soft(correlate_discrete_shape,E) :- task(correlate), channel(E,shape), discrete(E), enc_interesting(E).
soft(correlate_discrete_size,E) :- task(correlate), channel(E,size), discrete(E), enc_interesting(E).
soft(correlate_discrete_text,E) :- task(correlate), channel(E,text), discrete(E), enc_interesting(E).
soft(correlate_discrete_row,E) :- task(correlate), channel(E,row), discrete(E), enc_interesting(E).
soft(correlate_discrete_column,E) :- task(correlate), channel(E,column), discrete(E), enc_interesting(E).
soft(detect_correlation_continuous_x,E) :- task(detect_correlation), channel(E,x), continuous(E), enc_interesting(E).
soft(detect_correlation_continuous_y,E) :- task(detect_correlation), channel(E,y), continuous(E), enc_interesting(E).
soft(detect_correlation_continuous_color,E) :- task(detect_correlation), channel(E,color), continuous(E), enc_interesting(E).
soft(detect_correlation_continuous_size,E) :- task(detect_correlation), channel(E,size), continuous(E), enc_interesting(E).
soft(detect_correlation_continuous_text,E) :- task(detect_correlation), channel(E,text), continuous(E), enc_interesting(E).
soft(detect_correlation_continuous_radius,E) :- task(detect_correlation), channel(E,radius), continuous(E), enc_interesting(E).
soft(detect_correlation_continuous_theta,E) :- task(detect_correlation), channel(E,theta), continuous(E), enc_interesting(E).
soft(detect_correlation_discrete_x,E) :- task(detect_correlation), channel(E,x), discrete(E), enc_interesting(E).
soft(detect_correlation_discrete_y,E) :- task(detect_correlation), channel(E,y), discrete(E), enc_interesting(E).
soft(detect_correlation_discrete_color,E) :- task(detect_correlation), channel(E,color), discrete(E), enc_interesting(E).
soft(detect_correlation_discrete_shape,E) :- task(detect_correlation), channel(E,shape), discrete(E), enc_interesting(E).
soft(detect_correlation_discrete_size,E) :- task(detect_correlation), channel(E,size), discrete(E), enc_interesting(E).
soft(detect_correlation_discrete_text,E) :- task(detect_correlation), channel(E,text), discrete(E), enc_interesting(E).
soft(detect_correlation_discrete_row,E) :- task(detect_correlation), channel(E,row), discrete(E), enc_interesting(E).
soft(detect_correlation_discrete_column,E) :- task(detect_correlation), channel(E,column), discrete(E), enc_interesting(E).
soft(estimate_correlation_continuous_x,E) :- task(estimate_correlation), channel(E,x), continuous(E), enc_interesting(E).
soft(estimate_correlation_continuous_y,E) :- task(estimate_correlation), channel(E,y), continuous(E), enc_interesting(E).
soft(estimate_correlation_continuous_color,E) :- task(estimate_correlation), channel(E,color), continuous(E), enc_interesting(E).
soft(estimate_correlation_continuous_size,E) :- task(estimate_correlation), channel(E,size), continuous(E), enc_interesting(E).
soft(estimate_correlation_continuous_text,E) :- task(estimate_correlation), channel(E,text), continuous(E), enc_interesting(E).
soft(estimate_correlation_continuous_radius,E) :- task(estimate_correlation), channel(E,radius), continuous(E), enc_interesting(E).
soft(estimate_correlation_continuous_theta,E) :- task(estimate_correlation), channel(E,theta), continuous(E), enc_interesting(E).
soft(estimate_correlation_discrete_x,E) :- task(estimate_correlation), channel(E,x), discrete(E), enc_interesting(E).
soft(estimate_correlation_discrete_y,E) :- task(estimate_correlation), channel(E,y), discrete(E), enc_interesting(E).
soft(estimate_correlation_discrete_color,E) :- task(estimate_correlation), channel(E,color), discrete(E), enc_interesting(E).
soft(estimate_correlation_discrete_shape,E) :- task(estimate_correlation), channel(E,shape), discrete(E), enc_interesting(E).
soft(estimate_correlation_discrete_size,E) :- task(estimate_correlation), channel(E,size), discrete(E), enc_interesting(E).
soft(estimate_correlation_discrete_text,E) :- task(estimate_correlation), channel(E,text), discrete(E), enc_interesting(E).
soft(estimate_correlation_discrete_row,E) :- task(estimate_correlation), channel(E,row), discrete(E), enc_interesting(E).
soft(estimate_correlation_discrete_column,E) :- task(estimate_correlation), channel(E,column), discrete(E), enc_interesting(E).
soft(compare_derived_values_continuous_x,E) :- task(compare_derived_values), channel(E,x), continuous(E), enc_interesting(E).
soft(compare_derived_values_continuous_y,E) :- task(compare_derived_values), channel(E,y), continuous(E), enc_interesting(E).
soft(compare_derived_values_continuous_color,E) :- task(compare_derived_values), channel(E,color), continuous(E), enc_interesting(E).
soft(compare_derived_values_continuous_size,E) :- task(compare_derived_values), channel(E,size), continuous(E), enc_interesting(E).
soft(compare_derived_values_continuous_text,E) :- task(compare_derived_values), channel(E,text), continuous(E), enc_interesting(E).
soft(compare_derived_values_continuous_radius,E) :- task(compare_derived_values), channel(E,radius), continuous(E), enc_interesting(E).
soft(compare_derived_values_continuous_theta,E) :- task(compare_derived_values), channel(E,theta), continuous(E), enc_interesting(E).
soft(compare_derived_values_discrete_x,E) :- task(compare_derived_values), channel(E,x), discrete(E), enc_interesting(E).
soft(compare_derived_values_discrete_y,E) :- task(compare_derived_values), channel(E,y), discrete(E), enc_interesting(E).
soft(compare_derived_values_discrete_color,E) :- task(compare_derived_values), channel(E,color), discrete(E), enc_interesting(E).
soft(compare_derived_values_discrete_shape,E) :- task(compare_derived_values), channel(E,shape), discrete(E), enc_interesting(E).
soft(compare_derived_values_discrete_size,E) :- task(compare_derived_values), channel(E,size), discrete(E), enc_interesting(E).
soft(compare_derived_values_discrete_text,E) :- task(compare_derived_values), channel(E,text), discrete(E), enc_interesting(E).
soft(compare_derived_values_discrete_row,E) :- task(compare_derived_values), channel(E,row), discrete(E), enc_interesting(E).
soft(compare_derived_values_discrete_column,E) :- task(compare_derived_values), channel(E,column), discrete(E), enc_interesting(E).
soft(detect_presence_continuous_x,E) :- task(detect_presence), channel(E,x), continuous(E), enc_interesting(E).
soft(detect_presence_continuous_y,E) :- task(detect_presence), channel(E,y), continuous(E), enc_interesting(E).
soft(detect_presence_continuous_color,E) :- task(detect_presence), channel(E,color), continuous(E), enc_interesting(E).
soft(detect_presence_continuous_size,E) :- task(detect_presence), channel(E,size), continuous(E), enc_interesting(E).
soft(detect_presence_continuous_text,E) :- task(detect_presence), channel(E,text), continuous(E), enc_interesting(E).
soft(detect_presence_continuous_radius,E) :- task(detect_presence), channel(E,radius), continuous(E), enc_interesting(E).
soft(detect_presence_continuous_theta,E) :- task(detect_presence), channel(E,theta), continuous(E), enc_interesting(E).
soft(detect_presence_discrete_x,E) :- task(detect_presence), channel(E,x), discrete(E), enc_interesting(E).
soft(detect_presence_discrete_y,E) :- task(detect_presence), channel(E,y), discrete(E), enc_interesting(E).
soft(detect_presence_discrete_color,E) :- task(detect_presence), channel(E,color), discrete(E), enc_interesting(E).
soft(detect_presence_discrete_shape,E) :- task(detect_presence), channel(E,shape), discrete(E), enc_interesting(E).
soft(detect_presence_discrete_size,E) :- task(detect_presence), channel(E,size), discrete(E), enc_interesting(E).
soft(detect_presence_discrete_text,E) :- task(detect_presence), channel(E,text), discrete(E), enc_interesting(E).
soft(detect_presence_discrete_row,E) :- task(detect_presence), channel(E,row), discrete(E), enc_interesting(E).
soft(detect_presence_discrete_column,E) :- task(detect_presence), channel(E,column), discrete(E), enc_interesting(E).
soft(estimate_trend_continuous_x,E) :- task(estimate_trend), channel(E,x), continuous(E), enc_interesting(E).
soft(estimate_trend_continuous_y,E) :- task(estimate_trend), channel(E,y), continuous(E), enc_interesting(E).
soft(estimate_trend_continuous_color,E) :- task(estimate_trend), channel(E,color), continuous(E), enc_interesting(E).
soft(estimate_trend_continuous_size,E) :- task(estimate_trend), channel(E,size), continuous(E), enc_interesting(E).
soft(estimate_trend_continuous_text,E) :- task(estimate_trend), channel(E,text), continuous(E), enc_interesting(E).
soft(estimate_trend_continuous_radius,E) :- task(estimate_trend), channel(E,radius), continuous(E), enc_interesting(E).
soft(estimate_trend_continuous_theta,E) :- task(estimate_trend), channel(E,theta), continuous(E), enc_interesting(E).
soft(estimate_trend_discrete_x,E) :- task(estimate_trend), channel(E,x), discrete(E), enc_interesting(E).
soft(estimate_trend_discrete_y,E) :- task(estimate_trend), channel(E,y), discrete(E), enc_interesting(E).
soft(estimate_trend_discrete_color,E) :- task(estimate_trend), channel(E,color), discrete(E), enc_interesting(E).
soft(estimate_trend_discrete_shape,E) :- task(estimate_trend), channel(E,shape), discrete(E), enc_interesting(E).
soft(estimate_trend_discrete_size,E) :- task(estimate_trend), channel(E,size), discrete(E), enc_interesting(E).
soft(estimate_trend_discrete_text,E) :- task(estimate_trend), channel(E,text), discrete(E), enc_interesting(E).
soft(estimate_trend_discrete_row,E) :- task(estimate_trend), channel(E,row), discrete(E), enc_interesting(E).
soft(estimate_trend_discrete_column,E) :- task(estimate_trend), channel(E,column), discrete(E), enc_interesting(E).
soft(estimate_difference_continuous_x,E) :- task(estimate_difference), channel(E,x), continuous(E), enc_interesting(E).
soft(estimate_difference_continuous_y,E) :- task(estimate_difference), channel(E,y), continuous(E), enc_interesting(E).
soft(estimate_difference_continuous_color,E) :- task(estimate_difference), channel(E,color), continuous(E), enc_interesting(E).
soft(estimate_difference_continuous_size,E) :- task(estimate_difference), channel(E,size), continuous(E), enc_interesting(E).
soft(estimate_difference_continuous_text,E) :- task(estimate_difference), channel(E,text), continuous(E), enc_interesting(E).
soft(estimate_difference_continuous_radius,E) :- task(estimate_difference), channel(E,radius), continuous(E), enc_interesting(E).
soft(estimate_difference_continuous_theta,E) :- task(estimate_difference), channel(E,theta), continuous(E), enc_interesting(E).
soft(estimate_difference_discrete_x,E) :- task(estimate_difference), channel(E,x), discrete(E), enc_interesting(E).
soft(estimate_difference_discrete_y,E) :- task(estimate_difference), channel(E,y), discrete(E), enc_interesting(E).
soft(estimate_difference_discrete_color,E) :- task(estimate_difference), channel(E,color), discrete(E), enc_interesting(E).
soft(estimate_difference_discrete_shape,E) :- task(estimate_difference), channel(E,shape), discrete(E), enc_interesting(E).
soft(estimate_difference_discrete_size,E) :- task(estimate_difference), channel(E,size), discrete(E), enc_interesting(E).
soft(estimate_difference_discrete_text,E) :- task(estimate_difference), channel(E,text), discrete(E), enc_interesting(E).
soft(estimate_difference_discrete_row,E) :- task(estimate_difference), channel(E,row), discrete(E), enc_interesting(E).
soft(estimate_difference_discrete_column,E) :- task(estimate_difference), channel(E,column), discrete(E), enc_interesting(E).
soft(locate_continuous_x,E) :- task(locate), channel(E,x), continuous(E), enc_interesting(E).
soft(locate_continuous_y,E) :- task(locate), channel(E,y), continuous(E), enc_interesting(E).
soft(locate_continuous_color,E) :- task(locate), channel(E,color), continuous(E), enc_interesting(E).
soft(locate_continuous_size,E) :- task(locate), channel(E,size), continuous(E), enc_interesting(E).
soft(locate_continuous_text,E) :- task(locate), channel(E,text), continuous(E), enc_interesting(E).
soft(locate_continuous_radius,E) :- task(locate), channel(E,radius), continuous(E), enc_interesting(E).
soft(locate_continuous_theta,E) :- task(locate), channel(E,theta), continuous(E), enc_interesting(E).
soft(locate_discrete_x,E) :- task(locate), channel(E,x), discrete(E), enc_interesting(E).
soft(locate_discrete_y,E) :- task(locate), channel(E,y), discrete(E), enc_interesting(E).
soft(locate_discrete_color,E) :- task(locate), channel(E,color), discrete(E), enc_interesting(E).
soft(locate_discrete_shape,E) :- task(locate), channel(E,shape), discrete(E), enc_interesting(E).
soft(locate_discrete_size,E) :- task(locate), channel(E,size), discrete(E), enc_interesting(E).
soft(locate_discrete_text,E) :- task(locate), channel(E,text), discrete(E), enc_interesting(E).
soft(locate_discrete_row,E) :- task(locate), channel(E,row), discrete(E), enc_interesting(E).
soft(locate_discrete_column,E) :- task(locate), channel(E,column), discrete(E), enc_interesting(E).
soft(recognize_continuous_x,E) :- task(recognize), channel(E,x), continuous(E), enc_interesting(E).
soft(recognize_continuous_y,E) :- task(recognize), channel(E,y), continuous(E), enc_interesting(E).
soft(recognize_continuous_color,E) :- task(recognize), channel(E,color), continuous(E), enc_interesting(E).
soft(recognize_continuous_size,E) :- task(recognize), channel(E,size), continuous(E), enc_interesting(E).
soft(recognize_continuous_text,E) :- task(recognize), channel(E,text), continuous(E), enc_interesting(E).
soft(recognize_continuous_radius,E) :- task(recognize), channel(E,radius), continuous(E), enc_interesting(E).
soft(recognize_continuous_theta,E) :- task(recognize), channel(E,theta), continuous(E), enc_interesting(E).
soft(recognize_discrete_x,E) :- task(recognize), channel(E,x), discrete(E), enc_interesting(E).
soft(recognize_discrete_y,E) :- task(recognize), channel(E,y), discrete(E), enc_interesting(E).
soft(recognize_discrete_color,E) :- task(recognize), channel(E,color), discrete(E), enc_interesting(E).
soft(recognize_discrete_shape,E) :- task(recognize), channel(E,shape), discrete(E), enc_interesting(E).
soft(recognize_discrete_size,E) :- task(recognize), channel(E,size), discrete(E), enc_interesting(E).
soft(recognize_discrete_text,E) :- task(recognize), channel(E,text), discrete(E), enc_interesting(E).
soft(recognize_discrete_row,E) :- task(recognize), channel(E,row), discrete(E), enc_interesting(E).
soft(recognize_discrete_column,E) :- task(recognize), channel(E,column), discrete(E), enc_interesting(E).
soft(explore_adjacency_continuous_x,E) :- task(explore_adjacency), channel(E,x), continuous(E), enc_interesting(E).
soft(explore_adjacency_continuous_y,E) :- task(explore_adjacency), channel(E,y), continuous(E), enc_interesting(E).
soft(explore_adjacency_continuous_color,E) :- task(explore_adjacency), channel(E,color), continuous(E), enc_interesting(E).
soft(explore_adjacency_continuous_size,E) :- task(explore_adjacency), channel(E,size), continuous(E), enc_interesting(E).
soft(explore_adjacency_continuous_text,E) :- task(explore_adjacency), channel(E,text), continuous(E), enc_interesting(E).
soft(explore_adjacency_continuous_radius,E) :- task(explore_adjacency), channel(E,radius), continuous(E), enc_interesting(E).
soft(explore_adjacency_continuous_theta,E) :- task(explore_adjacency), channel(E,theta), continuous(E), enc_interesting(E).
soft(explore_adjacency_discrete_x,E) :- task(explore_adjacency), channel(E,x), discrete(E), enc_interesting(E).
soft(explore_adjacency_discrete_y,E) :- task(explore_adjacency), channel(E,y), discrete(E), enc_interesting(E).
soft(explore_adjacency_discrete_color,E) :- task(explore_adjacency), channel(E,color), discrete(E), enc_interesting(E).
soft(explore_adjacency_discrete_shape,E) :- task(explore_adjacency), channel(E,shape), discrete(E), enc_interesting(E).
soft(explore_adjacency_discrete_size,E) :- task(explore_adjacency), channel(E,size), discrete(E), enc_interesting(E).
soft(explore_adjacency_discrete_text,E) :- task(explore_adjacency), channel(E,text), discrete(E), enc_interesting(E).
soft(explore_adjacency_discrete_row,E) :- task(explore_adjacency), channel(E,row), discrete(E), enc_interesting(E).
soft(explore_adjacency_discrete_column,E) :- task(explore_adjacency), channel(E,column), discrete(E), enc_interesting(E).
soft(judge_similarity_continuous_x,E) :- task(judge_similarity), channel(E,x), continuous(E), enc_interesting(E).
soft(judge_similarity_continuous_y,E) :- task(judge_similarity), channel(E,y), continuous(E), enc_interesting(E).
soft(judge_similarity_continuous_color,E) :- task(judge_similarity), channel(E,color), continuous(E), enc_interesting(E).
soft(judge_similarity_continuous_size,E) :- task(judge_similarity), channel(E,size), continuous(E), enc_interesting(E).
soft(judge_similarity_continuous_text,E) :- task(judge_similarity), channel(E,text), continuous(E), enc_interesting(E).
soft(judge_similarity_continuous_radius,E) :- task(judge_similarity), channel(E,radius), continuous(E), enc_interesting(E).
soft(judge_similarity_continuous_theta,E) :- task(judge_similarity), channel(E,theta), continuous(E), enc_interesting(E).
soft(judge_similarity_discrete_x,E) :- task(judge_similarity), channel(E,x), discrete(E), enc_interesting(E).
soft(judge_similarity_discrete_y,E) :- task(judge_similarity), channel(E,y), discrete(E), enc_interesting(E).
soft(judge_similarity_discrete_color,E) :- task(judge_similarity), channel(E,color), discrete(E), enc_interesting(E).
soft(judge_similarity_discrete_shape,E) :- task(judge_similarity), channel(E,shape), discrete(E), enc_interesting(E).
soft(judge_similarity_discrete_size,E) :- task(judge_similarity), channel(E,size), discrete(E), enc_interesting(E).
soft(judge_similarity_discrete_text,E) :- task(judge_similarity), channel(E,text), discrete(E), enc_interesting(E).
soft(judge_similarity_discrete_row,E) :- task(judge_similarity), channel(E,row), discrete(E), enc_interesting(E).
soft(judge_similarity_discrete_column,E) :- task(judge_similarity), channel(E,column), discrete(E), enc_interesting(E).
soft(compare_chart_structure_continuous_x,E) :- task(compare_chart_structure), channel(E,x), continuous(E), enc_interesting(E).
soft(compare_chart_structure_continuous_y,E) :- task(compare_chart_structure), channel(E,y), continuous(E), enc_interesting(E).
soft(compare_chart_structure_continuous_color,E) :- task(compare_chart_structure), channel(E,color), continuous(E), enc_interesting(E).
soft(compare_chart_structure_continuous_size,E) :- task(compare_chart_structure), channel(E,size), continuous(E), enc_interesting(E).
soft(compare_chart_structure_continuous_text,E) :- task(compare_chart_structure), channel(E,text), continuous(E), enc_interesting(E).
soft(compare_chart_structure_continuous_radius,E) :- task(compare_chart_structure), channel(E,radius), continuous(E), enc_interesting(E).
soft(compare_chart_structure_continuous_theta,E) :- task(compare_chart_structure), channel(E,theta), continuous(E), enc_interesting(E).
soft(compare_chart_structure_discrete_x,E) :- task(compare_chart_structure), channel(E,x), discrete(E), enc_interesting(E).
soft(compare_chart_structure_discrete_y,E) :- task(compare_chart_structure), channel(E,y), discrete(E), enc_interesting(E).
soft(compare_chart_structure_discrete_color,E) :- task(compare_chart_structure), channel(E,color), discrete(E), enc_interesting(E).
soft(compare_chart_structure_discrete_shape,E) :- task(compare_chart_structure), channel(E,shape), discrete(E), enc_interesting(E).
soft(compare_chart_structure_discrete_size,E) :- task(compare_chart_structure), channel(E,size), discrete(E), enc_interesting(E).
soft(compare_chart_structure_discrete_text,E) :- task(compare_chart_structure), channel(E,text), discrete(E), enc_interesting(E).
soft(compare_chart_structure_discrete_row,E) :- task(compare_chart_structure), channel(E,row), discrete(E), enc_interesting(E).
soft(compare_chart_structure_discrete_column,E) :- task(compare_chart_structure), channel(E,column), discrete(E), enc_interesting(E).
soft(overall_continuous_x,E) :- task(overall), channel(E,x), continuous(E), enc_interesting(E).
soft(overall_continuous_y,E) :- task(overall), channel(E,y), continuous(E), enc_interesting(E).
soft(overall_continuous_color,E) :- task(overall), channel(E,color), continuous(E), enc_interesting(E).
soft(overall_continuous_size,E) :- task(overall), channel(E,size), continuous(E), enc_interesting(E).
soft(overall_continuous_text,E) :- task(overall), channel(E,text), continuous(E), enc_interesting(E).
soft(overall_continuous_radius,E) :- task(overall), channel(E,radius), continuous(E), enc_interesting(E).
soft(overall_continuous_theta,E) :- task(overall), channel(E,theta), continuous(E), enc_interesting(E).
soft(overall_discrete_x,E) :- task(overall), channel(E,x), discrete(E), enc_interesting(E).
soft(overall_discrete_y,E) :- task(overall), channel(E,y), discrete(E), enc_interesting(E).
soft(overall_discrete_color,E) :- task(overall), channel(E,color), discrete(E), enc_interesting(E).
soft(overall_discrete_shape,E) :- task(overall), channel(E,shape), discrete(E), enc_interesting(E).
soft(overall_discrete_size,E) :- task(overall), channel(E,size), discrete(E), enc_interesting(E).
soft(overall_discrete_text,E) :- task(overall), channel(E,text), discrete(E), enc_interesting(E).
soft(overall_discrete_row,E) :- task(overall), channel(E,row), discrete(E), enc_interesting(E).
soft(overall_discrete_column,E) :- task(overall), channel(E,column), discrete(E), enc_interesting(E).