require_relative '../src/data/line_state_machine'
require_relative '../src/data/word_data_source'
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
      @variables[data[0]] = DelimitedWordDataSource.new(data[2], LineStateMachine.new)
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
        'print' => self.method(:printTree),
    }
    @functionMapper = {}
    @numberParameters = {}
    @parameterType = {}
  end

  def runCommand(data)
    print "SuffixTree runCommand\n"
    # "read" handled differently because it creates the data source
    if (data[1] == "create") then
      @variables[data[0]] = SuffixTree.new
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
    print "Data #{data}\n"
    @functionMapper[data[1]].call(@dataSourceCommands.getVariable(data[2]))
  end

  def find(data)
    print "Find #{data}\n"
    st = @variables[data[0]]
    searcher = Searcher.new(st.rootDataSource, st.root)
    location = searcher.matchDataSource(SingleWordDataSource.new(data[2]))
    suffixVisitor = SuffixOffsetVisitor.new
    dfs = DFS.new(suffixVisitor)
    dfs.traverse(location.node)
    @searchResults = suffixVisitor.result
    print "Found #{@searchResults.length} results\n"
    @searchResults.each do |offset|
      print "  #{offset}, #{st.rootDataSource.valueAt(offset)}\n"
    end
  end

  def printTree(data)
    print "Print #{data}\n"
    st = @variables[data[0]]
    nv = NumberingVisitor.new
    dfs = DFS.new(nv)
    dfs.traverse(st.root)
    tpv = BasicDfsTreePrintVisitor.new(st.rootDataSource, STDOUT)
    dfs = DFS.new(tpv)
    dfs.traverse(st.root)
  end

  def setFunctionMapper(instance)
    @functionMapper['data'] = instance.method(:addDataSource)
    @numberParameters['data'] = 1
  end
end

class InteractiveSuffixTree
  def initialize
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
  end

  def process(line)
    line.chomp!
    print "#{line}\n" if (@verbose)
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
          self.process(line)
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

ist = InteractiveSuffixTree.new()
file = STDIN
if (ARGV.length == 1) then
  file = File.open(ARGV[0], "r")
end

while (line = file.readline) do
  ist.process(line)
end
