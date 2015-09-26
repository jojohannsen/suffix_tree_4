require_relative 'base_data_source'

class FileDataSource < BaseDataSource
  def initialize(path)
    @inFile = File.open(path, "rb")
    @checkFile = File.open(path, "rb")
  end

  def valueAt(offset)
    @checkFile.seek(offset, IO::SEEK_SET)
    return @checkFile.getc
  end
end