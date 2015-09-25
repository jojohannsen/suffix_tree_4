require_relative 'node'

class NodeFactory
  attr_reader :nextNodeId, :root
  attr_reader :dataSource
  attr_reader :configuration

  def initialize(dataSource)
    @dataSource = dataSource
    self.reset
  end

  def reset
    @nextNodeId = 1
  end

  def setConfiguration configurationHash
    @configuration = configurationHash
  end

  def newRoot()
    self.reset
    result = newNode
    result.children = {}
    @root = result
    return result
  end


  #
  #  The algorithm adds leaf nodes in order
  #
  def addLeaf(suffixOffset, node, value, offset)
    result = newChild(node, value)
    result.leafCount = 1
    result.suffixOffset = suffixOffset
    result.incomingEdgeStartOffset = offset
    result.incomingEdgeEndOffset = Node::CURRENT_ENDING_OFFSET
    result
  end

  def splitEdgeAt(node, incomingEdgeOffset)
    result = newChild(node.parent, @dataSource.valueAt(node.incomingEdgeStartOffset))
    result.incomingEdgeStartOffset = node.incomingEdgeStartOffset
    result.incomingEdgeEndOffset = incomingEdgeOffset - 1
    result.suffixOffset = node.suffixOffset
    node.incomingEdgeStartOffset = incomingEdgeOffset
    addChild(result, @dataSource.valueAt(incomingEdgeOffset), node)
    return result
  end

  private

  def newChild(node, key)
    child = newNode
    addChild(node, key, child)
    return child
  end

  def newNode()
    result = Node.new(@nextNodeId)
    @nextNodeId += 1
    return result
  end

  def addChild(parentNode, value, childNode)
    if (parentNode.children == nil) then
      parentNode.children = {}
    end
    parentNode.children[value] = childNode
    childNode.parent = parentNode
  end
end