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

  def addSource(dataSource)
    @dataSource = dataSource
    offset = 0
    dataSource.stringValue.each_char do |cval|
      self.add(cval, offset)
      offset += 1
    end
  end

  def add(value, offset)
    while self.extend(value, offset) do
      @suffixLinker.update(@location)
    end
  end

  #
  #  returns true if there is more to do as part of this extension
  #  returns false when there is nothing more to extend (last extension, or rule 3)
  #
  def extend(value, offset)
    if (@location.onNode)
      if (@location.node.children.has_key?(value)) then
        @location.traverseDownChildValue(value)
        return false  # rule 3
      else
        @nodeFactory.addLeaf(@location.node, value, offset)
        return @location.traverseToNextSuffix(@dataSource)  # rule 1, traverse returns false when at root
      end
    elsif (@dataSource.valueAt(@location.incomingEdgeOffset) == value) then
      @location.traverseDownEdgeValue()
      return false   # found value on edge, rule 3
    else
      newNode = @nodeFactory.splitEdgeAt(@dataSource, @location.node, @location.incomingEdgeOffset)
      @suffixLinker.nodeNeedingSuffixLink(newNode)
      @location.jumpToNode(newNode)
      return true   # rule 2
    end
  end
end