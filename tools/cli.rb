require_relative '../src/node'
require_relative '../src/data_source_factory'

class Cli
  def initialize()
    @trees = {}
    @data = {}
    @currentTree = nil
    @currentTreeName = "(undefined)"
    @currentDataSource = nil
    @currentDataSourceName = "(undefined)"
    @dataSourceFactory = DataSourceFactory.new
    @commandHash = {
        "data" => "data <name> <type=string|file> <string or fileName>",
        "tree" => "tree <name>",
        "use" =>  "use tree <tree name>\nuse data <data name>"
    }
    @functionMapper = {
        'data' => self.method(:dataSource),
        'tree' => self.method(:tree),
        'quit' => self.method(:quit),
        'use' => self.method(:useVar),
        '?' => self.method(:showCommands)
    }
  end

  def showCommands(data)
    @commandHash.keys.each do |key|
      print "#{@commandHash[key]}\n"
    end

    if (@currentTree != nil) then
      print "\nCurrent Tree: #{@currentTreeName}\n"
    end
    if (@currentDataSource != nil) then
      print "\nCurrent Data Source: #{@currentDataSourceName}\n"
    end
  end

  def usage(key)
    print "Usage: #{@commandHash[key]}\n"
  end

  def dumpKeys(name, hash)
    print "#{name}:"
    if (hash.keys.length == 0) then
      print " none created\n"
    else
      print "\n"
      hash.keys.each do |key|
        print "  #{key}\n"
      end
    end
  end

  # use tree <tree name>
  # use data <data name>
  def useVar(data)
    if ((data.length == 3) && ((data[1] == 'tree') || (data[1] == 'data'))) then
      varType = data[1]
      varName = data[2]
      if (varType == 'tree') then
        if (@trees.has_key?(varName)) then
          @currentTree = @trees[varName]
          @currentTreeName = varName
        else
          print "Tree '#{varName}' not found\n"
        end
      elsif (varType == 'data') then
        if (@data.has_keky?(varName)) then
          @currentDataSource = @data[varName]
          @currentDataSourceName = varName
        else
          print "Data '#{varName}' not found\n"
        end
      end
    else
      self.usage("use")
    end
  end

  # data <name> <type=string|file> value
  # puts data source into "data" hash
  def dataSource(data)
    if (data.length == 1) then
      self.dumpKeys("Data", @data)
    elsif ((data.length == 4) && ((data[2] == 'file') || (data[2] == 'string'))) then
      if (@data.has_key?(data[1])) then
        print "Data source '#{data[1]}' already created\n"
      else
        @data[data[1]] = @dataSource.newDataSource(data[2],data[3])
      end
    else
      self.usage("data")
    end
  end

  # tree <name>, puts new tree into "trees" hash
  def tree(data)
    if (data.length == 1) then
      self.dumpKeys("Trees", @trees)
    elsif (data.length == 2) then
      if (@trees.has_key?(data[1])) then
        print "Tree '#{data[1]}' already created\n"
      else
        @trees[data[1]] = Node.new
      end
    else
      self.usage("tree")
    end
  end

  # quit
  def quit(data)
    exit(0)
  end

  def process_line(line)
    line.chomp!
    line.downcase!
    data = line.split
    if (@functionMapper.has_key?(data[0])) then
      @functionMapper[data[0]].call(data)
    end
  end
end

cli = Cli.new()
file = STDIN
if (ARGV.length == 1) then
  file = File.open(ARGV[0], "r")
end

while (line = STDIN.readline) do
  cli.process_line(line)
end


