require 'rspec'
require_relative '../src/location'
require_relative '../src/node'
require_relative '../src/node_factory'
require_relative '../src/data/string_data_source'
require_relative '../src/data/file_data_source'
require_relative '../src/suffix_tree'
require_relative '../src/visitor/bfs'
require_relative '../src/visitor/data_source_visitor'
require_relative '../src/visitor/k_common_visitor'
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
      st = SuffixTree.new(nil, hash)
      st.addDataSource(dataSource)

      cdv = DFS.new(ValueDepthVisitor.new)
      cdv.traverse(st.root)
      self.verifyValueDepth(st.root)
    end
  end

  context "BFS traversal" do
    it "sets character depth using breadth first traversal" do
      st = SuffixTree.new(nil, { :valueDepth => true })
      st.addDataSource(dataSource)
      cdv = BFS.new(ValueDepthVisitor.new)
      cdv.traverse(st.root)
      self.verifyValueDepth(st.root)
    end
  end

  def verifyLeafCount(root)
    lcv = DFS.new(LeafCountVisitor.new)
    lcv.traverse(root)
    expect(root.leafCount).to eq (10)  # final 'i' is implicit
    mChild = root.children['m']
    iChild = root.children['i']
    sChild = root.children['s']
    pChild = root.children['p']
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
      st = SuffixTree.new(nil, hash)
      st.addDataSource(dataSource)
      self.verifyLeafCount(st.root)
    end
  end

  context "DFS traversal" do
    it "sets leaf count for suffix tree loaded from file" do
      hash = {
          :leafCount => true
      }
      st = SuffixTree.new(nil, hash)
      st.addDataSource(fileDataSource)
      self.verifyLeafCount(st.root)
    end
  end

  def verifyNodeCount(dataSource)
    st = SuffixTree.new(nil, nil)
    st.addDataSource(fileDataSource)
    ncv = NodeCountVisitor.new
    bt = DFS.new(ncv)
    bt.traverse(st.root)
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
      st = SuffixTree.new(nil, nil)
      st.addDataSource(dataSource)
      so.traverse(st.root)
      expect(soCollector.result.sort).to eq ([ 0, 1, 2, 3, 4, 5, 6, 7, 8, 9 ])
    end
  end

  describe "generalized suffix tree" do
    let(:s1) { StringDataSource.new "sandollar" }
    let(:s2) { StringDataSource.new "sandlot" }
    let(:s3) { StringDataSource.new "handler" }
    let(:s4) { StringDataSource.new "grand" }
    let(:s5) { StringDataSource.new "pantry" }

    it "KCommonVisitor finds longest substring common to k strings" do
      # make the generalized suffix tree
      st = SuffixTree.new("$", {:valueDepth => true, :dataSourceBit => true})
      st.addDataSource(s1)
      st.addDataSource(s2)
      st.addDataSource(s3)
      st.addDataSource(s4)
      st.addDataSource(s5)

      dataSourceVisitor = DataSourceVisitor.new
      dfs = DFS.new(dataSourceVisitor)
      dfs.traverse(st.root)
      kCommonVisitor = KCommonVisitor.new(s1)
      dfs = DFS.new(kCommonVisitor)
      dfs.traverse(st.root)
      longestLength,sample = kCommonVisitor.longestStringCommonTo(2)
      expect(longestLength).to eq 4
      expect(sample).to eq "sand"
      longestLength,sample = kCommonVisitor.longestStringCommonTo(3)
      expect(longestLength).to eq 3
      expect(sample).to eq "and"
      longestLength,sample = kCommonVisitor.longestStringCommonTo(4)
      expect(longestLength).to eq 3
      expect(sample).to eq "and"
      longestLength,sample = kCommonVisitor.longestStringCommonTo(5)
      expect(longestLength).to eq 2
      expect(sample).to eq "an"
    end
  end
end