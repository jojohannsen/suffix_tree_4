# suffix_tree_4

This is a Ruby library for creating suffix trees one value at a time.

Since some algorithms require additional Node properties, such as "leaf count", "previous value at leaf", 
"value depth", the NodeFactory allows dynamic addition of attributes to the Node class, and these values are
used if configuration allows it.

The libraries builds suffix trees one value at a time, there is no need to provide all values at once.

Depth first and breadth first traversal algorithms are provided to allow different algorithms to be 
implemented by providing only a Visitor instance to the traversal algorithms.  Algorithm specific
properties are set during tree construction when possible.  Otherwise Visitor instances are 
provided for setting properties (like "leafCount" property) that only make sense to set after the
tree is constructed.

