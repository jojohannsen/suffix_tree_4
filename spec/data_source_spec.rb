require 'rspec'
require_relative '../src/data/word_data_source'

describe 'reads data sources' do

  describe 'WordDataSource' do
    it "should read words" do
      wordDataSource = WordDataSource.new(File.join('spec', 'fixtures', "singlePara.txt"))
      expect(wordDataSource.valueAt(0)).to eq "i"
      expect(wordDataSource.valueAt(1)).to eq "was"
      expect(wordDataSource.valueAt(2)).to eq "born"
      expect(wordDataSource.valueAt(8)).to eq "angora"
      expect(wordDataSource.valueAt(16)).to eq "silky-haired"
      expect(wordDataSource.valueAt(19)).to eq "goats"
    end
  end
end