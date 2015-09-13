require 'rspec'
require_relative '../src/location'
require_relative '../src/node'
require_relative '../src/node_factory'
require_relative '../src/string_data_source'
require_relative '../src/ukkonen_builder'
require_relative '../src/visitor/character_depth_visitor'
require_relative '../src/visitor/dfs'
require_relative '../src/visitor/bfs'
require_relative '../src/visitor/leaf_count_visitor'

describe 'character depth visitor' do

  context "child traversal" do
    it "visitor works with DFS" do
      nodeFactory = NodeFactory.new()
      dataSource = StringDataSource.new("mississippi")
      nodeFactory = NodeFactory.new
      rootNodeId = nodeFactory.nextNodeId
      builder = UkkonenBuilder.new(dataSource, nodeFactory)
      builder.addSource(dataSource)
      cdv = DFS.new(CharacterDepthVisitor.new)
      cdv.traverse(builder.root)
      expect(builder.root.characterDepth).to eq (0)
      mChild = builder.root.children['m']
      iChild = builder.root.children['i']
      sChild = builder.root.children['s']
      pChild = builder.root.children['p']
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
  end

  context "child traversal" do
    it "same visitor works with BFS" do
      nodeFactory = NodeFactory.new()
      dataSource = StringDataSource.new("mississippi")
      nodeFactory = NodeFactory.new
      rootNodeId = nodeFactory.nextNodeId
      builder = UkkonenBuilder.new(dataSource, nodeFactory)
      builder.addSource(dataSource)
      cdv = BFS.new(CharacterDepthVisitor.new)
      cdv.traverse(builder.root)
      expect(builder.root.characterDepth).to eq (0)
      mChild = builder.root.children['m']
      iChild = builder.root.children['i']
      sChild = builder.root.children['s']
      pChild = builder.root.children['p']
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
  end

  context "child traversal" do
    it "DFS leaf count" do
      nodeFactory = NodeFactory.new()
      dataSource = StringDataSource.new("mississippi")
      nodeFactory = NodeFactory.new
      rootNodeId = nodeFactory.nextNodeId
      builder = UkkonenBuilder.new(dataSource, nodeFactory)
      builder.addSource(dataSource)
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
  end
end