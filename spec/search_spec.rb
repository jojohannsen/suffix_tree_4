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
require_relative '../src/search/searcher'

describe "Search class" do

  let (:dataSource) { StringDataSource.new("mississippi") }
  let (:nodeFactory) { NodeFactory.new dataSource }
  let (:rootNodeId) { nodeFactory.nextNodeId }
  let (:fileDataSource) { FileDataSource.new(File.join('spec', 'fixtures', "mississippi.txt")) }
  let (:fileNodeFactory) { NodeFactory.new fileDataSource }

  describe '#find' do

    it 'finds all substrings' do
      hash = {
          :valueDepth => true
      }
      nodeFactory.setConfiguration(hash)
      builder = UkkonenBuilder.new nodeFactory
      builder.addSourceValues
      searcher = Searcher.new(dataSource, builder.root)
      expect(searcher.find("m")).to eq ([0])
      expect(searcher.find("i")).to eq ([1,4,7])
      expect(searcher.find("s")).to eq ([2,3,5,6])
      expect(searcher.find("p")).to eq ([8,9])
      expect(searcher.find("x")).to eq ([])
      expect(searcher.find("mi")).to eq ([0])
      expect(searcher.find("is")).to eq ([1,4])
      expect(searcher.find("ss")).to eq ([2,5])
      expect(searcher.find("si")).to eq ([3,6])
      expect(searcher.find("ip")).to eq ([7])
      expect(searcher.find("pp")).to eq ([8])
      expect(searcher.find("pi")).to eq ([9])
      expect(searcher.find("mis")).to eq ([0])
      expect(searcher.find("iss")).to eq ([1,4])
      expect(searcher.find("ssi")).to eq ([2,5])
      expect(searcher.find("ssx")).to eq ([])
      expect(searcher.find("sis")).to eq ([3])
      expect(searcher.find("sip")).to eq ([6])
      expect(searcher.find("ipp")).to eq ([7])
      expect(searcher.find("ppi")).to eq ([8])
      expect(searcher.find("miss")).to eq ([0])
      expect(searcher.find("issi")).to eq ([1,4])
      expect(searcher.find("ssis")).to eq ([2])
      expect(searcher.find("siss")).to eq ([3])
      expect(searcher.find("ssip")).to eq ([5])
      expect(searcher.find("sipp")).to eq ([6])
      expect(searcher.find("ippi")).to eq ([7])
      expect(searcher.find("missi")).to eq ([0])
      expect(searcher.find("issis")).to eq ([1])
      expect(searcher.find("ssiss")).to eq ([2])
      expect(searcher.find("sissi")).to eq ([3])
      expect(searcher.find("issip")).to eq ([4])
      expect(searcher.find("ssipp")).to eq ([5])
      expect(searcher.find("sippi")).to eq ([6])
      expect(searcher.find("missis")).to eq ([0])
      expect(searcher.find("ississ")).to eq ([1])
      expect(searcher.find("ssissi")).to eq ([2])
      expect(searcher.find("sissip")).to eq ([3])
      expect(searcher.find("issipp")).to eq ([4])
      expect(searcher.find("ssippi")).to eq ([5])
      expect(searcher.find("mississ")).to eq ([0])
      expect(searcher.find("ississi")).to eq ([1])
      expect(searcher.find("ssissip")).to eq ([2])
      expect(searcher.find("sissipp")).to eq ([3])
      expect(searcher.find("issippi")).to eq ([4])
      expect(searcher.find("mississi")).to eq ([0])
      expect(searcher.find("ississip")).to eq ([1])
      expect(searcher.find("ssissipp")).to eq ([2])
      expect(searcher.find("sissippi")).to eq ([3])
      expect(searcher.find("mississip")).to eq ([0])
      expect(searcher.find("ississipp")).to eq ([1])
      expect(searcher.find("ssissippi")).to eq ([2])
      expect(searcher.find("ssissippix")).to eq ([])
      expect(searcher.find("mississipp")).to eq ([0])
      expect(searcher.find("ississippi")).to eq ([1])
      expect(searcher.find("mississippi")).to eq ([0])
    end

    it 'finds all substrings' do
      fileNodeFactory.setConfiguration( { :valueDepth => true })
      builder = UkkonenBuilder.new fileNodeFactory
      builder.addSourceValues
      builder.addValue('m')
      builder.addValue('i')
      builder.addValue('$')
      searcher = Searcher.new(dataSource, builder.root)
      expect(searcher.find("m")).to eq ([0,11])         # 2 m's now
      expect(searcher.find("i")).to eq ([1,4,7,10,12])  # final "i" of mississippi now explicit, and there's another as well
      expect(searcher.find("s")).to eq ([2,3,5,6])
      expect(searcher.find("p")).to eq ([8,9])
      expect(searcher.find("x")).to eq ([])
      expect(searcher.find("mi")).to eq ([0,11])        # "mi" is now at end as well
      expect(searcher.find("is")).to eq ([1,4])
      expect(searcher.find("ss")).to eq ([2,5])
      expect(searcher.find("si")).to eq ([3,6])
      expect(searcher.find("ip")).to eq ([7])
      expect(searcher.find("pp")).to eq ([8])
      expect(searcher.find("pi")).to eq ([9])
      expect(searcher.find("mis")).to eq ([0])
      expect(searcher.find("iss")).to eq ([1,4])
      expect(searcher.find("ssi")).to eq ([2,5])
      expect(searcher.find("ssx")).to eq ([])
      expect(searcher.find("sis")).to eq ([3])
      expect(searcher.find("sip")).to eq ([6])
      expect(searcher.find("ipp")).to eq ([7])
      expect(searcher.find("ppi")).to eq ([8])
      expect(searcher.find("miss")).to eq ([0])
      expect(searcher.find("issi")).to eq ([1,4])
      expect(searcher.find("ssis")).to eq ([2])
      expect(searcher.find("siss")).to eq ([3])
      expect(searcher.find("ssip")).to eq ([5])
      expect(searcher.find("sipp")).to eq ([6])
      expect(searcher.find("ippi")).to eq ([7])
      expect(searcher.find("missi")).to eq ([0])
      expect(searcher.find("issis")).to eq ([1])
      expect(searcher.find("ssiss")).to eq ([2])
      expect(searcher.find("sissi")).to eq ([3])
      expect(searcher.find("issip")).to eq ([4])
      expect(searcher.find("ssipp")).to eq ([5])
      expect(searcher.find("sippi")).to eq ([6])
      expect(searcher.find("missis")).to eq ([0])
      expect(searcher.find("ississ")).to eq ([1])
      expect(searcher.find("ssissi")).to eq ([2])
      expect(searcher.find("sissip")).to eq ([3])
      expect(searcher.find("issipp")).to eq ([4])
      expect(searcher.find("ssippi")).to eq ([5])
      expect(searcher.find("mississ")).to eq ([0])
      expect(searcher.find("ississi")).to eq ([1])
      expect(searcher.find("ssissip")).to eq ([2])
      expect(searcher.find("sissipp")).to eq ([3])
      expect(searcher.find("issippi")).to eq ([4])
      expect(searcher.find("mississi")).to eq ([0])
      expect(searcher.find("ississip")).to eq ([1])
      expect(searcher.find("ssissipp")).to eq ([2])
      expect(searcher.find("sissippi")).to eq ([3])
      expect(searcher.find("mississip")).to eq ([0])
      expect(searcher.find("ississipp")).to eq ([1])
      expect(searcher.find("ssissippi")).to eq ([2])
      expect(searcher.find("ssissippix")).to eq ([])
      expect(searcher.find("mississipp")).to eq ([0])
      expect(searcher.find("ississippi")).to eq ([1])
      expect(searcher.find("mississippi")).to eq ([0])
    end
  end

  describe "#matchDataSource" do
    it "returns root location if nothing matches" do
      nodeFactory.setConfiguration( { :valueDepth => true })
      builder = UkkonenBuilder.new nodeFactory
      builder.addSourceValues
      searcher = Searcher.new(dataSource, builder.root)
      xDataSource = StringDataSource.new("xxx")
      location = searcher.matchDataSource(xDataSource)
      expect(location.onNode).to eq true
      expect(location.node).to eq builder.root
      expect(location.depth).to eq 0
    end

    it "finds location that we can use to get suffix offset" do
      nodeFactory.setConfiguration( { :valueDepth => true })
      builder = UkkonenBuilder.new nodeFactory
      builder.addSourceValues
      builder.addValue('$')
      searcher = Searcher.new(dataSource, builder.root)
      location = searcher.matchDataSource(StringDataSource.new "i")
      result = []
      location.node.each_suffix do |suffixOffset|
        result << suffixOffset
      end
      expect(result).to eq [ 10, 7, 4, 1 ]
    end
  end
end
