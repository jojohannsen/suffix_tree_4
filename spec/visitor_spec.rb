require 'rspec'
require_relative '../src/location'
require_relative '../src/node'
require_relative '../src/node_factory'
require_relative '../src/data/string_data_source'
require_relative '../src/data/file_data_source'
require_relative '../src/ukkonen_builder'
require_relative '../src/visitor/character_depth_visitor'
require_relative '../src/visitor/dfs'
require_relative '../src/visitor/bfs'
require_relative '../src/visitor/leaf_count_visitor'

describe 'character depth visitor' do
  let (:nodeFactory) { NodeFactory.new }
  let (:dataSource) { StringDataSource.new("mississippi") }
  let (:rootNodeId) { nodeFactory.nextNodeId }
  let (:fileDataSource) { FileDataSource.new(File.join('spec', 'fixtures', "mississippi.txt")) }

  def verifyCharacterDepth(root)
    expect(root.characterDepth).to eq (0)
    mChild = root.children['m']
    iChild = root.children['i']
    sChild = root.children['s']
    pChild = root.children['p']
    expect(pChild.characterDepth).to eq (1)
    expect(pChild.children['p'].characterDepth).to eq (Node::LEAF_DEPTH)
    expect(pChild.children['i'].characterDepth).to eq (Node::LEAF_DEPTH)
    expect(mChild.characterDepth).to eq (Node::LEAF_DEPTH)
    expect(iChild.characterDepth).to eq (1)
    expect(iChild.children['p'].characterDepth).to eq (Node::LEAF_DEPTH)
    isChild = iChild.children['s']
    expect(isChild.characterDepth).to eq (4)
    expect(isChild.children['s'].characterDepth).to eq(Node::LEAF_DEPTH)
    expect(isChild.children['p'].characterDepth).to eq(Node::LEAF_DEPTH)
    expect(sChild.characterDepth).to eq (1)
    siChild = sChild.children['i']
    ssChild = sChild.children['s']
    expect(siChild.characterDepth).to eq (2)
    expect(ssChild.characterDepth).to eq (3)
    expect(siChild.children['p'].characterDepth).to eq(Node::LEAF_DEPTH)
    expect(siChild.children['s'].characterDepth).to eq(Node::LEAF_DEPTH)
    expect(ssChild.children['s'].characterDepth).to eq(Node::LEAF_DEPTH)
    expect(ssChild.children['p'].characterDepth).to eq(Node::LEAF_DEPTH)
  end

  context "DFS traversal" do
    it "sets character depth using depth first traversal" do
      builder = UkkonenBuilder.new(dataSource, nodeFactory)
      builder.addSourceValues
      cdv = DFS.new(CharacterDepthVisitor.new)
      cdv.traverse(builder.root)
      self.verifyCharacterDepth(builder.root)
    end
  end

  context "BFS traversal" do
    it "sets character depth using breadth first traversal" do
      builder = UkkonenBuilder.new(dataSource, nodeFactory)
      builder.addSourceValues
      cdv = BFS.new(CharacterDepthVisitor.new)
      cdv.traverse(builder.root)
      self.verifyCharacterDepth(builder.root)
    end
  end

  def verifyLeafCount(builder)
    lcv = DFS.new(LeafCountVisitor.new)
    lcv.traverse(builder.root)
    expect(builder.root.leafCount).to eq (10)  # final 'i' is implicit
    mChild = builder.root.children['m']
    iChild = builder.root.children['i']
    sChild = builder.root.children['s']
    pChild = builder.root.children['p']
    expect(mChild.leafCount).to eq (1)
    expect(iChild.leafCount).to eq (3)
    expect(sChild.leafCount).to eq (4)
    expect(pChild.leafCount).to eq (2)
  end

  context "DFS traversal" do
    it "sets leaf count for suffix tree created from string" do
      builder = UkkonenBuilder.new(dataSource, nodeFactory)
      builder.addSourceValues
      self.verifyLeafCount(builder)
    end
  end

  context "DFS traversal" do
    it "sets leaf count for suffix tree loaded from file" do
      builder = UkkonenBuilder.new(fileDataSource, nodeFactory)
      builder.addSourceValues
      self.verifyLeafCount(builder)
    end
  end
end