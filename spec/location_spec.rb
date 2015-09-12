require 'rspec'
require_relative '../src/location'
require_relative '../src/node'
require_relative '../src/string_data_source'

describe 'Location traversal' do

  context "child traversal" do
    it "traverses to leaf child" do
      @root = Node.new
      @child1 = Node.new
      @child2 = Node.new
      @root.addChild('c', @child1)
      @root.addChild('x', @child2)
      @location = Location.new(@root)
      @location.traverseDownChildValue('c')
      expect(@location.node.nodeId).to eq @child1.nodeId
      @location.traverseUp
      expect(@location.node.nodeId).to eq @root.nodeId
      @location.traverseDownChildValue('x')
      expect(@location.node.nodeId).to eq @child2.nodeId
    end
  end

  context "edge traversal" do
    it "traverse to middle of edge" do
      @root = Node.new
      @child = Node.new
      @child.incomingEdgeStartOffset = 0
      @child.incomingEdgeEndOffset = Node::UNSPECIFIED_OFFSET
      @dataSource = StringDataSource.new("xabxac")
      @root.addChild('x', @child)
      @location = Location.new(@root)
      @location.traverseDownChildValue('x')
      expect(@location.node.nodeId).to eq (1 + @root.nodeId)
      expect(@location.onNode).to eq false
      expect(@location.incomingEdgeOffset).to eq 1
    end
  end

  context "suffix link traversal" do
    it "follows suffix link" do
      @dataSource = StringDataSource.new("abxy")
      @root = Node.new
      @child1 = Node.new
      @root.addChild('a', @child1)
      @child2 = Node.new
      @root.addChild('b', @child2)
      @child1.incomingEdgeStartOffset = 0
      @child1.incomingEdgeEndOffset = 10
      @grandChild1 = Node.new
      @grandChild1.incomingEdgeStartOffset = 2
      @grandChild1.incomingEdgeEndOffset = Node::CURRENT_ENDING_OFFSET
      @child1.addChild('x', @grandChild1)
      @grandChild2 = Node.new
      @grandChild2.incomingEdgeStartOffset = 3
      @grandChild2.incomingEdgeEndOffset = Node::CURRENT_ENDING_OFFSET
      @child2.addChild('x', @grandChild2)
      @child1.suffixLink = @child2
      @location = Location.new(@root)
      @location.traverseDownChildValue('a')
      expect(@location.node.nodeId).to eq(@child1.nodeId)
      @location.traverseDownChildValue('x')
      expect(@location.node.nodeId).to eq(@grandChild1.nodeId)
      incomingEdgeStart, incomingEdgeEnd = @location.traverseUp
      expect(incomingEdgeStart).to eq(2)
      expect(incomingEdgeEnd).to eq(Node::CURRENT_ENDING_OFFSET)
      expect(@location.node.nodeId).to eq(@child1.nodeId)
      @location.traverseSuffixLink()
      expect(@location.node.nodeId).to eq(@child2.nodeId)
      @location.traverseSkipCountDown(@dataSource, incomingEdgeStart, incomingEdgeEnd)
      expect(@location.node.nodeId).to eq(@grandChild2.nodeId)
      @location.jumpToNode(@grandChild1)
      @location.traverseToNextSuffix(@dataSource)
      expect(@location.node.nodeId).to eq(@grandChild2.nodeId)
    end
  end
end