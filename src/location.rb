require_relative 'node'

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
    @incomingEdgeOffset = @node.incomingEdgeStartOffset
    @onNode = true
    return incomingEdgeStart, incomingEdgeEnd
  end

  def traverseSuffixLink
    @node = @node.suffixLink
    @incomingEdgeOffset = @node.incomingEdgeStartOffset
    @onNode = true
  end

  #
  #  From the current Node with a given child value, traverse past that value
  #
  def traverseDownChildValue(value)
    @node = @node.children[value]
    @onNode = (@node.incomingEdgeLength == 1)
    @incomingEdgeOffset = @node.incomingEdgeStartOffset + 1
  end

  #
  #  From the current location that does NOT have a suffix link, either because it
  #  is on an edge or because it is on a newly created internal node, traverse
  #  to the next suffix
  #
  def traverseToNextSuffix(dataSource)
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
end