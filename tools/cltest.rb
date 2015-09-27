require_relative '../src/data/word_data_source'
require_relative '../src/node_factory'
require_relative '../src/ukkonen_builder'
require_relative '../src/visitor/dfs'
require_relative '../src/visitor/leaf_count_visitor'

wordDataSource = WordDataSource.new File.join('spec', 'fixtures', "chapter1.txt")
nodeFactory = NodeFactory.new wordDataSource
nodeFactory.setConfiguration( { :leafCount => true, :valueDepth => true })
builder = UkkonenBuilder.new nodeFactory
builder.addSourceValues
root = builder.root
lcv = DFS.new(LeafCountVisitor.new)
lcv.traverse(builder.root)
topLcv = TopLeafCountVisitor.new
lcvt = DFS.new(topLcv)
lcvt.traverse(builder.root)
deepestValueDepthNode = topLcv.deepestValueDepthNode
print "deepestValueDepthNode is #{deepestValueDepthNode.nodeId}\n"
vp = nodeFactory.valuePath(deepestValueDepthNode)
print "valuePath: #{vp}\n"