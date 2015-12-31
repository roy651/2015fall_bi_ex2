# testing the tree
module TreeTester
  def self.test_random_forest(forest, test_data, test_header)
    forest_results = []
    trees_results = []
    trees_errors = []
    puts 'TESTING: '
    iterations = test_data.length
    test_data.each.with_index do |test_row, j|
      votes = {}
      forest.each.with_index do |tree, i|
        decision, probability = tree.decide(test_row)
        trees_results[i] = decision
        votes[decision] = 0 if votes[decision].nil?
        votes[decision] += probability
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
                            error: Utils.calc_error(prophecy.to_f, actual.to_f, test_header) }

      trees_results.each.with_index do |result, i|
        if result != actual
          trees_errors[i] = 0 if trees_errors[i].nil?
          trees_errors[i] += Utils.calc_error(result.to_f, actual.to_f, test_header)
        end
      end
      # print "#{j + 1}/#{iterations}\r"
      # STDOUT.flush
    end
    puts ''
    puts 'ENDED:'
    forest_results
  end
end
