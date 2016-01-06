# Base class for different tree nodes
class TreeNode
  # feature - the index of the feature / -1 for leaf
  @feature = -1
  # split - the value to compare. small or equal value
  #         fall on left_node / -1 for leaf
  @split = -1
  @left_node = nil
  @right_node = nil
  @decision = nil # incase it's a leaf
  @probability = -1 # incase it's a leaf

  # once established as a node - set the split value and feature index
  def set_as_node(feature, split, left, right)
    @feature = feature
    @split = split
    @left_node = left
    @right_node = right
    @is_leaf = false
  end

  # test function for a sample to provide an answer
  def decide(test_sample)
    if @is_leaf
      return @decision, @probability
    else
      if test_sample[@feature] <= @split
        return @left_node.decide(test_sample)
      else
        return @right_node.decide(test_sample)
      end
    end
  end

  # awesome printing
  def print(prefix = '')
    if @is_leaf
      puts "#{@decision} / #{@probability}"
    else
      puts "#{prefix}a#{@feature} <= #{@split}"
      @left_node.print(prefix + '|    ')
      puts "#{prefix}a#{@feature} > #{@split}"
      @right_node.print(prefix + '|    ')
    end
  end

  def get_features_score(result = {}, depth = 1.0)
    unless @is_leaf
      feature_name = 'a' + @feature.to_s
      result[feature_name] = 0 if result[feature_name].nil?
      result[feature_name] += (1.0 / depth)
      @left_node.get_features_score(result, depth * 2)
      @right_node.get_features_score(result, depth * 2)
    end
    result
  end

  def initialize(results_vector)
    @results_vector = results_vector
  end
end

# Tree node extension, used in 'regular' decision tree
module DecisionNode
  def init
    @is_leaf = true
    @totals = Utils.totals(@results_vector)
    highest = 0
    # a discrete decision requires voting amongst the results vector
    @totals.each do |result_item, result_occurence|
      if result_occurence > highest
        @decision = result_item
        # probability _may_ be used to weighted avg of the results of the forest
        @probability = result_occurence.to_f / @results_vector.length
      end
    end
  end
end

# Tree node extension used in 'regression' decision tree
module RegressionNode
  def init
    @is_leaf = true
    @results_vector.map!(&:to_f) # convert to float
    n = @results_vector.size
    @decision = @results_vector.reduce(&:+) / n # sum and divide in n
    # the decision is simply the avg of the values of the vector
    # the probability is not relevant in this case
    @probability = 1
  end
end
