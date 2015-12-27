load './file_reader.rb'
load './tree_builder.rb'
load './tree_tester.rb'
require 'byebug'

# Main program code
module EX2Main
  def self.run(train_file_path, test_file_path, num_records, min_records)
    train_header, train_data = FileReader.read_data_file(train_file_path)
    test_header, test_data = FileReader.read_data_file(test_file_path)
    # data.each { |row| puts row}
    # puts header

    random_forest = TreeBuilder.build_random_forest(
      train_header,
      train_data,
      100, # iterations
      2, # depth
      num_records, # records
      min_records) # min records

    right = 0
    forest_results = TreeTester.test_random_forest(random_forest, test_data)
    forest_results.each do |result|
      right += 1 if result[:accurate]
    end
    right
  end
end

# EX2Main.run('../ex2files/data.txt', '../ex2files/data2.txt') if __FILE__ == $PROGRAM_NAME
