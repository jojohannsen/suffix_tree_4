require_relative '../src/node'
require_relative '../src/node_factory'
require_relative '../src/ukkonen_builder'
require_relative '../src/data/data_source_factory'
require_relative '../src/visitor/dfs'
require_relative '../src/visitor/tree_print_visitor'

class Cli
  def initialize()
    @trees = {}
    @treeData = {}
    @data = {}
    @currentTree = nil
    @currentTreeName = "(undefined)"
    @currentDataSource = nil
    @currentDataSourceName = "(undefined)"
    @dataSourceFactory = DataSourceFactory.new
    @commandHash = {
        "data" => "data <name> <type=string|file> <string or fileName>",
        "dump" => "dump <tree name>",
        "tree" => "tree <tree name> <data source name>"
    }
    @functionMapper = {
        'data' => self.method(:dataSource),
        'dump' => self.method(:dump),
        'help' => self.method(:showCommands),
        'tree' => self.method(:tree),
        'quit' => self.method(:quit),
        '?' => self.method(:showCommands)
    }
  end

  # help, ?
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

  # show hash of trees or data
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

  def dump(data)
    if (data.length == 2) then
      if (!@trees.has_key?(data[1])) then
        print "Tree '#{data[1]}' not found\n"
      else
        tree = @trees[data[1]]
        tpv = TreePrintVisitor.new(@treeData[data[1]])
        tdfs = DFS.new(tpv)
        tdfs.traverse(tree)
      end
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
        @data[data[1]] = @dataSourceFactory.newDataSource(data[2],data[3])
      end
    else
      self.usage("data")
    end
  end

  # tree <tree name> <data source name>
  def tree(data)
    if (data.length == 1) then
      self.dumpKeys("Trees", @trees)
    elsif (data.length == 3) then
      if (@trees.has_key?(data[1])) then
        print "Tree '#{data[1]}' already created\n"
      elsif (!@data.has_key?(data[2])) then
        print "Data '#{data[2]}' is not defined\n"
      else
        nodeFactory = NodeFactory.new
        builder = UkkonenBuilder.new(@data[data[2]], nodeFactory)
        builder.addSourceValues
        @trees[data[1]] = builder.root
        @treeData[data[1]] = @data[data[2]]
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

while (line = file.readline) do
  cli.process_line(line)
end


