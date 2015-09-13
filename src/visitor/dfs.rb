class DFS
  def initialize(visitor)
    @visitor = visitor
  end

  def traverse(node)
    @visitor.preVisit(node)
    if (node.children != nil)
      node.children.values.each do |child|
        self.traverse(child)
      end
    end
    @visitor.postVisit(node)
  end
end