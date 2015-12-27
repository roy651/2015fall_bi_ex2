# load './tree_builder.rb'

class TreeNodeOrLeaf
  # feature - the index of the feature / -1 for leaf
  # split - the value to compare. small or equal value fall on left_node / -1 for leaf
  # purity - the current node's purity index
  def initialize(results_vector)
    @feature = -1
    @split = -1
    @left_node = nil
    @right_node = nil
    @totals = TreeBuilder.totals(results_vector)
    highest = 0
    @totals.each do |result_item, result_occurence|
      if result_occurence > highest
        @decision = result_item
        @probability = result_occurence.to_f / results_vector.length
      end
    end
  end

  def set_as_node(feature, split, left, right)
    @feature = feature
    @split = split
    @left_node = left
    @right_node = right
  end

  def decide(test_sample)
    if @left_node.nil? && @right_node.nil?
      return @decision, @probability
    else
      if test_sample[@feature] <= @split
        return @left_node.decide(test_sample)
      else
        return @right_node.decide(test_sample)
      end
    end
  end
end
