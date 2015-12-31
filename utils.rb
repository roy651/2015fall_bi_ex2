# utility functions
module Utils

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

  def self.calc_error(prophecy, actual, header)
    if regression?(header)
      (prophecy - actual)**2
    else
      prophecy == actual ? 0 : 1
    end
  end

  def self.print_results(error_count, data, header)
    if regression?(header) # hence regression
      puts "RESULTS: #{Math.sqrt(error_count / data.size)} error-margin / out of #{data.size} test samples"
    else
      puts "RESULTS: #{error_count} error / out of #{data.size} test samples"
    end
  end
end
