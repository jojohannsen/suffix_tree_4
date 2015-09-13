class BFS
  def initialize(visitor)
    @visitor = visitor
    @q = Array.new
  end

  def traverse(node)
    @q.unshift(node)

    while (@q.size > 0) do
      node = @q.pop
      @visitor.preVisit(node)
      if (node.children != nil)  then
        node.children.values.each do |child|
          @q.unshift(child)
        end
      end
    end

  end
end