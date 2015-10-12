require_relative '../visitor/bfs'
require_relative '../visitor/suffix_offset_visitor'

#
#  Searcher finds matches in a tree
#
#  It needs the tree root, and the data source used to make the tree
#  This assumes the tree was made with a single data source.
#
#  "find" really should be finding matches from a different data source (not a string)
#
class Searcher
  def initialize(treeDataSource, treeRoot)
    @dataSource = treeDataSource
    @root = treeRoot
    print "root node ID is #{@root.nodeId}\n"
    print "dataSource first value is #{@dataSource.valueAt(0)}\n"
  end

  #
  #  match dataSource values, return location in the suffix tree where the match stopped
  #
  def matchDataSource(dataSource)
    location = Location.new(@root)
    location.matchDataSource(@dataSource, dataSource)
    location
  end

  def find(s)
    location = Location.new(@root)
    if (location.matchDataSource(@dataSource, StringDataSource.new(s)).depth == s.length) then
      soCollector = SuffixOffsetVisitor.new
      so = BFS.new(soCollector)
      so.traverse(location.node)
      return soCollector.result.sort
    else
      return []
    end
  end

  # match a string starting at a specific location,
  # returning the character depth of the resulting match
  def findAtLocation(location, s)
    location.matchString(@dataSource, s)
    return location.depth
  end
end