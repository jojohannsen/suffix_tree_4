require_relative 'node'

#
#  This class keeps track of the next value to check in a suffix tree
#
#  If we are located at a node, there are several options for the next value
#  which are in the map of value-to-node.
#
#  If we are not on a node, there is an incoming edge with at least one value
#  so we store the offset of that value in the data source
#
class Location
  attr_reader :node, :onNode, :incomingEdgeOffset

  def initialize(node)
    self.jumpToNode(node)
  end

  def jumpToNode(node)
    @node = node
    @onNode = true
    @incomingEdgeOffset = @node.incomingEdgeStartOffset
  end

  def traverseUp
    incomingEdgeStart, incomingEdgeEnd = @node.incomingEdgeStartOffset, @node.incomingEdgeEndOffset
    @node = @node.parent
    @incomingEdgeOffset = Node::UNSPECIFIED_OFFSET
    @onNode = true
    return incomingEdgeStart, incomingEdgeEnd
  end

  def traverseSuffixLink
    @node = @node.suffixLink
    @incomingEdgeOffset = Node::UNSPECIFIED_OFFSET
    @onNode = true
  end

  #
  #  From the current Node with a given child value, traverse past that value
  #
  def traverseDownChildValue(value)
    @node = @node.children[value]
    if (@node.incomingEdgeLength == 1) then
      @onNode = true
      @incomingEdgeOffset = Node::UNSPECIFIED_OFFSET
    else
      @onNode = false
      @incomingEdgeOffset = @node.incomingEdgeStartOffset + 1
    end
  end

  #
  #  From the current location that does NOT have a suffix link, either because it
  #  is on an edge or because it is on a newly created internal node, traverse
  #  to the next suffix
  #
  #  Returns true if it actually traversed, otherwise false
  #
  def traverseToNextSuffix(dataSource)
    if (@node.isRoot) then
      return false
    end
    upStart, upEnd = self.traverseUp
    if (@node.isRoot) then
      if (upStart < upEnd) then
        self.traverseSkipCountDown(dataSource, upStart + 1, upEnd)
      else
        @onNode = true
      end
    else
      @node = @node.suffixLink
      self.traverseSkipCountDown(dataSource, upStart, upEnd)
    end
    return true
  end

  #
  #  From the current location on a Node, traverse down assuming the characters
  #  on the path exist, which allows skip/count method to be used to move down.
  #
  def traverseSkipCountDown(dataSource, startOffset, endOffset)
    done = false
    while (!done) do
      @node = @node.children[dataSource.valueAt(startOffset)]
      if (@node.isLeaf) then
        @onNode = false
        @incomingEdgeOffset = @node.incomingEdgeStartOffset + (endOffset - startOffset + 1)
      else
        startOffset += @node.incomingEdgeLength
        remainingLength = endOffset - startOffset + 1
        @onNode = (remainingLength == 0)
        # if remaining length is negative, it means we have past where we need to be
        # by that amount, incoming edge offset is set to end reduced by that amount
        if (remainingLength < 0) then
          @incomingEdgeOffset = @node.incomingEdgeEndOffset + remainingLength + 1
        end
      end

      done = (@node.isLeaf || (remainingLength <= 0))
    end
  end

  def traverseDownEdgeValue()
    @incomingEdgeOffset += 1
    if (!@node.isLeaf && (@incomingEdgeOffset > @node.incomingEdgeEndOffset)) then
      @onNode = true
    end
  end

  def match(dataSource, s)
    s.each_char.with_index(0) do |cval, index|
      if (!self.matchChar(dataSource, cval)) then
        return index
      end
    end
    return s.length
  end

  def matchChar(dataSource, cval)
    if (@onNode) then
      if ((@node.children != nil) && (@node.children.has_key?(cval)))
        self.traverseDownChildValue(cval)
        return true
      end
    elsif (dataSource.valueAt(@incomingEdgeOffset) == cval) then
      self.traverseDownEdgeValue
      return true
    end
    return false
  end

  #
  #  get the depth of the location
  #
  #  Requires the tree nodes all have character depth
  #
  def depth
    if (@onNode) then
      return @node.characterDepth
    else
      return @node.parent.characterDepth + @incomingEdgeOffset - @node.incomingEdgeStartOffset
    end
  end
end