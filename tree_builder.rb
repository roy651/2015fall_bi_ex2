load './tree_node.rb'
# Tree Builder
module TreeBuilder
  def self.build_random_forest(header, data, iterations,
                               depth, samples_in_iteration, 
                               num_features, min_samples_in_set, seed)
    features = []
    header[0].to_i.times { |i| features[i] = i }
    forest = []
    puts "DATA: #{header[0]} coordinates / #{header[1]} classes"
    puts "BUILD: #{iterations} trees / #{depth} levels deep / " <<
      "#{samples_in_iteration} records per tree / " <<
      "#{min_samples_in_set} records to stop / #{num_features} features per level"
    puts 'RUNNING: '
    iterations.times do |i|
      # features_subset = features.sample(depth, random: seed)
      forest << decision_tree_split(data.sample(samples_in_iteration, random: seed),
                                    features,
                                    num_features,
                                    depth,
                                    min_samples_in_set,
                                    regression?(header))
      print "#{i + 1}/#{iterations}\r"
      STDOUT.flush
    end
    puts ''
    puts 'ENDED:'
    forest
  end

  def self.regression?(header)
    header[1] == '0'
  end

  def self.decision_tree_split(data, features, num_features, depth,
                               min_samples_in_set,
                               use_regression)
    class_vector = data.map { |e| e[e.length - 1] }
    if use_regression
      decision = RegressionTreeNode.new(class_vector)
    else
      decision = DecisionTreeNode.new(class_vector)
    end

    return decision if stoping_condition(class_vector, depth, min_samples_in_set)

    best_gain = 0
    best_split = nil
    best_feature = nil
    best_sort_by_feature = nil
    best_index = -1

    features_subset = features.sample(num_features)
    features_subset.each do |feature|
      sorted_by_feature = data.sort_by { |row| row[feature] }
      sorted_by_feature.each.with_index do |row, split_index|
        split_value = row[feature]
        split_gain = calc_gain(sorted_by_feature, split_index, use_regression)
        if split_gain > best_gain
          best_gain = split_gain
          best_split = split_value
          best_feature = feature
          best_sort_by_feature = sorted_by_feature
          best_index = split_index
        end
      end
    end

    decision.set_as_node(
      best_feature,
      best_split,
      decision_tree_split(split_left_set(best_sort_by_feature, best_index),
                          features, num_features, (depth - 1),
                          min_samples_in_set,
                          use_regression),
      decision_tree_split(split_right_set(best_sort_by_feature, best_index),
                          features, num_features, (depth - 1),
                          min_samples_in_set,
                          use_regression))
    decision
  end

  def self.del_from_arr(arr, value)
    arr.reject { |a| a == value }
  end

  def self.stoping_condition(class_vector, depth, min_samples_in_set)
    class_vector.length < min_samples_in_set ||
      class_vector.uniq.length <= 1 ||
      depth == 0
  end

  def self.calc_gain(sorted_set, split_index, use_regression)
    if use_regression
      calc_stdev_gain(sorted_set, split_index)
    else
      calc_gini_gain(sorted_set, split_index)
    end
  end

  def self.calc_stdev_gain(sorted_set, split_index)
    parent_set_stdev = calc_stdev(get_results_vector(sorted_set))

    left_set_stdev = calc_stdev(get_results_vector(
                                split_left_set(sorted_set, split_index)))
    left_set_prob = (split_index + 1).to_f / sorted_set.length

    right_set_stdev = calc_stdev(get_results_vector(
                                 split_right_set(sorted_set, split_index)))
    right_set_prob = 1 - left_set_prob

    parent_set_stdev - (left_set_prob * left_set_stdev +
                        right_set_prob * right_set_stdev)
  end

  def self.calc_gini_gain(sorted_set, split_index)
    parent_set_gini = calc_gini(get_results_vector(sorted_set))

    left_set_gini = calc_gini(get_results_vector(
                                split_left_set(sorted_set, split_index)))
    left_set_prob = (split_index + 1).to_f / sorted_set.length

    right_set_gini = calc_gini(get_results_vector(
                                 split_right_set(sorted_set, split_index)))
    right_set_prob = 1 - left_set_prob

    parent_set_gini - (left_set_prob * left_set_gini +
                       right_set_prob * right_set_gini)
  end

  def self.get_results_vector(data_set)
    data_set.map { |e| e[e.length - 1] }
  end

  def self.calc_stdev(results_vector)
    n = results_vector.size
    if n > 0
      results_vector.map!(&:to_f) # convert to float
      mean = results_vector.reduce(&:+) / n # sum and divide in n
      sum_sqr = results_vector.map { |x| x**2 }.reduce(&:+) # sum squared values
      Math.sqrt((sum_sqr - n * mean**2) / n) # sqrt the gap to the mean
    else
      0
    end
  end

  def self.calc_gini(results_vector)
    totals_hash = totals(results_vector)
    probability_hash = {}
    prob_sqr = 0
    results_vector.uniq.each do |class_value|
      probability_hash[class_value] =
        totals_hash[class_value].to_f / results_vector.length
      prob_sqr += (probability_hash[class_value]**2)
    end
    1 - prob_sqr
  end

  def self.totals(results_vector)
    totals = {}
    results_vector.each do |result_item|
      totals[result_item] = 0 if totals[result_item].nil?
      totals[result_item] += 1
    end
    totals
  end

  def self.split_left_set(sorted_set, split_index)
    sorted_set[0..split_index]
  end

  def self.split_right_set(sorted_set, split_index)
    sorted_set[split_index + 1..-1]
  end
end
