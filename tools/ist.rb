require_relative '../src/data/line_state_machine'
require_relative '../src/data/word_data_source'
require_relative '../src/persist/suffix_tree_db'
require_relative '../src/search/searcher'
require_relative '../src/suffix_tree'
require_relative '../src/visitor/dfs'
require_relative '../src/visitor/numbering_visitor'
require_relative '../src/visitor/tree_print_visitor'

#
#  Another attempt at an interactive language for testing suffix trees
#

class DataSourceCommands
  def initialize
    @variables = {}
    @functionMapper = {}
    @numberParameters = {}
  end

  def runCommand(data)
    # "read" handled differently because it creates the data source
    if (data[1] == "read") then
      limit = 0
      limit = data[3].to_i if (data.length == 4)
      @variables[data[0]] = DelimitedWordDataSource.new(data[2], LineStateMachine.new, limit)
      self.setFunctionMapper(@variables[data[0]])

    elsif (@variables.has_key?(data[0]) && @functionMapper.has_key?(data[1]))
      self.setFunctionMapper(@variables[data[0]])

      # explicitly handle small number of parameters
      if (@numberParameters[data[1]] == 0) then
        @functionMapper[data[1]].call()
      elsif (@numberParameters[data[1]] == 1) then
        @functionMapper[data[1]].call(data[2])
      end
    end
  end

  def getVariable(name)
    return @variables[name]
  end

  def setFunctionMapper(instance)
    @functionMapper['save'] = instance.method(:save)
    @numberParameters['save'] = 0
  end
end

class SuffixTreeCommands
  def initialize(dataSourceCommands)
    @dataSourceCommands = dataSourceCommands
    @variables = {}
    @instanceFunctionMapper = {
        'data' => self.method(:data),
        'find' => self.method(:find),
        'finish' => self.method(:finish),
        'persist' => self.method(:persist),
        'print' => self.method(:printTree),
        'verify' => self.method(:verify),
    }
    @functionMapper = {}
    @numberParameters = {}
    @parameterType = {}
  end

  def runCommand(data)
    # "read" handled differently because it creates the data source
    if (data[1] == "create") then
      terminalValue = nil
      configuration = nil
      persister = nil
      persister = SuffixTreeDB.new(data[2][1..-1]) if (data.length == 3)
      @variables[data[0]] = SuffixTree.new(terminalValue, configuration, persister)
      self.setFunctionMapper(@variables[data[0]])
    elsif (@variables.has_key?(data[0]) && @instanceFunctionMapper.has_key?(data[1]))
      self.setFunctionMapper(@variables[data[0]])

      # explicitly handle small number of parameters
      if (@numberParameters[data[1]] == 0) then
        @functionMapper[data[1]].call()
      else
        @instanceFunctionMapper[data[1]].call(data)
      end
    end
  end

  def data(data)
    @functionMapper[data[1]].call(@dataSourceCommands.getVariable(data[2]))
  end

  def find(data)
    st = @variables[data[0]]
    searcher = Searcher.new(st.rootDataSource, st.root)
    location = searcher.matchDataSource(SingleWordDataSource.new(data[2]))
    if (location.node == st.root) then
      print "Did not find it\n"
    else
      suffixVisitor = SuffixOffsetVisitor.new
      dfs = DFS.new(suffixVisitor)
      dfs.traverse(location.node)
      @searchResults = suffixVisitor.result
      print "Found #{@searchResults.length} results\n"
      @searchResults.each do |offset|
        print "  #{offset}, #{st.rootDataSource.valueAt(offset)}, #{st.rootDataSource.metaDataFor(offset)}\n"
      end
    end
  end

  def finish(data)
    st = @variables[data[0]]
    st.finish
  end

  def persist(data)
    st = @variables[data[0]]

    searcher = Searcher.new(st.rootDataSource, st.root)
    testDataSource = ArrayWordDataSource.new(st.rootDataSource.wordAsEncountered,
                                             st.rootDataSource.wordValueSequence, data[2].to_i)
    allVerified = true
    testDataSource.each_word do |word|
      location = searcher.matchDataSource(SingleWordDataSource.new(word))
      suffixVisitor = SuffixOffsetVisitor.new
      dfs = DFS.new(suffixVisitor)
      dfs.traverse(location.node)
      @searchResults = suffixVisitor.result
      if (!st.rootDataSource.verify(word,@searchResults.length)) then
        print "Failed to verify #{word}, expected #{st.rootDataSource.wordCounts[word]}, found #{@searchResults.length}\n"
        allVerified = false
        self.printTreeFromNode(st.rootDataSource, location.node, 1)
      end
    end
    print "Successfully verified suffix tree '#{data[0]}'\n" if (allVerified)
    print "Failed to verify suffix tree '#{data[0]}'\n" if (!allVerified)
  end

  def printTree(data)
    st = @variables[data[0]]
    self.printTreeAtNode(st.root)
    nv = NumberingVisitor.new
    dfs = DFS.new(nv)
    dfs.traverse(st.root)
    self.printTreeFromNode(st.rootDataSource, st.root, (data.length == 3) ? data[2].to_i : TreePrintVisitor::ALL_LEVELS)
  end

  def printTreeFromNode(dataSource, node, levels)
    tpv = BasicDfsTreePrintVisitor.new(dataSource, STDOUT, levels)
    dfs = DFS.new(tpv)
    dfs.traverse(node)
  end

  def verify(data)
    st = @variables[data[0]]
    searcher = Searcher.new(st.rootDataSource, st.root)
    testDataSource = ArrayWordDataSource.new(st.rootDataSource.wordAsEncountered,
        st.rootDataSource.wordValueSequence, data[2].to_i)
    allVerified = true
    testDataSource.each_word do |word|
      location = searcher.matchDataSource(SingleWordDataSource.new(word))
      suffixVisitor = SuffixOffsetVisitor.new
      dfs = DFS.new(suffixVisitor)
      dfs.traverse(location.node)
      @searchResults = suffixVisitor.result
      if (!st.rootDataSource.verify(word,@searchResults.length)) then
        print "Failed to verify #{word}, expected #{st.rootDataSource.wordCounts[word]}, found #{@searchResults.length}\n"
        allVerified = false
        self.printTreeFromNode(st.rootDataSource, location.node, 1)
      end
    end
    print "Successfully verified suffix tree '#{data[0]}'\n" if (allVerified)
    print "Failed to verify suffix tree '#{data[0]}'\n" if (!allVerified)
  end

  def setFunctionMapper(instance)
    @functionMapper['data'] = instance.method(:addDataSource)
    @numberParameters['data'] = 1
  end
