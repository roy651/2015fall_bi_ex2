# Base class for different tree nodes
class TreeNode
  # feature - the index of the feature / -1 for leaf
  @feature = -1
  # split - the value to compare. small or equal value
  #         fall on left_node / -1 for leaf
  @split = -1
  @left_node = nil
  @right_node = nil
  @decision = nil
  @probability = -1

  def set_as_node(feature, split, left, right)
    @feature = feature
    @split = split
    @left_node = left
    @right_node = right
    @is_leaf = false
  end

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

  def print(prefix)
    if @is_leaf
      puts "#{@decision} / #{@probability}"
    else
      puts "#{prefix}a#{@feature} <= #{@split}"
      @left_node.print(prefix + '|    ')
      puts "#{prefix}a#{@feature} > #{@split}"
      @right_node.print(prefix + '|    ')
    end
  end
end

# Tree node used in 'regular' decision tree
class DecisionTreeNode < TreeNode
  def initialize(results_vector)
    @is_leaf = true
    @totals = TreeBuilder.totals(results_vector)
    highest = 0
    @totals.each do |result_item, result_occurence|
      if result_occurence > highest
        @decision = result_item
        @probability = result_occurence.to_f / results_vector.length
      end
    end
  end
end

# Tree node used in 'regular' decision tree
class RegressionTreeNode < TreeNode
  def initialize(results_vector)
    @is_leaf = true
    results_vector.map!(&:to_f) # convert to float
    n = results_vector.size
    @decision = results_vector.reduce(&:+) / n # sum and divide in n
    @probability = 1
  end
end
