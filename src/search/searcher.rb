require_relative '../visitor/bfs'
require_relative '../visitor/suffix_offset_visitor'

class Searcher
  def initialize(dataSource, node)
    @dataSource = dataSource
    @root = node
  end

  def find(s)
    location = Location.new(@root)
    if (location.match(@dataSource, s) == s.length) then
      soCollector = SuffixOffsetVisitor.new
      so = BFS.new(soCollector)
      so.traverse(location.node)
      return soCollector.result.sort
    else
      return []
    end
  end
end