require_relative '../node'

class ValueDepthVisitor
  def preVisit(node)
    if (node.isInternal) then
      node.valueDepth = node.parent.valueDepth + node.incomingEdgeLength
    elsif (node.isLeaf) then
      node.valueDepth = Node::LEAF_DEPTH
    end
    return true
  end

  def postVisit(node)
  end
end