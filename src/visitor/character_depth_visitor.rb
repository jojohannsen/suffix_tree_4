require_relative '../node'

class CharacterDepthVisitor
  def preVisit(node)
    if (node.isInternal) then
      node.characterDepth = node.parent.characterDepth + node.incomingEdgeLength
    elsif (node.isLeaf) then
      node.characterDepth = Node::LEAF_DEPTH
    end
  end

  def postVisit(node)
  end
end