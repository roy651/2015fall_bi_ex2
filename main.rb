load './file_reader.rb'
load './tree_builder.rb'
load './tree_tester.rb'
load './utils.rb'
require 'byebug'
require 'benchmark'

# Main program code
module EX2Main
  def self.run(train_file_path, test_file_path, num_trees, depth,
               num_records, num_features_per_level, min_records, seed)

    # read files
    train_header, train_data = FileReader.read_data_file(train_file_path)
    test_header, test_data = FileReader.read_data_file(test_file_path)

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
    random_forest.first.print('') if random_forest.size == 1

    # test the forest
    forest_results_per_test_rec = 
      TreeTester.test_random_forest(random_forest, test_data, test_header)

    # count the errors
    error_count = forest_results_per_test_rec.
      map { |result_rec| result_rec[:error]  }.reduce(&:+)

    # print the results
    Utils.print_results(error_count, test_data, test_header)
  end
end

time = Benchmark.measure {
  EX2Main.run('../ex2files/data.txt', '../ex2files/data2.txt', 100, 10, 90, 2, 10, 1) if __FILE__ == $PROGRAM_NAME
}
puts time.real # print benchmark data

# best=2450~ => 2600
# EX2Main.run('../ex2files/forestS.txt', '../ex2files/forestS2.txt', 100, 6, 70, 6, 5, 1)
# best=2500~ => 3600
# EX2Main.run('../ex2files/forestR.txt', '../ex2files/forestR2.txt', 1, 15, 1000, 14, 10, 1)
# best 0.18~ => 0.12
# EX2Main.run('../ex2files/sphere.txt', '../ex2files/sphere2.txt', 1, 15, 1000, 10, 9, 1)
# best 0.70~ => 0.57 

# EX2Main.run('../ex2files/data.txt', '../ex2files/data2.txt', trees:100, depth:10, records:90, features:2, min_rec:10)
# best=2450~ => 2600
# EX2Main.run('../ex2files/forestS.txt', '../ex2files/forestS2.txt', trees:100, depth:6, records:70, features:6, min_rec:5)
# best=2500~ => 3600
# EX2Main.run('../ex2files/forestR.txt', '../ex2files/forestR2.txt', trees:1, depth:15, records:1000, features:14, min_rec:10)
# best 0.18~ => 0.12
# EX2Main.run('../ex2files/sphere.txt', '../ex2files/sphere2.txt', trees:1, depth:15, records:1000, features:10, min_rec:10)
# best 0.70~ => 0.57 