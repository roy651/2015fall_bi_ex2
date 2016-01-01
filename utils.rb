# utility functions
module Utils

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

  def self.num_of_classes(header)
    header.last.to_i
  end

  def self.num_of_features(header)
    header.first.to_i
  end

  def self.calc_error(prediction, actual, header)
    if regression?(header)
      (prediction - actual)**2
    else
      prediction == actual ? 0 : 1
    end
  end

  def self.calc_prediction(votes, header)
    if regression?(header)
      votes.map { |decision, probability| decision }.reduce(&:+) / votes.size
    else
      votes.sort_by { |decision, vote| vote  }.last.first
    end
  end

  def self.print_results(error_count, data, header)
    if regression?(header) # hence regression
      puts "RESULTS: #{Math.sqrt(error_count) / data.size} error-margin / out of #{data.size} test samples"
    else
      puts "RESULTS: #{error_count} errors / out of #{data.size} test samples"
    end
  end

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

  def self.get_results_vector(data_set)
    data_set.map { |e| e.last }
  end

  def self.totals(results_vector)
    totals = {}
    results_vector.each do |result_item|
      totals[result_item] = 0 if totals[result_item].nil?
      totals[result_item] += 1
    end
    totals
  end

  def self.split_left_set(sorted_set, split_index)
    sorted_set[0..split_index]
  end

  def self.split_right_set(sorted_set, split_index)
    sorted_set[split_index + 1..-1]
  end

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

  def self.calc_stddev_func()
    return -> results_vector {
      n = results_vector.size
      if n > 0
        results_vector.map!(&:to_f) # convert to float
        mean = results_vector.reduce(&:+) / n # sum and divide in n
        sum_sqr = results_vector.map { |x| x**2 }.reduce(&:+) # sum squared values
        Math.sqrt((sum_sqr - n * mean**2) / n) # sqrt the gap to the mean
      else
        0
      end
    }
  end
end
