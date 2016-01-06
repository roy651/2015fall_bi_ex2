# analyze the feature rankings in the trees
module TreeAnalyzer
  def self.analyze_forest(forest)
    features_total_score = {}
    forest.each do |tree|
      tree.get_features_score.each do |feature, score|
        features_total_score[feature] = 0 if features_total_score[feature].nil?
        features_total_score[feature] += score
      end
    end
    puts "RANKING:"
    puts features_total_score.sort_by { |feature, score| -score }.to_s
  end
end
