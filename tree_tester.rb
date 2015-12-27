# testing the tree
module TreeTester
  def self.test_random_forest(forest, test_data)
    forest_results = []
    trees_results = []
    trees_errors = []
    test_data.each.with_index do |test_row, j|
      votes = {}
      forest.each.with_index do |tree, i|
        decision, probability = tree.decide(test_row)
        trees_results[i] = decision
        if votes[decision].nil?
          votes[decision] = 1
        else
          votes[decision] += 1
        end
      end
      highest = -1
      prophecy = -1
      votes.each do |decision, vote|
        if vote > highest
          prophecy = decision
          highest = vote
        end
      end
      actual = test_row[test_row.length - 1]
      forest_results[j] = { result: prophecy,
                            accurate: prophecy == actual }
      trees_results.each.with_index do |result, i|
        if result != actual
          if trees_errors[i].nil?
            trees_errors[i] = 1
          else
            trees_errors[i] += 1
          end
        end
      end
    end
    forest_results
  end
end
