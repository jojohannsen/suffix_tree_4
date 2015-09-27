class DFS
  def initialize(visitor)
    @visitor = visitor
  end

  def traverse(node)
    #print "DFS traverse #{node.nodeId}\n"
    if (@visitor.preVisit(node)) then
      #print "preVisit returned true for #{node.nodeId}\n"
      if (node.children != nil)
        #print "traversing children of #{node.nodeId}\n"
        node.children.values.each do |child|
          self.traverse(child)
        end
      end
      #print "calling postVisit #{node.nodeId}\n"
      @visitor.postVisit(node)
      #print "postVisit #{node.nodeId} returned\n"
    end
    #print "DFS completed, traverse #{node.nodeId}\n"
  end
end