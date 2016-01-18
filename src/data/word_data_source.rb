require_relative 'base_data_source'

class WordDataSource < BaseDataSource
  attr_reader :words, :numberWordsInFile

  def initialize(filePath, regex = "/[^a-z0-9\-\s]/i")
    @filePath = filePath
    @words = []
    @regex = regex
    File.open(filePath, "r") do |file|
      file.each_line do |line|
        line.chomp!
        self.process(line)
      end
    end
    @numberWordsInFile = @words.length
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
    return @words[offset] if (offset < @numberWordsInFile)
    return nil
  end

  def toString(startOffset, endOffset)
    if (endOffset == -1) then
      result = "#{@words[startOffset]} ..*"
    else
      result = ""
      (startOffset..endOffset).each do |offset|
        result += "#{@words[offset]} "
      end
    end
    result
  end
end

class SingleWordDataSource < BaseDataSource
  def initialize(word)
    @word = word
  end

  def valueAt(offset)
    return @word
  end
end

class DelimitedWordDataSource < WordDataSource
  attr_reader :buckets, :wordCounts

  def initialize(filePath, lineStateMachine)
    @lineStateMachine = lineStateMachine
    @buckets = {}
    @wordCounts = {}
    @wordValueSequence = []  # list of words in file in terms of index into @wordAsEncountered
    @wordAsEncounteredIndex = {}          # key is word, value is number as encountered
    @wordAsEncountered = []  # array entry added only when a new word is encountered
    @nextWordEncounteredIndex = 0
    super(filePath,"/[^[:print:]]/")
  end

  def bucket
    @lineStateMachine.bucket
  end

  def save
    File.open("#{@filePath}.words", 'w') do |file|
      @wordAsEncountered.each do |word|
        file.write("#{word}\n")
      end
    end
    File.open("#{@filePath}.values", 'wb') do |file|
      file << @wordValueSequence.pack("N*")
    end
    File.open("#{@filePath}.summary", "w") do |file|
      file << "#{@numberWordsInFile} words in file\n"
      file << "#{@nextWordEncounteredIndex} distinct words\n"
    end
  end

  def wordCount(word)
    return @wordCounts[word] if @wordCounts.has_key?(word)
    return 0
  end

  def processData(data,bucket)
    data.each do |word|
      word = word.chomp(",")
      word = word.chomp(".")
      if (word.length > 0) then
        @words << word
        if (!@wordCounts.has_key?(word)) then
          # we have a new word
          @wordAsEncounteredIndex[word] = @nextWordEncounteredIndex
          @wordAsEncountered << word
          @nextWordEncounteredIndex += 1
          @wordCounts[word] = 0
        end
        @wordCounts[word] += 1
        if (!@buckets[bucket].has_key?(word)) then
          @buckets[bucket][word] = 0
        end
        @buckets[bucket][word] += 1
        @wordValueSequence << @wordAsEncounteredIndex[word]
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