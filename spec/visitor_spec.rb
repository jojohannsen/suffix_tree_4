require 'rspec'
require_relative '../src/location'
require_relative '../src/node'
require_relative '../src/node_factory'
require_relative '../src/data/string_data_source'
require_relative '../src/data/file_data_source'
require_relative '../src/ukkonen_builder'
require_relative '../src/visitor/bfs'
require_relative '../src/visitor/leaf_count_visitor'
require_relative '../src/visitor/value_depth_visitor'
require_relative '../src/visitor/dfs'
require_relative '../src/visitor/node_count_visitor'
require_relative '../src/visitor/suffix_offset_visitor'

describe 'character depth visitor' do

  let (:dataSource) { StringDataSource.new("mississippi") }
  let (:stringNodeFactory) { NodeFactory.new dataSource }
  let (:stringRootNodeId) { stringNodeFactory.nextNodeId }
  let (:fileDataSource) { FileDataSource.new(File.join('spec', 'fixtures', "mississippi.txt")) }
  let (:fileNodeFactory) { NodeFactory.new fileDataSource }

  def verifyValueDepth(root)
    expect(root.valueDepth).to eq (0)
    mChild = root.children['m']
    iChild = root.children['i']
    sChild = root.children['s']
    pChild = root.children['p']
    expect(pChild.valueDepth).to eq (1)
    expect(pChild.children['p'].valueDepth).to eq (Node::LEAF_DEPTH)
    expect(pChild.children['i'].valueDepth).to eq (Node::LEAF_DEPTH)
    expect(mChild.valueDepth).to eq (Node::LEAF_DEPTH)
    expect(iChild.valueDepth).to eq (1)
    expect(iChild.children['p'].valueDepth).to eq (Node::LEAF_DEPTH)
    isChild = iChild.children['s']
    expect(isChild.valueDepth).to eq (4)
    expect(isChild.children['s'].valueDepth).to eq(Node::LEAF_DEPTH)
    expect(isChild.children['p'].valueDepth).to eq(Node::LEAF_DEPTH)
    expect(sChild.valueDepth).to eq (1)
    siChild = sChild.children['i']
    ssChild = sChild.children['s']
    expect(siChild.valueDepth).to eq (2)
    expect(ssChild.valueDepth).to eq (3)
    expect(siChild.children['p'].valueDepth).to eq(Node::LEAF_DEPTH)
    expect(siChild.children['s'].valueDepth).to eq(Node::LEAF_DEPTH)
    expect(ssChild.children['s'].valueDepth).to eq(Node::LEAF_DEPTH)
    expect(ssChild.children['p'].valueDepth).to eq(Node::LEAF_DEPTH)
  end

  context "DFS traversal" do
    it "sets character depth using depth first traversal" do
      hash = {
          :valueDepth => true
      }
      stringNodeFactory.setConfiguration hash
      builder = UkkonenBuilder.new stringNodeFactory
      builder.addSourceValues
      cdv = DFS.new(ValueDepthVisitor.new)
      cdv.traverse(builder.root)
      self.verifyValueDepth(builder.root)
    end
  end

  context "BFS traversal" do
    it "sets character depth using breadth first traversal" do
      builder = UkkonenBuilder.new stringNodeFactory.setConfiguration( { :valueDepth => true })
      builder.addSourceValues
      cdv = BFS.new(ValueDepthVisitor.new)
      cdv.traverse(builder.root)
      self.verifyValueDepth(builder.root)
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
      hash = {
          :leafCount => true
      }
      stringNodeFactory.setConfiguration hash
      builder = UkkonenBuilder.new stringNodeFactory
      builder.addSourceValues
      self.verifyLeafCount(builder)
    end
  end

  context "DFS traversal" do
    it "sets leaf count for suffix tree loaded from file" do
      hash = {
          :leafCount => true
      }
      fileNodeFactory.setConfiguration hash
      builder = UkkonenBuilder.new fileNodeFactory
      builder.addSourceValues
      self.verifyLeafCount(builder)
    end
  end

  def verifyNodeCount(dataSource)
    builder = UkkonenBuilder.new fileNodeFactory
    builder.addSourceValues
    ncv = NodeCountVisitor.new
    bt = DFS.new(ncv)
    bt.traverse(builder.root)
    expect(ncv.count).to eq (17)
  end

  context "Count nodes" do
    it "counts nodes with DFS traversal of file data source" do
      verifyNodeCount(fileDataSource)
    end
  end

  context "Count nodes" do
    it "counts nodes with DFS traversal of string data source" do
      verifyNodeCount(dataSource)
    end
  end

  context "collect suffix offsets" do
    it "traverses suffix tree and collects suffix offsets" do
      soCollector = SuffixOffsetVisitor.new
      so = BFS.new(soCollector)
      builder = UkkonenBuilder.new stringNodeFactory
      builder.addSourceValues
      so.traverse(builder.root)
      expect(soCollector.result.sort).to eq ([ 0, 1, 2, 3, 4, 5, 6, 7, 8, 9 ])
    end
  end
end