require_relative '../src/data/data_source_factory'
require_relative '../src/node'
require_relative '../src/node_factory'
require_relative '../src/persist/suffix_tree_db'
require_relative '../src/search/searcher'
require_relative '../src/suffix_tree'
require_relative '../src/visitor/data_source_visitor'
require_relative '../src/visitor/dfs'
require_relative '../src/visitor/k_common_visitor'
require_relative '../src/visitor/tree_print_visitor'
require_relative '../src/visitor/value_depth_visitor'
require_relative '../src/visitor/numbering_visitor'

require "benchmark"

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
    @persist = false
    @defaultDB = SuffixTreeDB.new($stdout)
    @commandHash = {
        "child" => "child <key>",
        "data" => "data <name> <type=string|file> <string or fileName>",
        "dump" => "dump <tree name>",
        "find" => "find <string>",
        "lca" => "lca <node1> <node2>",
        "load" => "load from <file>",
        "parent" => "parent",
        "persist" => "persist [to <file>]",
        "root" => "root",
        "time" => "time",
        "tree" => "tree <tree name> <data source name>",
        "visit" => "visit <visitor name> [<data source name>]\n  visitor=datasource|kcommon|depth|dfsNumber"
    }
    @functionMapper = {
        'call' => self.method(:call),
        'child' => self.method(:child),
        'data' => self.method(:dataSource),
        'dump' => self.method(:dump),
        'find' => self.method(:find),
        'help' => self.method(:showCommands),
        'kcommon' => self.method(:kcommon),
        'lca' => self.method(:lca),
        'load' => self.method(:load),
        'parent' => self.method(:parent),
        'persist' => self.method(:persist),
        'root' => self.method(:root),
        'time' => self.method(:time),
        'tree' => self.method(:tree),
        'visit' => self.method(:visit),
        'quit' => self.method(:quit),
        '?' => self.method(:showCommands)
    }
  end

  def dumpNode(node)
    print "Node #{node.nodeId}\n"
    if (node.children == nil) then
      print ".. Leaf, #{node.incomingEdgeStartOffset}\n"
    else
      print ".. Internal, #{node.incomingEdgeStartOffset} .. #{node.incomingEdgeEndOffset}\n"
      node.children.keys.each do |key|
        print ".. #{key}\n"
      end
    end
  end

  def root(data)
    @currentNode = @currentTree.root
    self.dumpNode(@currentNode)
  end

  def child(data)
    print "child #{data[1]}..\n"
    key = data[1]
    if (@currentNode.children != nil) then
      if (!@currentNode.children.has_key?(key)) then
        key = data[1].upcase
      end
    end
    if ((@currentNode.children != nil) && (@currentNode.children.has_key?(key))) then
      print "..found\n"
      @currentNode = @currentNode.children[data[1]]
      self.dumpNode(@currentNode)
      print "..dumped\n"
    else
      print "..not found\n"
    end
  end

  def parent(data)
    if ((@currentNode != nil) && (@currentNode.parent != nil)) then
      @currentNode = @currentNode.parent
      self.dumpNode(@currentNode)
    end
  end

  def time(data)
    now = Time.now
    if (@prevTime != nil) then
      print "#{(now - @prevTime)*1000.0} ms\n"
    end
    @prevTime = now
  end

  # call <file>
  def call(data)
    if (data.length == 2) then
      print ">#{data[1]}: start of file\n"
      file = File.open(data[1], "r")
      file.each_line do |line|
        print ">#{line}"
        self.process_line(line)
      end
      print ">#{data[1]}: end of file\n"
    end
  end

  def find(data)
    if (data.length == 2) then
      searcher = Searcher.new(@currentDataSource, @currentTree.root)
      node = searcher.findNode(data[1])
      print "Node #{node.dfsNumber}\n" if node != nil
      result = searcher.find(data[1])
      print "Result size: #{result.length}\n"
      result.each do |value|
        print "#{value}, "
      end
    end
  end

  # lca <node1> <node2>
  def lca(data)
    bitUtil = BitUtil.new
    leafNodeCollector = LeafNodeCollector.new
    dfs = DFS.new(leafNodeCollector)
    dfs.traverse(@currentTree.root)
    node1 = leafNodeCollector.suffixToLeaf[data[1].to_i]
    node2 = leafNodeCollector.suffixToLeaf[data[2].to_i]
    if (node1 == nil) then
      print "node1 is nil\n"
    else
      print "node1 suffixOffset is #{node1.suffixOffset}, #{node1.dfsNumber}\n"
      print "node1 runTail is #{node1.runTail.dfsNumber}\n"
    end
    if (node2 == nil) then
      print "node2 is nil\n"
    else
      print "node2 suffixOffset is #{node2.suffixOffset}, #{node2.dfsNumber}\n"
      print "node2 runTail is #{node2.runTail.dfsNumber}\n"
    end
    binaryTreeLca = node1.runTail.dfsNumber & node2.runTail.dfsNumber
    print "AND = #{binaryTreeLca}\n"
    leftMostBit = bitUtil.leftBit(binaryTreeLca)
    print "Left-most 1 bit: #{leftMostBit}\n"
    lcaHeight = bitUtil.bitGreaterThanOrEqualTo(leftMostBit, node1.dfsNumber, node2.dfsNumber)
    print "Left-most bit >= to above, common to runBits of node1 and node2 = #{lcaHeight}\n"
    node1rightBit = bitUtil.rightBit(node1.dfsNumber)
    node2rightBit = bitUtil.rightBit(node2.dfsNumber)
    print "Right-most 1 bit of node1 = #{node1rightBit}\n"
    print "Right-most 1 bit of node2 = #{node2rightBit}\n"
    node1ancestorInRun = self.getAncestor(bitUtil, node1, lcaHeight, node1rightBit)
    node2ancestorInRun = self.getAncestor(bitUtil, node2, lcaHeight, node2rightBit)
    print "Node1 ancestor in run "
    if (node1ancestorInRun == nil) then
      print "nil\n"
    else
      print "#{node1ancestorInRun.dfsNumber}\n"
    end
    print "Node2 ancestor in run "
    if (node2ancestorInRun == nil) then
      print "nil\n"
    else
      print "#{node2ancestorInRun.dfsNumber}\n"
    end
  end

  def getAncestor(bitUtil, node, lcaHeight, nodeRightBit)
    if (lcaHeight == nodeRightBit) then
      return node
    else
      leftMostBitToRight = bitUtil.leftMostBitToRightOf(lcaHeight, node.dfsNumber)
      return nil
    end
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
      print "Current Data Source: #{@currentDataSourceName}\n"
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

  def newPrintVisitor(treedata)
    if (@lcaPreprocessed == nil) then
      TreePrintVisitor.new(treedata, $stdout)
    else
      DfsTreePrintVisitor.new(treedata, $stdout)
    end
  end

  def dump(data)
    if (data.length == 2) then
      if (!@trees.has_key?(data[1])) then
        print "Tree '#{data[1]}' not found\n"
      else
        tree = @trees[data[1]]
        tpv = self.newPrintVisitor(@treeData[data[1]])
        tdfs = DFS.new(tpv)
        tdfs.traverse(tree.root)
      end
    end
  end

  #
  # data <name> <type=string|file> value
  # puts data source into "data" hash
  #
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

  # tree <tree name> <data source name> [<data source switch interval>]
  def tree(data)
    if (data.length == 1) then
      self.dumpKeys("Trees", @trees)
    elsif ((data.length == 3) || (data.length == 4)) then
      if (@trees.has_key?(data[1])) then
        if (data[2] == "append") then
          if (@data.has_key?(data[3])) then
            print "Adding data source '#{data[3]}' to tree '#{data[1]}'"
            @trees[data[1]].addDataSource(@data[data[3]])
          else
            print "Data source '#{data[3]}' not found\n"
          end
        else
          print "Tree '#{data[1]}' already created\n"
        end
      elsif (!@data.has_key?(data[2])) then
        print "Data '#{data[2]}' is not defined\n"
      else
        print "Creating SuffixTree...#{data.length}\n"
        print "#{data[2]}, #{data[3]}"
        defaultHash = {:valueDepth => true, :dataSourceBit => true}
        defaultHash[:persist] = true if (@persist)
        st = SuffixTree.new(nil, defaultHash, @defaultDB)
        print "..adding values\n"
        @trees[data[1]] = st
        @treeData[data[1]] = @data[data[2]]
        if (data.length == 4) then
          st.nodeFactory.nextDataSourceSetSize(data[3].to_i)
        end
        st.addDataSource(@data[data[2]])
        @currentTree = st
        @currentTreeName = data[1]
        @currentDataSource = @data[data[2]]
        @currentDataSourceName = data[2]
        print "done\n"
      end
    else
      self.usage("tree")
    end
  end

  def persist(data)
    @persist = true
    if ((data.length == 3) && (data[1] == "to")) then
      @defaultDB = SuffixTreeDB.new(File.open(data[2], "w"))
    end
  end

  def load(data)
    if (((data.length == 5) || (data.length == 7)) && (data[1] == "from") && (data[3] == "data")) then
      dataSource = @data[data[4]]
      suffixLimit = 1000000
      if ((data.length == 7) && (data[5] == "limit")) then
        suffixLimit = data[6].to_i
      end
      treeBuilder = SuffixTreeBuilder.new(SuffixTreeDB.new(File.open(data[2], "r")), dataSource)
      @builtRoot = treeBuilder.buildNode()
      timing = Benchmark.measure {
        while (treeBuilder.buildNode() && (treeBuilder.suffixCount < suffixLimit)) do
        end
      }
      print "#{timing}\n"
    end
  end

  def kcommon(data)
    if (data.length == 2) then
      longestLength,sample = @kCommonVisitor.longestStringCommonTo(data[1].to_i)
      print "Longest length common to #{data[1]} is #{longestLength}\n"
      print "#{sample}\n"
    end
  end

  # visit <visitor name> [<data source name>]
  def visit(data)
    if ((data.length == 2) || (data.length == 3)) then
      d1down = data[1].downcase
      if (d1down == "datasource") then
        print "Start DataSourceVisitor traversal...\n"
        @dataSourceVisitor = DataSourceVisitor.new
        dfs = DFS.new(@dataSourceVisitor)
        dfs.traverse(@currentTree.root)
        print "Completed traversal\n"
      elsif (d1down == "kcommon") then
        print "Start KCommonVisitor traversal...\n"
        @kCommonVisitor = KCommonVisitor.new(@data[data[2]])
        dfs = DFS.new(@kCommonVisitor)
        dfs.traverse(@currentTree.root)
        print "Completed traversal\n"
      elsif (d1down == "depth") then
        print "Start ValueDepthVisitor traversal...\n"
        @valueDepthVisitor = ValueDepthVisitor.new
        dfs = DFS.new(@valueDepthVisitor)
        dfs.traverse(@currentTree.root)
        print "Completed traversal\n"
      elsif (d1down == "lca") then
        print "Started pre-processing for least common ancestor...\n"
        dfs = OrderedDFS.new(NumberingVisitor.new)
        dfs.traverse(@currentTree.root)
        dfs = OrderedDFS.new(RunDefiningVisitor.new)
        dfs.traverse(@currentTree.root)
        dfs = DFS.new(RunBitVisitor.new(@currentTree.root))
        dfs.traverse(@currentTree.root)
        @lcaPreprocessed = true
        print "Completed traversal\n"
      end
    end
  end

  # quit
  def quit(data)
    exit(0)
  end

  def process_line(line)
    line.chomp!
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


