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
      200, # iterations
      6, # depth
      num_records, # records
      min_records) # min records

    error = 0
    forest_results = TreeTester.test_random_forest(random_forest, test_data, test_header)
    forest_results.each do |result|
      error += result[:error]
    end
    if test_header[1] == '0'
      Math.sqrt(error)
    else
      error
    end
  end
end

# EX2Main.run('../ex2files/data.txt', '../ex2files/data2.txt', 70, 30) if __FILE__ == $PROGRAM_NAME
