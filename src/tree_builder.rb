load './tree_node.rb'
# Tree Builder... actually a forest builder
module TreeBuilder
  # main control function for growing the forest
  def self.build_random_forest(header, data, iterations,
                               depth, samples_in_iteration, 
                               num_features_per_level, 
                               min_samples_in_set, seed)
    # awesome printing...
    puts "DATA: #{header[0]} coordinates / #{header[1]} classes"
    puts "BUILD: #{iterations} trees / #{depth} levels deep / " <<
      "#{samples_in_iteration} records per tree / " <<
      "#{min_samples_in_set} records to stop / #{num_features_per_level} features per level"
    puts 'RUNNING: '

    forest = []
    # run {iteration} trees in the forest...
    iterations.times do |i|
      # buiid each tree recursively from the root
      forest << decision_tree_split(
                  samples_in_iteration.times.map { data.sample(random:seed) }, # randomize N recs for each tree with repetitions
                  (0..(Utils.num_of_features(header) - 1)).to_a, # pass all the features to choose from at each level
                  num_features_per_level, # to randomize at each level
                  depth,
                  min_samples_in_set,
                  Utils.regression?(header), seed)
      # log progress
      print "#{i + 1}/#{iterations}\r"
      STDOUT.flush
    end

    # log..
    puts ''
    puts 'ENDED.'

    # return value
    forest
  end

  # main grow function on the node level
  def self.decision_tree_split(data, features, num_features, depth,
                               min_samples_in_set,
                               use_regression, seed)
    # extract the class vector from the results matrix
    class_vector = Utils.get_results_vector(data)
    # initialize the tree node
    # prepare calc function
    node_or_leaf = TreeNode.new(class_vector)
    calc_func = nil
    if use_regression
      node_or_leaf.extend(RegressionNode)
      calc_func = Utils.calc_stddev_func
      incremental_func = Utils.calc_stddev_incremental!
    else
      node_or_leaf.extend(DecisionNode)
      calc_func = Utils.calc_gini_func
      incremental_func = Utils.calc_gini_incremental!
    end
    node_or_leaf.init

    # stop condition - get out and return node as a leaf
    return node_or_leaf if stoping_condition(class_vector, depth, min_samples_in_set)

    # construct the winning structure skeleton
    best_result = {gain: 0, split: nil, feature: nil, sort_by_feature: nil, index: -1}

    # randomize the set of features - maintain a consistent seed for re-runs
    features_subset = features.sample(num_features, random: seed)
    # iterate over selected features
    features_subset.each do |feature|
      # sort according to the selected feature
      sorted_by_feature = data.sort_by { |row| row[feature] }

      # calc the purity of the parent set WRT the current feature
      # preserve the calculation intermediate data in "memory" objects
      # and later pass them on to the iterations of calculations of the splits
      # to be able to calculate incrementally in o(1) instead of o(n)
      right_memory_obj =
        calc_func.call(Utils.get_results_vector(sorted_by_feature))
      parent_purity = right_memory_obj[:purity]
      # need to create a fake memory object for the fake left split in order
      # to serve the start of the iteration of the splits
      left_memory_obj = calc_func.call([])

      # iterate over the ordered samples
      sorted_by_feature.each.with_index do |row, split_index|
        # get current split value
        split_value = row[feature]
        # the "core" of the algo - calc the gain of the current split
        # receives also the "memory" data objects to pass on the to
        # the next cycle of the iteration
        split_gain, left_memory_obj, right_memory_obj =
          calc_gain!(sorted_by_feature,
                     split_index,
                     incremental_func,
                     left_memory_obj,
                     right_memory_obj,
                     parent_purity)
        # save as best if it is.... well - best...
        if split_gain > best_result[:gain]
          best_result[:gain] = split_gain
          best_result[:split] = split_value
          best_result[:feature] = feature
          best_result[:sort_by_feature] = sorted_by_feature
          best_result[:index] = split_index
        end
      end
    end

    # yet another stop condition - no gain at any possible split => it's a leaf!
    return node_or_leaf if best_result[:gain] == 0

    # since this is ot a leaf (failed stop condition..) - recursively operate on
    # the two sides of the split and continue to grow their branches
    node_or_leaf.set_as_node(
      best_result[:feature],
      best_result[:split],
      decision_tree_split(Utils.split_left_set(best_result[:sort_by_feature],
                          best_result[:index]),
                          features, num_features, (depth - 1),
                          min_samples_in_set,
                          use_regression, seed),
      decision_tree_split(Utils.split_right_set(best_result[:sort_by_feature],
                          best_result[:index]),
                          features, num_features, (depth - 1),
                          min_samples_in_set,
                          use_regression, seed))

    # return current node to the higher level
    node_or_leaf
  end

  # stop condition: check number of items in set, homeogenuity and depth
  def self.stoping_condition(class_vector, depth, min_samples_in_set)
    class_vector.length < min_samples_in_set ||
      class_vector.uniq.length <= 1 ||
      depth == 0
  end

  # gain = parent node's value minus probability weighted sum of child nodes
  # called with the "memory" data from the previous split in order to calculate
  # the purity (and gain) incrementally and save processing time from o(n) to o(1)
  # returns - the new "memory" objects for the next cycle of calculations
  def self.calc_gain!(sorted_set, split_index, incremental_func,
                     left_memory_obj, right_memory_obj, parent_purity)
    left_memory_obj = incremental_func.call(left_memory_obj,
                                            sorted_set[split_index].last,
                                            true)
    left_set_prob = (split_index + 1).to_f / sorted_set.length

    right_memory_obj = incremental_func.call(right_memory_obj,
                                             sorted_set[split_index].last,
                                             false)
    right_set_prob = 1 - left_set_prob

    # return the result
    gain = parent_purity - (left_set_prob * left_memory_obj[:purity] +
                            right_set_prob * right_memory_obj[:purity])
    return gain, left_memory_obj, right_memory_obj
  end
end
