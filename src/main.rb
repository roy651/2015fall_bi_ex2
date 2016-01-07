load './tree_builder.rb'
load './tree_tester.rb'
load './tree_analyzer.rb'
load './utils.rb'
require 'byebug'
require 'benchmark'
# require 'profile'

# Main program code
module EX2Main
  def self.run(train_file_path, test_file_path, num_trees, depth,
               num_records, num_features_per_level, min_records, seed = 1)

    # read files
    train_header, train_data = Utils.read_data_file(train_file_path)
    test_header, test_data = Utils.read_data_file(test_file_path)

    puts "---------------------------------------------"
    puts "TRAINING: #{train_file_path}"
    # num of records is usually N - but we allow here to build on a smaller subset
    num_records = train_data.size if num_records <= 0
    # grow forest
    random_forest = TreeBuilder.build_random_forest(
      train_header,
      train_data,
      num_trees, # iterations
      depth, # depth
      num_records, # to randomize at each tree
      num_features_per_level, # to randomize each level of the tree
      min_records, # within a group as a stop condition
      seed)

    # print the tree if there's only a single tree - used for debug
    random_forest.first.print() if random_forest.size == 1

    # collect score of all features from all trees and print out
    TreeAnalyzer.analyze_forest(random_forest)

    puts "TESTING: #{test_file_path}"
    # test the forest
    forest_results_per_test_rec, progressive_results_per_tree = 
      TreeTester.test_random_forest(random_forest, test_data, test_header)

    # count the errors
    error_count = forest_results_per_test_rec.
      map { |result_rec| result_rec[:error]  }.reduce(&:+)

    # print the results
    Utils.print_results(error_count, test_data, test_header)
    Utils.print_trees_results(progressive_results_per_tree, test_header)
  end
end

time = Benchmark.measure {
  EX2Main.run('../data/data.txt', '../data/data.txt', 200, 10, 0, 2, 3, 1) if __FILE__ == $PROGRAM_NAME
} 
puts "TIME: #{time.real}" # print benchmark data
time = Benchmark.measure {
  EX2Main.run('../data/forestS.txt', '../data/forestS.txt', 200, 15, 0, 8, 5, 1) if __FILE__ == $PROGRAM_NAME
} 
puts "TIME: #{time.real}" # print benchmark data
time = Benchmark.measure {
  EX2Main.run('../data/forestR.txt', '../data/forestR.txt', 200, 10, 0, 5, 5, 1) if __FILE__ == $PROGRAM_NAME
} 
puts "TIME: #{time.real}" # print benchmark data
time = Benchmark.measure {
  EX2Main.run('../data/sphere.txt', '../data/sphere.txt', 200, 10, 0, 5, 5, 1) if __FILE__ == $PROGRAM_NAME
} 
puts "TIME: #{time.real}" # print benchmark data
time = Benchmark.measure {
  EX2Main.run('../data/data.txt', '../data/data2.txt', 200, 10, 0, 2, 3, 1) if __FILE__ == $PROGRAM_NAME
} 
puts "TIME: #{time.real}" # print benchmark data
time = Benchmark.measure {
  EX2Main.run('../data/forestS.txt', '../data/forestS2.txt', 200, 15, 0, 8, 5, 1) if __FILE__ == $PROGRAM_NAME
} 
puts "TIME: #{time.real}" # print benchmark data
time = Benchmark.measure {
  EX2Main.run('../data/forestR.txt', '../data/forestR2.txt', 200, 10, 0, 5, 5, 1) if __FILE__ == $PROGRAM_NAME
} 
puts "TIME: #{time.real}" # print benchmark data
time = Benchmark.measure {
  EX2Main.run('../data/sphere.txt', '../data/sphere2.txt', 200, 10, 0, 5, 5, 1) if __FILE__ == $PROGRAM_NAME
} 
puts "TIME: #{time.real}" # print benchmark data
