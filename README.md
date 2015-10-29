# suffix_tree_4

This is a Ruby library for creating suffix trees one value at a time.

Since some algorithms require specific Node properties, such as "leaf count", "previous value at leaf",
"value depth", the NodeFactory allows dynamic addition of attributes to the Node class, and these values are
used if configuration allows it.

## How to build a Suffix Tree of values

1. Create a DataSource that provides the sequence of values
2. Create a SuffixTree, and add the data source to the tree
3. Create whatever visitor implements the algorithm

Here's an example that builds a suffix tree of words and finds the phrase repeated most in that text, in linear time.
This example is taken from one of the unit tests.

1. Create a Data source containing just words:

    wordDataSource = WordDataSource.new File.join('spec', 'fixtures', "chapter1.txt")

2. Create a suffix tree from that data source, with Node properties needed for solving this sort of problem.

    st = SuffixTree.new(nil, { :leafCount => true, :valueDepth => true })
    st.addDataSource(wordDataSource)

3. Traverse the tree with a visitor that solves the problem.  The DFS is a generic depth-first visitor.

    lcv = DFS.new(LeafCountVisitor.new)
    lcv.traverse(st.root)
    deepVal = DeepestValueDepthVisitor.new
    dfs = DFS.new(deepVal)
    dfs.traverse(st.root)

Once these are done, the answer is in the "deepVal" visitor.  Here is the check in the test:

    expect(st.nodeFactory.valuePath(deepVal.deepestValueDepthNode)).to eq "my father s thumb"

The nice thing about this approach is that dozens of complex problems can be solved in linear time with
just a simple visitor.  The rest, building the suffix tree using values of any data type, can be used unchanged.

For example, the DeepestValueDepthVisitor source is just this:

class DeepestValueDepthVisitor < BaseVisitor
  attr_reader :deepestValueDepth, :deepestValueDepthNode

  def initialize
    @deepestValueDepthNode = nil
    @deepestValueDepth = 0
    super
  end

  def postVisit(node)
    if (node.valueDepth > @deepestValueDepth) then
      @deepestValueDepth = node.valueDepth
      @deepestValueDepthNode = node
    end
  end
end