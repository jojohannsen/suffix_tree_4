class FileDataSource
  def initialize(path)
    @inFile = File.open(path, "rb")
    @checkFile = File.open(path, "rb")
  end

  def stringValue
    @inFile.seek(0, IO::SEEK_SET)
    return @inFile
  end

  def valueAt(offset)
    @checkFile.seek(offset, IO::SEEK_SET)
    return @checkFile.getc
  end
end