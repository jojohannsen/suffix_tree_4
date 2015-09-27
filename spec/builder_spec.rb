require 'rspec'
require_relative '../src/location'
require_relative '../src/node'
require_relative '../src/data/string_data_source'
require_relative '../src/data/word_data_source'
require_relative '../src/ukkonen_builder'
require_relative '../src/visitor/dfs'
require_relative '../src/visitor/leaf_count_visitor'
require_relative '../src/visitor/value_depth_visitor'

describe 'Suffix tree builder' do

  context "basic tree" do
    it "builds tree with one leaf" do
      dataSource = StringDataSource.new("a")
      nodeFactory = NodeFactory.new dataSource
      builder = UkkonenBuilder.new nodeFactory
      builder.add('a', 0)
      expect(builder.root.children.length).to eq (1)
      location = builder.location
      expect(location.onNode).to eq (true)
      expect(location.node).to eq(builder.root)
    end
  end

  context "two char tree" do
    it "builds tree with two leaf" do
      dataSource = StringDataSource.new("ab")
      nodeFactory = NodeFactory.new dataSource
      builder = UkkonenBuilder.new nodeFactory
      builder.add('a', 0)
      expect(builder.root.children.length).to eq (1)
      child1 = builder.root.children['a']
      expect(child1.suffixOffset).to eq(0)
      builder.add('b', 1)
      expect(builder.root.children.length).to eq (2)
      child2 = builder.root.children['b']
      expect(child2.suffixOffset).to eq(1)
      location = builder.location
      expect(location.onNode).to eq (true)
      expect(location.node).to eq(builder.root)
    end
  end

  context "mississippi" do
    it "builds mississippi tree" do
      dataSource = StringDataSource.new("mississippi")
      nodeFactory = NodeFactory.new dataSource
      rootNodeId = nodeFactory.nextNodeId
      builder = UkkonenBuilder.new nodeFactory
      suffix0_nodeId = nodeFactory.nextNodeId
      builder.add('m', 0)
      expect(nodeFactory.nextNodeId).to eq (suffix0_nodeId + 1)
      location = builder.location
      expect(location.onNode).to eq (true)
      expect(location.node.nodeId).to eq (rootNodeId)
      suffix1_nodeId = nodeFactory.nextNodeId
      builder.add('i', 1)
      expect(nodeFactory.nextNodeId).to eq (suffix1_nodeId + 1)
      expect(location.onNode).to eq (true)
      expect(location.node.nodeId).to eq (rootNodeId)
      suffix2_nodeId = nodeFactory.nextNodeId
      builder.add('s', 2)
      expect(nodeFactory.nextNodeId).to eq (suffix2_nodeId + 1)
      expect(location.onNode).to eq (true)
      expect(location.node.nodeId).to eq (rootNodeId)
      builder.add('s', 3)
      rootSchild = builder.root.children['s']
      expect(rootSchild.nodeId).to eq (suffix2_nodeId)
      expect(rootSchild.incomingEdgeStartOffset).to eq(2)
      expect(rootSchild.incomingEdgeEndOffset).to eq(Node::CURRENT_ENDING_OFFSET)
      expect(location.onNode).to eq (false)
      expect(location.incomingEdgeOffset).to eq (3)
      # we should not have added any node at this point
      expect(nodeFactory.nextNodeId).to eq (suffix2_nodeId + 1)
      builder.add('i', 4)
      # should have added an internal node and a leaf node
      # internal node should be the 's' child of root, with a suffix link pointing to root
      rootSchild = builder.root.children['s']
      expect(rootSchild.suffixLink).not_to eq (nil)
      expect(rootSchild.suffixLink).to eq(builder.root)
      expect(nodeFactory.nextNodeId).to eq (suffix2_nodeId + 3)
      expect(location.onNode).to eq (false)
      expect(location.node.nodeId).to eq (suffix1_nodeId)
      expect(location.incomingEdgeOffset).to eq (2)
      rootSchild = builder.root.children['s']
      expect(rootSchild.incomingEdgeStartOffset).to eq(2)
      expect(rootSchild.incomingEdgeEndOffset).to eq(2)
      expect(rootSchild.nodeId).to eq (suffix2_nodeId + 1)
      suffix3_nodeId = suffix2_nodeId + 2
      currentNextNodeId = nodeFactory.nextNodeId
      currentLocationNodeId = location.node.nodeId
      # these next 3 should not should only update the location incomingEdgeOffset
      builder.add('s', 5)
      expect(location.incomingEdgeOffset).to eq (3)
      expect(location.onNode).to eq (false)
      expect(location.node.nodeId).to eq (currentLocationNodeId)
      expect(nodeFactory.nextNodeId).to eq(currentNextNodeId)
      builder.add('s', 6)
      expect(location.incomingEdgeOffset).to eq (4)
      expect(location.onNode).to eq (false)
      expect(location.node.nodeId).to eq (currentLocationNodeId)
      expect(nodeFactory.nextNodeId).to eq(currentNextNodeId)
      builder.add('i', 7)
      expect(location.incomingEdgeOffset).to eq (5)
      expect(location.onNode).to eq (false)
      expect(location.node.nodeId).to eq (currentLocationNodeId)
      expect(nodeFactory.nextNodeId).to eq(currentNextNodeId)
      result = builder.extend('p', 8)
      expect(result).to eq (true)
      expect(location.onNode).to eq(true)
      slNode = location.node
      expect(slNode.suffixLink).to eq(nil)
      result = builder.extend('p', 8)
      expect(result).to eq (true)
      expect(location.onNode).to eq(false)
      result = builder.extend('p', 8)
      expect(result).to eq (true)
      expect(location.onNode).to eq(true)
      expect(slNode.suffixLink).not_to eq(nil)
      result = builder.extend('p', 8)
      expect(result).to eq (true)
      expect(location.onNode).to eq(false)
      result = builder.extend('p', 8)
      expect(result).to eq (true)
      expect(location.onNode).to eq(true)
      result = builder.extend('p', 8)
      expect(result).to eq (true)
      expect(location.onNode).to eq(false)
      result = builder.extend('p', 8)
      expect(result).to eq (true)
      expect(location.onNode).to eq(true)
      result = builder.extend('p', 8)
      expect(result).to eq (true)
      expect(location.onNode).to eq(true)
      result = builder.extend('p', 8)
      expect(result).to eq (false)
      expect(location.onNode).to eq(true)

      expect(builder.root.children['i'].children['s'].nodeId).to eq (suffix3_nodeId + 1)
      expect(builder.root.children['i'].children['s'].children['p'].nodeId).to eq (suffix3_nodeId + 2)
      expect(builder.root.children['i'].children['s'].children['s'].nodeId).to eq (suffix1_nodeId)
      expect(nodeFactory.nextNodeId).to eq (suffix3_nodeId + 10)
      # here we made 10 nodes, have to make sure they are all ok
      suffix4_nodeId = suffix3_nodeId + 2
      builder.add('p', 9)
      expect(location.onNode).to eq (false)
      expect(location.node.nodeId).to eq (nodeFactory.nextNodeId - 1)
      expect(location.incomingEdgeOffset).to eq(9)
      firstPnodeId = nodeFactory.nextNodeId - 1
      builder.add('i', 10)
      expect(location.onNode).to eq (true)
      expect(location.node.nodeId).to eq (13)
      expect(nodeFactory.nextNodeId).to eq(firstPnodeId + 3)
    end
  end

  describe "using word data source" do
    it "builds suffix tree of words" do
      wordDataSource = WordDataSource.new File.join('spec', 'fixtures', "chapter1.txt")
      nodeFactory = NodeFactory.new wordDataSource
      nodeFactory.setConfiguration( { :leafCount => true, :valueDepth => true })
      builder = UkkonenBuilder.new nodeFactory
      builder.addSourceValues
      root = builder.root
      expect(root.nodeId).to eq 1
      lcv = DFS.new(LeafCountVisitor.new)
      lcv.traverse(builder.root)
      deepVal = DeepestValueDepthVisitor.new
      dfs = DFS.new(deepVal)
      dfs.traverse(builder.root)
      expect(nodeFactory.valuePath(deepVal.deepestValueDepthNode)).to eq "my father s thumb"
    end
  end
end