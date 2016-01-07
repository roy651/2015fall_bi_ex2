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
  # this method should only run once per node-per-feature and later we run the
  # incremental version below
  def self.calc_gini_func()
    return -> results_vector do
      data = {}
      data[:totals_hash] = Utils.totals(results_vector)
      data[:length] = results_vector.length
      prob_sqr = calc_prob_sqr(data[:totals_hash], results_vector.length)
      data[:purity] = (1 - prob_sqr)
      return data
    end
  end

  # calculates the impurity of the data based on the previous purity of the
  # data and the addition/subtraction of a new item - thus turning this
  # multi-million calls function from o(n) to o(1) !!!
  def self.calc_gini_incremental!
    return -> (mem_data, new_item, add_to_set) do
      if add_to_set
        mem_data[:totals_hash][new_item] += 1
        mem_data[:length] += 1
      else
        mem_data[:totals_hash][new_item] -= 1
        mem_data[:length] -= 1
      end
      prob_sqr = calc_prob_sqr(mem_data[:totals_hash], mem_data[:length])
      mem_data[:purity] = (1 - prob_sqr)
      return mem_data
    end
  end

  # heart of the calculation: measure the std-dev of any vector passed to it
  # this method should only run once per node-per-feature and later we run the
  # incremental version below
  def self.calc_stddev_func
    return -> results_vector do
      data = {}
      data[:purity] = 0
      data[:n] = results_vector.size
      data[:mean] = 0
      data[:sum_sqr] = 0
      if (results_vector.is_a? Array) && data[:n] > 1
        results_vector.map!(&:to_f) # convert to float
        # identical numbers causing exceptions due to float calc - solved with rounding 
        data[:mean] = (results_vector.reduce(&:+) / data[:n]) # sum and divide in n
        data[:sum_sqr] = results_vector.map { |x| x**2 }.reduce(&:+).round(5) # sum squared values
        data[:n_mean_sqr] = (data[:n] * data[:mean]**2).round(5)
        data[:purity] =
          Math.sqrt((data[:sum_sqr] - data[:n_mean_sqr]) / data[:n]) # sqrt the gap to the mean
      end
      return data
    end
  end

  # calculates the stddev of the data based on the previous stddev of the
  # data and the addition/subtraction of a new item - thus turning this
  # multi-million calls function from o(n) to o(1) !!!
  def self.calc_stddev_incremental!
    return -> (mem_data, new_item, add_to_set) do
      sum = mem_data[:mean] * mem_data[:n]
      new_item = new_item.to_f
      # according to the addition/subtraction of the item - make the correction
      # to the calculation towards the stddev calc
      if add_to_set
        sum += new_item
        mem_data[:n] += 1
        mem_data[:sum_sqr] += new_item**2
      else
        sum -= new_item
        mem_data[:n] -= 1
        mem_data[:sum_sqr] -= new_item**2
      end

      mem_data[:mean] = (sum / mem_data[:n]) # sum and divide in n
      mem_data[:n_mean_sqr] = (mem_data[:n] * mem_data[:mean]**2).round(5)
      # due the rounding done on the previous cycles of the calculation we may 
      # be dragging a slight incremental error, thus allowing myself to neglect it
      mem_data[:sum_sqr] = mem_data[:n_mean_sqr] if (mem_data[:sum_sqr] < mem_data[:n_mean_sqr])
      mem_data[:purity] =
        Math.sqrt((mem_data[:sum_sqr] - mem_data[:n_mean_sqr]) / mem_data[:n]) # sqrt the gap to the mean
      return mem_data
    end
  end

  # utility helper
  def self.calc_prob_sqr(occurences_hash, length)
    prob_sqr = 0
    occurences_hash.values.each do |value|
      prob_sqr += ((value.to_f / length)**2)
    end
    prob_sqr
  end
end
