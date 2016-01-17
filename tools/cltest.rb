require_relative '../src/data/word_data_source'
require_relative '../src/node_factory'
require_relative '../src/suffix_tree'
require_relative '../src/visitor/dfs'
require_relative '../src/visitor/leaf_count_visitor'
require_relative '../src/visitor/value_depth_visitor'

wordDataSource = WordDataSource.new File.join('spec', 'fixtures', "chapter1.txt")
st = SuffixTree.new(nil,  { :leafCount => true, :valueDepth => true })
st.addDataSource(wordDataSource)
lcv = DFS.new(LeafCountVisitor.new)
lcv.traverse(st.root)
dvdv = DeepestValueDepthVisitor.new
lcvt = DFS.new(dvdv)
lcvt.traverse(st.root)
deepestValueDepthNode = dvdv.deepestValueDepthNode
print "deepestValueDepthNode is #{deepestValueDepthNode.nodeId}\n"
vp = st.nodeFactory.valuePath(deepestValueDepthNode)
print "valuePath: #{vp}\n"