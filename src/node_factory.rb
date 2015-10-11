require_relative 'node'

class NodeFactory
  attr_reader :nextNodeId, :root
  attr_reader :dataSource
  attr_reader :configuration

  def initialize(dataSource)
    @dataSource = dataSource
    @suffixOffset = 0
    @configuration = {
        :leafCount => false,
        :valueDepth => false,
        :previousValue => false,
        :dataSourceBit => false
    }
    self.reset
  end

  def reset
    @nextNodeId = 1
  end

  def extendDataSource(dataSource, startOffset)
    @dataSourceBit = (@dataSourceBit << 1) if ((@configuration[:dataSourceBit]) && (@dataSource != nil))
    if (@dataSource == nil) then
      @dataSource = dataSource
    else
      @dataSource.extendWith(dataSource, startOffset)
    end
  end

  def setConfiguration configurationHash
    configurationHash.each do |key, value|
      @configuration[key] = value
    end
    self
  end

  def newRoot
    self.reset
    result = newNode
    result.children = {}
    @root = result
    @configuration.each do |key, value|
      if (value) then
        @root.createAccessor(key.to_s)
      end
    end

    # configuration controlled accessors
    @root.valueDepth = 0 if @configuration[:valueDepth]
    @root.leafCount = 0 if @configuration[:leafCount]
    @dataSourceBit = 1 if @configuration[:dataSourceBit]
    @root.dataSourceBit = @dataSourceBit if @configuration[:dataSourceBit]
    return result
  end


  #
  #  The algorithm adds leaf nodes in order
  #
  def addLeaf(node, value, offset)
    result = newChild(node, value)
    result.suffixOffset = @suffixOffset

    result.incomingEdgeStartOffset = offset
    result.incomingEdgeEndOffset = Node::CURRENT_ENDING_OFFSET

    # optional configuration based properties
    result.leafCount = 1 if (@configuration[:leafCount])
    result.previousValue = (@dataSource.valueAt(@suffixOffset - 1)) if ((@suffixOffset > 0) && @configuration[:previousValue])
    result.dataSourceBit = @dataSourceBit if @configuration[:dataSourceBit]
    @suffixOffset += 1
    result
  end

  def splitEdgeAt(node, incomingEdgeOffset)
    result = newChild(node.parent, @dataSource.valueAt(node.incomingEdgeStartOffset))
    result.incomingEdgeStartOffset = node.incomingEdgeStartOffset
    result.incomingEdgeEndOffset = incomingEdgeOffset - 1
    result.suffixOffset = node.suffixOffset
    node.incomingEdgeStartOffset = incomingEdgeOffset
    addChild(result, @dataSource.valueAt(incomingEdgeOffset), node)

    # optional configuration based properties
    result.valueDepth = (result.parent.valueDepth + result.incomingEdgeLength) if @configuration[:valueDepth]
    result.dataSourceBit = (node.dataSourceBit | @dataSourceBit) if @configuration[:dataSourceBit]
    return result
  end

  #
  # return a string of all values on the path to this node
  #
  def valuePath(node, delimiter=' ')
    result = []
    while (node.parent != nil) do
      addValues(result, node.incomingEdgeStartOffset, node.incomingEdgeEndOffset)
      node = node.parent
    end
    result.reverse!
    return result.join(delimiter)
  end

  #
  # internal private methods
  #
  private

  def addValues(result, startOffset, endOffset)
    if (endOffset == Node::CURRENT_ENDING_OFFSET) then
      result << @dataSource.valueAt(startOffset)
    else
      scanner = endOffset
      while (scanner >= startOffset) do
        result << @dataSource.valueAt(scanner)
        scanner -= 1
      end
    end
  end

  def newChild(node, key)
    child = newNode
    addChild(node, key, child)
    child.valueDepth = 0 if @configuration[:valueDepth]
    return child
  end

  def newNode
    result = Node.new(@nextNodeId)

    # newRoot defines leafCount accessor, so that case is handled in newRoot after the node is created
    result.leafCount = 0 if (@configuration[:leafCount] && (@nextNodeId > 1))
    result.dataSourceBit = @dataSourceBit if (@configuration[:dataSourceBit] && (@nextNodeId > 1))
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