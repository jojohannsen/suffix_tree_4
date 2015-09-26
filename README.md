# suffix_tree_4

This is a Ruby library for creating suffix trees one value at a time.

Since some algorithms require additional Node properties, such as "leaf count", "previous value at leaf", 
"value depth", the NodeFactory allows dynamic addition of attributes to the Node class, and these values are
used if configuration allows it.

## How to build a Suffix Tree of values

1. Create a data source
2. Configure the NodeFactory
3. Create the UkkonenBuilder

See builder_spec.rb for details
