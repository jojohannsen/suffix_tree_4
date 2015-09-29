# suffix_tree_4

This is a Ruby library for creating suffix trees using Ukkonen's algorithm.

## Why another library for suffix trees?

This library has a couple advantages I could not get with other libraries:

1. It makes the suffix tree "on-the-fly" as data values are fed to it.  The data values can be of any type.
2. Breadth-first or depth-first tree traversal framework allows different algorithms (like "longest string common to K strings") to be implemented with a single method.

## What are suffix trees good for?

Suffix trees allow linear time solutions to messy large data problems.  Very large data sets can be compared with very simple algorithms.  Any all instances of any sequence of values can be found in time proportional to the length of the sequence.  In practice this means any large data sets that can be converted into a sequence of values can be compared with each other with a minimum of effort.

## What does the code look like?

Here's an example problem.  Given some text, what is the longest sequence of words used two or more times?

```ruby
wordDataSource = WordDataSource.new "book.txt"
nodeFactory = NodeFactory.new wordDataSource
nodeFactory.setConfiguration( { :valueDepth => true }
builder = UkkonenBuilder.new nodeFactory
builder.addSourceValues
```

At this point, the suffix tree has been created using "word" values, and each tree node has a "valueDepth" property.  The internal node with the greatest "valueDepth" represents the longest sequence of words used two or more times.

```ruby
deepVal = DeepestValueDepthVisitor.new
dfs = DFS.new(deepVal)
dfs.traverse(builder.root)
print "#{nodeFactory.valuePath(deepVal.deepestValueDepthNode,' ')\n"
```

The code above visits all nodes, saves the "deepestValueDepthNode", and prints out the phrase.

The visitor that does this has very little code, the main code is just 4 lines in "postVisit".

```ruby
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
```

## Why are the visitors important?

The visitors are the components that implement pieces of algorithms.  Some algorithms need value depth, others need which sequences created which nodes (generalized suffix trees).  

In many cases, the information needed by an algorithm can be calculated on-the-fly, but in other cases the entire tree must exist before any calculation can take place.  The visitors handle this 'post-construction' data collection needed by algorithms.

For example, the "longest substring common to K strings" is implemented by creating a tree that records "valueDepth" of each node:

```ruby
nodeFactory.setConfiguration( { :valueDepth => true }
```

followed by a KCommonVisitor traversal of the tree, which collects the deepest depth for sequences of length 2 to 64 (configurable max).  The additional code to get this after the tree is constructed:

```ruby
builder.newDataSource s2
builder.addSourceValues
builder.newDataSource s3
builder.addSourceValues
builder.newDataSource s4
builder.addSourceValues
builder.newDataSource s5
builder.addSourceValues
```

The above code adds data from different data sources to the suffix tree.

```ruby
dataSourceVisitor = DataSourceVisitor.new
dfs = DFS.new(dataSourceVisitor)
dfs.traverse(builder.root)
kCommonVisitor = KCommonVisitor.new(s1)
dfs = DFS.new(kCommonVisitor)
dfs.traverse(builder.root)
longestLength,sample = kCommonVisitor.longestStringCommonTo(2)
```

The above code traverses the tree to identify the data source that is associated with each node, then traverses the tree again to get the length of the longest string common to N=2..64 samples.  Calculation time is linear, proportional to size of data.
