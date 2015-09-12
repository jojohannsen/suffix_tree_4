class Node
  # Leaf nodes use this due to Rule 1: once a leaf, always a leaf
  CURRENT_ENDING_OFFSET = -1

  # Root uses this, it has no incoming edge, yet as a Node has incoming edge offset properties
  UNSPECIFIED_OFFSET = -2

  attr_accessor :incomingEdgeStartOffset, :incomingEdgeEndOffset, :suffixOffset
  attr_accessor :parent, :suffixLink, :children
  attr_accessor :nodeId

  attr_accessor :characterDepth, :numberLeafNodesBelow

  def initialize(nodeId)
    @nodeId = nodeId
    @incomingEdgeStartOffset = UNSPECIFIED_OFFSET
    @incomingEdgeEndOffset = UNSPECIFIED_OFFSET
    @suffixOffset = UNSPECIFIED_OFFSET

    @parent = nil
    @suffixLink = nil
    @children = nil

    @characterDepth = 0
    @numberLeafNodesBelow = 0
  end

  def addChild(cVal, child)
    if (@children == nil) then
      @children = {}
    end
    @children[cVal] = child
    child.parent = self
  end

  def isRoot
    return @parent == nil
  end

  def isLeaf
    return @incomingEdgeEndOffset == CURRENT_ENDING_OFFSET
  end

  def incomingEdgeLength
    return @incomingEdgeEndOffset - @incomingEdgeStartOffset + 1
  end

end