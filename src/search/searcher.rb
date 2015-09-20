require_relative '../visitor/bfs'
require_relative '../visitor/suffix_offset_visitor'

class Searcher
  def initialize(dataSource, node)
    @dataSource = dataSource
    @root = node
  end

  def find(s)
    location = Location.new(@root)
    if (location.matchString(@dataSource, s) == s.length) then
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
  def match(location, s)
    location.match(@dataSource, s)
    return location.depth
  end
end