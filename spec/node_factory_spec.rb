require 'rspec'
require_relative '../src/node'
require_relative '../src/node_factory'
require_relative '../src/data/string_data_source'

describe "NodeFactory class" do

  let(:dataSource) { StringDataSource.new "mississippi" }
  let(:nodeFactory) { NodeFactory.new dataSource }
  let(:alphaDataSource) { StringDataSource.new "abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyz" }
  let(:alphaNodeFactory) { NodeFactory.new alphaDataSource }

  describe '#initialize' do
    it "accepts a dataSource" do
      expect(nodeFactory.dataSource).to eq dataSource
    end
  end

  describe '#configure' do
    it "keeps a hash of configuration options for how nodes get built" do
      hash = {
          :generalized_suffix_tree => true,
          :track_character_depth => false
      }
      nodeFactory.setConfiguration(hash)
      configuration = nodeFactory.configuration
      expect(configuration[:generalized_suffix_tree]).to eq hash[:generalized_suffix_tree]
      expect(configuration[:track_character_depth]).to eq hash[:track_character_depth]
    end
  end

  describe "#newRoot" do
    it "creates a new root node with node_id=1" do
      root = nodeFactory.newRoot
      expect(root.nodeId).to eq 1
      expect(root.children.length).to eq 0
      expect(nodeFactory.nextNodeId).to eq 2
    end

    it "resets each time newRoot is called" do
      root1 = nodeFactory.newRoot
      root2 = nodeFactory.newRoot
      expect(root1.nodeId).to eq 1
      expect(root2.nodeId).to eq 1
    end
  end

  describe "#addLeaf" do
    it "adds a leaf node" do
      root = nodeFactory.newRoot
      child = nodeFactory.addLeaf(0, root, 'a', 3)
      aChild = root.children['a']
      expect(aChild).to eq child
      expect(root.children['a'].parent).to eq root
    end
  end

  describe "#splitEdgeAtOffset" do
    it "splits a long edge" do
      root = alphaNodeFactory.newRoot
      level1 = alphaNodeFactory.addLeaf(0, root, 'a', 0)
      expect(level1.parent).to eq root
      expect(level1.incomingEdgeStartOffset).to eq 0
      expect(level1.incomingEdgeEndOffset).to eq Node::CURRENT_ENDING_OFFSET
      level2 = alphaNodeFactory.splitEdgeAt(level1, 26)
      expect(level2.parent).to eq root
      expect(level1.parent).to eq level2
      expect(level2.incomingEdgeStartOffset).to eq 0
      expect(level2.incomingEdgeEndOffset).to eq 25
      expect(level1.incomingEdgeStartOffset).to eq 26
      expect(level1.incomingEdgeEndOffset).to eq Node::CURRENT_ENDING_OFFSET
      level3 = alphaNodeFactory.splitEdgeAt(level1, 29)
      expect(level3.parent).to eq level2
      expect(level2.parent).to eq root
      expect(level3.incomingEdgeStartOffset).to eq 26
      expect(level3.incomingEdgeEndOffset).to eq 28
      expect(level1.incomingEdgeStartOffset).to eq 29
      expect(level1.incomingEdgeEndOffset).to eq Node::CURRENT_ENDING_OFFSET
    end

    it "splits edge and returns that node" do
      root = nodeFactory.newRoot
      child = nodeFactory.addLeaf(0, root, 'm', 0)
      middleNode = nodeFactory.splitEdgeAt(child, 3)
      expect(middleNode.parent).to eq (root)
      expect(middleNode.incomingEdgeStartOffset).to eq 0
      expect(middleNode.incomingEdgeEndOffset).to eq 2
      expect(middleNode.isInternal).to eq true
      expect(child.parent).to eq (middleNode)
      expect(child.incomingEdgeStartOffset).to eq 3
      expect(child.incomingEdgeEndOffset).to eq Node::CURRENT_ENDING_OFFSET
      expect(child.isLeaf).to eq true
    end

    it "splits nodes correctly" do
      root = nodeFactory2.newRoot
      level1 = nodeFactory2.addLeaf(0, root, 'a', 0)
      expect(root.children['a']).to eq level1
      level2 = nodeFactory2.splitEdgeAt(level1, 26)
      expect(root.children['a']).to eq level2
      expect(level2.parent).to eq root
      expect(level2.incomingEdgeStartOffset).to eq 0
      expect(level2.incomingEdgeEndOffset).to eq 25
      expect(level1.parent).to eq level2
      expect(level1.incomingEdgeStartOffset).to eq 26
      expect(level1.incomingEdgeEndOffset).to eq Node::CURRENT_ENDING_OFFSET
    end

    it "handles multiple splits" do
      root2 = nodeFactory2.newRoot
      rLevel1 = nodeFactory2.addLeaf(0, root2, 'a', 0)
      expect(rLevel1.incomingEdgeStartOffset).to eq 0
      expect(rLevel1.incomingEdgeEndOffset).to eq Node::CURRENT_ENDING_OFFSET
      rLevel2 = nodeFactory2.splitEdgeAt(rLevel1, 26)
      expect(rLevel2.children.length).to eq 1
      expect(rLevel2.isInternal).to eq true
      expect(rLevel2.incomingEdgeStartOffset).to eq 0
      expect(rLevel2.incomingEdgeEndOffset).to eq 25
      expect(rLevel1.isLeaf).to eq true
      expect(rLevel1.incomingEdgeStartOffset).to eq 26
      expect(rLevel1.incomingEdgeEndOffset).to eq Node::CURRENT_ENDING_OFFSET
    end

    let(:dataSource2)  { StringDataSource.new("abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyz")}
    let(:nodeFactory2) { NodeFactory.new dataSource2 }
  end
end
