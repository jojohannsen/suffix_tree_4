require_relative 'location'
require_relative 'node_factory'
require_relative 'suffix_linker'

class UkkonenBuilder
  attr_reader :dataSource, :location, :suffixLinker, :nodeFactory, :root

  def initialize(dataSource, nodeFactory)
    @dataSource = dataSource
    @nodeFactory = nodeFactory
    @root = @nodeFactory.newRoot()
    @location = Location.new(@root)
    @suffixLinker = SuffixLinker.new
  end

  def add(value, offset)
    while !self.extend(value, offset) do
      # nothing to do
    end
  end

  #
  #  returns true if done extending, which occurs when the value is found at the location
  #  or when there is nothing more to extend
  #
  def extend(value, offset)
    if (@location.onNode)
      if (@location.node.children.has_key?(value)) then
        @location.traverseDownChildValue(value)
        return true
      else
        @nodeFactory.addLeaf(@location.node, value, offset)

        # if we are at root, we are done
        if (@location.node.isRoot) then
          return true
        else
          @location.traverseToNextSuffix(@dataSource)
          @suffixLinker.update(@location)
          return false
        end
      end
    elsif (@dataSource.valueAt(@location.incomingEdgeOffset) == value) then
      @location.traverseDownEdgeValue()
      return true
    else
      newNode = @nodeFactory.splitEdgeAt(@dataSource, @location.node, @location.incomingEdgeOffset)
      @suffixLinker.nodeNeedingSuffixLink(newNode)
      @location.jumpToNode(newNode)
      return false
    end
  end
end