end

class InteractiveSuffixTree
  def initialize(args)
    @verbose = false
    @context = nil
    @functionMapper = {
        'call' => self.method(:call),
        'debug' => self.method(:debug),
        'quit' => self.method(:quit),
        'use' => self.method(:use)
    }
    @dataSourceCommands = DataSourceCommands.new
    @suffixTreeCommands = SuffixTreeCommands.new(@dataSourceCommands)
    @replacements = {}
    if (args.length > 1) then
      (1..(args.length-1)).each do |offset|
        print "offset is #{offset}, arg is #{args[offset]}\n"
        @replacements["ARGV-#{offset-1}"] = args[offset]
      end
    end
  end

  def process(line)
    line.chomp!

    print "BEFORE replacement: #{line}\n" if (@verbose)

    if (@replacements.length) then
      @replacements.keys.each do |replacementKey|
        print "line gsub '#{replacementKey}' with #{@replacements[replacementKey]}\n"
        print "original line: #{line}\n"
        line = line.gsub(replacementKey, @replacements[replacementKey])
        print "replaced line: #{line}\n"
      end
    end
    print "AFTER replacement: #{line}\n" if (@verbose)

    data = line.split

    # control commands
    if (data.length > 0) then
      if (data[0][0] == '#') then
        return
      end
      if (@functionMapper.has_key?(data[0])) then
        @functionMapper[data[0]].call(data)
        return
      end
    end

    # context specific commands require at minimum two tokens: <variable> <command>
    if ((@context != nil) && (data.length > 1)) then
      @context.runCommand(data)
    end
  end

  #
  # methods called via @functionMapper
  #
  #    call - read and run commands from a file
  #    debug - turn debugging print on and off
  #    quit - exit
  #    use - set context for class specific commands
  #
  def call(data)
    if ((data.length > 1) && File.exist?(data[1])) then
      File.open(data[1], "r") do |file|
        file.each_line do |line|
          self.process(line, nil)
        end
      end
    else
      self.commandError(data)
    end
  end

  def debug(data)
    @verbose = (data.length == 1) ? true : (data[1] == "on")
  end

  def quit(data)
    exit
  end

  def use(data)
    if ((data.length == 4) && (data[1] == "word") && (data[2] == "data") && (data[3] == "source")) then
      @context = @dataSourceCommands
    elsif ((data.length == 3) && (data[1] == "suffix") && (data[2] == "tree")) then
      @context = @suffixTreeCommands
    end
  end

  def commandError(data)
    print "ERROR: #{data[0]}, #{data.length}\n"
    data.each do |d|
      print "  #{d}\n"
    end
  end
end

ist = InteractiveSuffixTree.new(ARGV)
file = STDIN
if (ARGV.length > 1) then
  file = File.open(ARGV[0], "r")
end

begin
  while (line = file.readline) do
    ist.process(line)
  end
rescue EOFError
  print "End of file\n"
end

