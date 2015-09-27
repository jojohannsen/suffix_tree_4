require_relative 'base_data_source'

class WordDataSource < BaseDataSource
  def initialize(filePath)
    file = File.open(filePath, "r")
    @words = []
    file.each_line do |line|
      line.chomp!
      line = line.downcase.gsub(/[^a-z0-9\-\s]/i, ' ')
      data = line.split
      data.each do |word|
        @words << word
      end
    end
    @numberWords = @words.length
  end

  def valueAt(offset)
    return @words[offset] if (offset < @numberWords)
    return nil
  end
end