class LeafCountVisitor
  def preVisit(node)
  end

  def postVisit(node)
    if (node.children != nil) then
      node.children.values.each do |child|
        node.leafCount += child.leafCount
      end
    end
  end
end