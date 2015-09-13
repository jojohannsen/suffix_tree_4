require 'rspec'
require_relative '../src/location'
require_relative '../src/node'
require_relative '../src/node_factory'
require_relative '../src/data/string_data_source'

describe 'Location traversal' do

  context "child traversal" do
    it "traverses to leaf child" do
      nodeFactory = NodeFactory.new()
      root = nodeFactory.newRoot()
      child1 = nodeFactory.newNode()
      child2 = nodeFactory.newNode()
      root.addChild('c', child1)
      root.addChild('x', child2)
      location = Location.new(root)
      location.traverseDownChildValue('c')
      expect(location.node.nodeId).to eq child1.nodeId
      location.traverseUp
      expect(location.node.nodeId).to eq root.nodeId
      location.traverseDownChildValue('x')
      expect(location.node.nodeId).to eq child2.nodeId
    end
  end

  context "edge traversal" do
    it "traverse to middle of edge" do
      nodeFactory = NodeFactory.new()
      root = nodeFactory.newRoot()
      child = nodeFactory.newNode()
      child.incomingEdgeStartOffset = 0
      child.incomingEdgeEndOffset = Node::UNSPECIFIED_OFFSET
      dataSource = StringDataSource.new("xabxac")
      root.addChild('x', child)
      location = Location.new(root)
      location.traverseDownChildValue('x')
      expect(location.node.nodeId).to eq (1 + root.nodeId)
      expect(location.onNode).to eq false
      expect(location.incomingEdgeOffset).to eq 1
    end
  end

  context "suffix link traversal" do
    it "follows suffix link" do
      dataSource = StringDataSource.new("abxy")
      nodeFactory = NodeFactory.new()
      root = nodeFactory.newRoot()
      child1 = nodeFactory.newNode()
      root.addChild('a', child1)
      child2 = nodeFactory.newNode()
      root.addChild('b', child2)
      child1.incomingEdgeStartOffset = 0
      child1.incomingEdgeEndOffset = 10
      grandChild1 = nodeFactory.newNode()
      grandChild1.incomingEdgeStartOffset = 2
      grandChild1.incomingEdgeEndOffset = Node::CURRENT_ENDING_OFFSET
      child1.addChild('x', grandChild1)
      grandChild2 = nodeFactory.newNode()
      grandChild2.incomingEdgeStartOffset = 3
      grandChild2.incomingEdgeEndOffset = Node::CURRENT_ENDING_OFFSET
      child2.addChild('x', grandChild2)
      child1.suffixLink = child2
      location = Location.new(root)
      location.traverseDownChildValue('a')
      expect(location.node.nodeId).to eq(child1.nodeId)
      location.traverseDownChildValue('x')
      expect(location.node.nodeId).to eq(grandChild1.nodeId)
      incomingEdgeStart, incomingEdgeEnd = location.traverseUp
      expect(incomingEdgeStart).to eq(2)
      expect(incomingEdgeEnd).to eq(Node::CURRENT_ENDING_OFFSET)
      expect(location.node.nodeId).to eq(child1.nodeId)
      location.traverseSuffixLink()
      expect(location.node.nodeId).to eq(child2.nodeId)
      location.traverseSkipCountDown(dataSource, incomingEdgeStart, incomingEdgeEnd)
      expect(location.node.nodeId).to eq(grandChild2.nodeId)
      location.jumpToNode(grandChild1)
      location.traverseToNextSuffix(dataSource)
      expect(location.node.nodeId).to eq(grandChild2.nodeId)
    end
  end
end