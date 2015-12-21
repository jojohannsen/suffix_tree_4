require_relative '../node'

module NodeExtensions
  attr_accessor :dfsNumber, :numberNodesInSubtree
end

class Node
  prepend NodeExtensions
end

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