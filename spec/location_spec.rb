require 'rspec'
require_relative '../src/location'
require_relative '../src/node'
require_relative '../src/node_factory'
require_relative '../src/data/string_data_source'

describe 'Location class' do

  let(:nodeFactory) { NodeFactory.new }
  let(:root) { nodeFactory.newRoot }
  let(:testNode) { nodeFactory.newNode }
  let(:testNode2) { nodeFactory.newNode }

  describe "#new" do
    it "starts at a node" do
      location = Location.new(testNode)
      expect(location.node).to eq testNode
      expect(location.onNode).to eq true
      expect(location.incomingEdgeOffset).to eq Node::UNSPECIFIED_OFFSET
    end
  end

  describe "#traverseDownChildValue" do
    it "ends on child node if child edge has one value" do
      testNode.addChild('c', testNode2)
      location = Location.new(testNode)
      testNode2.incomingEdgeStartOffset = testNode2.incomingEdgeEndOffset = 3
      location.traverseDownChildValue('c')
      expect(location.node).to eq testNode2
      expect(location.onNode).to eq true
      expect(location.incomingEdgeOffset).to eq Node::UNSPECIFIED_OFFSET
    end

    it "ends on second character of child edge when that edge has more than one value" do
      testNode.addChild('c', testNode2)
      location = Location.new(testNode)
      testNode2.incomingEdgeStartOffset = 1
      testNode2.incomingEdgeEndOffset = 3
      location.traverseDownChildValue('c')
      expect(location.node).to eq testNode2
      expect(location.onNode).to eq false
      expect(location.incomingEdgeOffset).to eq 2
    end
  end

  context "child traversal" do
    it "traverses to leaf child" do
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