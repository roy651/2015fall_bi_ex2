# utility functions
module Utils

  # read the file, return the first row and then all the data rows
  def self.read_data_file(file_path)
    data = []
    header = nil
    File.open(file_path, 'r') do |f|
      f.each_line do |line|
        data << line.split(' ') unless header.nil?
        header = line.split(' ') if header.nil?
      end
      return header, data
    end
  end

  # is it a regression run?
  def self.regression?(header)
    num_of_classes(header) == 0
  end

  # utility func to get the classes from the header
  def self.num_of_classes(header)
    header.last.to_i
  end

  # utility func to get the features from the header
  def self.num_of_features(header)
    header.first.to_i
  end

  # different error calc for discreet or continous prediction
  def self.calc_error(prediction, actual, header)
    if regression?(header)
      (prediction - actual)**2
    else
      prediction == actual ? 0 : 1
    end
  end

  # different prediction extraction
  def self.calc_prediction(votes, header)
    if regression?(header)
      # simple avg of the decision of all the trees
      votes.map { |decision, probability| decision }.reduce(&:+) / votes.size
    else
      # sort the votes results, get the highest vote (last), then get the selected value (first)
      votes.sort_by { |decision, vote| vote  }.last.first
    end
  end

  # different error rate calculation
  def self.print_results(error_count, data, header)
    if regression?(header) # hence regression
      puts "RESULTS: #{Math.sqrt(error_count / data.size)} error-margin / out of #{data.size} test samples"
    else
      puts "RESULTS: #{error_count} errors / out of #{data.size} test samples"
    end
  end

  # different error calculation
  def self.print_trees_results(trees_results, header)
    puts "TREES:"
    if regression?(header) # hence regression
      trees_results.each.with_index do |result, size|
        print "#{(Math.sqrt(result)).round(2)}, "
      end
    else
      trees_results.each.with_index do |result, size|
        print "#{(result.to_f).round(2)}, "
      end
    end
    puts
  end

  # utility function to extract the last vector of the matrix - the result vector
  def self.get_results_vector(data_set)
    data_set.map { |e| e.last }
  end

  # utility function to total the classes occurences in the vector (used later for probability)
  def self.totals(results_vector)
    @@totals = Hash.new 0
    results_vector.each do |result_item|
      # @@totals[result_item] = 0 if @@totals[result_item].nil?
      @@totals[result_item] += 1
    end
    @@totals
  end

  # break vector into the left node
  def self.split_left_set(sorted_set, split_index)
    sorted_set[0..split_index]
  end

  # break vector into the right node
  def self.split_right_set(sorted_set, split_index)
    sorted_set[split_index + 1..-1]
  end

  # heart of the calculation: measure the impurity of any vector passed to it
  def self.calc_gini_func()
    return -> results_vector {
      totals_hash = Utils.totals(results_vector)
      probability_hash = {}
      prob_sqr = 0
      results_vector.uniq.each do |class_value|
        probability_hash[class_value] =
          totals_hash[class_value].to_f / results_vector.length
        prob_sqr += (probability_hash[class_value]**2)
      end
      1 - prob_sqr
    }
  end

  # heart of the calculation: measure the std-dev of any vector passed to it
  def self.calc_stddev_func()
    return -> results_vector {
      n = results_vector.size
      if (results_vector.is_a? Array) && n > 1
        results_vector.map!(&:to_f) # convert to float
        # identical numbers causing exceptions due to float calc - solved with rounding 
        mean = (results_vector.reduce(&:+) / n) # sum and divide in n
        sum_sqr = results_vector.map { |x| x**2 }.reduce(&:+).round(5) # sum squared values
        n_mean_sqr = (n * mean**2).round(5)
        Math.sqrt((sum_sqr - n_mean_sqr) / n) # sqrt the gap to the mean
      else
        0
      end
    }
  end
end
