# testing the tree
module TreeTester
  # run all test samples iteratively through the forest to get a prediction
  def self.test_random_forest(forest, test_data, test_header)
    forest_results = []
    trees_results = []
    trees_errors = []
    prediction = -1
    puts 'TESTING: '
    iterations = test_data.length
    #iterate over the test records
    test_data.each.with_index do |test_row, j|
      votes = {}
      # per record - iterate over the forest trees
      forest.each.with_index do |tree, i|
        # get the tree's vote
        decision, probability = tree.decide(test_row)
        # decision = decision.to_i
        votes[decision] = 0 if votes[decision].nil? # init the hash entry counter
        votes[decision] += probability
        # record the current vote up to this tree and save into prediction (incase it's last)
        # ==> sort the votes (ascending), get the last=>highest vote, get the vote from the record
        trees_results[i] = prediction = Utils.calc_prediction(votes, test_header)
      end
      # now get the actual result in order to compare to the prediction
      actual = test_row[test_row.length - 1]
      forest_results[j] = { result: prediction,
                            error: Utils.calc_error(prediction.to_f, actual.to_f, test_header) }
      # ... and compare to the progressive prediction we recorded on each tree
      trees_results.each.with_index do |result, i|
        trees_errors[i] = 0 if trees_errors[i].nil?
        trees_errors[i] += Utils.calc_error(result.to_f, actual.to_f, test_header)
      end
      # log progress
      if ((j + 1) % 100 == 0)
        print "#{j + 1}/#{iterations}\r"
        STDOUT.flush
     end
    end
    puts ''
    puts 'ENDED:'
    return forest_results, trees_errors
  end
end
