require_relative 'base_data_source'

class FileDataSource < BaseDataSource
  def initialize(path)
    @inFile = File.open(path, "rb")
    @checkFile = File.open(path, "rb")
    super(0)
  end

  def valueAt(offset)
    @checkFile.seek(offset - @startOffset, IO::SEEK_SET)
    result = @checkFile.getc
    if (result == nil) then
      return self.nextDataSourceValueAt(offset)
    end
    result
  end
end