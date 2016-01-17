require_relative 'base_data_source'

class WordDataSource < BaseDataSource
  def initialize(filePath, regex = "/[^a-z0-9\-\s]/i")
    file = File.open(filePath, "r")
    @words = []
    @regex = regex
    file.each_line do |line|
      line.chomp!
      self.process(line)
    end
    @numberWords = @words.length
  end

  def process(line)
    line = self.preprocessLine(line)
    self.processData(line.split)
  end

  def processData(data)
    data.each do |word|
      word = word.chomp(",")
      @words << word
    end
  end

  def preprocessLine(line)
    line.downcase.gsub(@regex, ' ')
  end

  def valueAt(offset)
    return @words[offset] if (offset < @numberWords)
    return nil
  end
end



class DelimitedWordDataSource < WordDataSource
  attr_accessor :buckets
  def initialize(filePath, lineStateMachine)
    @lineStateMachine = lineStateMachine
    @buckets = {}
    super(filePath,"/[^[:print:]]/")
  end

  def bucket
    @lineStateMachine.bucket
  end

  def processData(data,bucket)
    data.each do |word|
      word = word.chomp(",")
      if (word.length > 0) then
        @words << word
        if (!@buckets[bucket].has_key?(word)) then
          @buckets[bucket][word] = 0
        end
        @buckets[bucket][word] += 1
      end
    end
  end

  def process(line)
    line = self.preprocessLine(line)
    data = @lineStateMachine.process(line)
    if (data.length > 0) then
      bucket = @lineStateMachine.bucket
      @buckets[bucket] = {} if (!@buckets.has_key?(bucket))
      self.processData(data,bucket)
    end
  end
end