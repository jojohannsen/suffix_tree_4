class DFS
  def initialize(visitor)
    @visitor = visitor
  end

  def traverse(node)
    if (@visitor.preVisit(node)) then
      if (node.children != nil)
        node.children.each do |key,value|
          self.traverse(value)
        end
      end
      @visitor.postVisit(node)
    end
  end

end