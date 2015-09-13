require_relative 'node'

class NodeFactory
  attr_reader :nextNodeId, :nextSuffixOffset, :root

  def initialize()
    @nextSuffixOffset = 0
    @nextNodeId = 1
  end

  def newRoot()
    result = self.newNode()
    result.children = {}
    @root = result
    return result
  end

  def newNode()
    result = Node.new(@nextNodeId)
    @nextNodeId += 1
    return result
  end

  #
  #  The algorithm adds leaf nodes in order
  #
  def addLeaf(node, value, offset)
    result = self.newNode()
    result.leafCount = 1
    node.addChild(value, result)
    result.suffixOffset = @nextSuffixOffset
    @nextSuffixOffset += 1
    result.incomingEdgeStartOffset = offset
    result.incomingEdgeEndOffset = Node::CURRENT_ENDING_OFFSET
  end

  def splitEdgeAt(dataSource, node, incomingEdgeOffset)
    result = self.newNode()
    result.incomingEdgeStartOffset = node.incomingEdgeStartOffset
    result.incomingEdgeEndOffset = incomingEdgeOffset - 1
    result.suffixOffset = node.suffixOffset
    node.incomingEdgeStartOffset = incomingEdgeOffset
    node.parent.addChild(dataSource.valueAt(result.incomingEdgeStartOffset), result)
    result.addChild(dataSource.valueAt(incomingEdgeOffset), node)
    return result
  end
end