# File Reading module
module FileReader
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
end
