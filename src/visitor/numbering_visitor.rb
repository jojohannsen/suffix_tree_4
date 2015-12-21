require_relative '../node'

# monkey patching dfsNumber and numberNodesInSubtree
module NodeExtensions
  attr_accessor :dfsNumber, :numberNodesInSubtree
end

class Node
  prepend NodeExtensions
end

# use BaseVisitor counters to set the values
class NumberingVisitor < BaseVisitor
  def initialize
    super
  end

  def preVisit(node)
    super(node)
    node.dfsNumber = @preCounter
    return true
  end

  def postVisit(node)
    node.numberNodesInSubtree = @preCounter - node.dfsNumber + 1
  end
end