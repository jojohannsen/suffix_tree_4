class BaseDataSource
  def initialize
    @nextDataSource = nil
    @nextDataSourceStartOffset = 0
  end

  def extendWith(dataSource, startOffset)
    if (@nextDataSource == nil) then
      @nextDataSource = dataSource
      @nextDataSourceStartOffset = startOffset
    else
      @nextDataSource.extendWith(dataSource, startOffset)
    end
  end

  def nextDataSourceValueAt(offset)
    if (@nextDataSource != nil) then
      return @nextDataSource.valueAt(offset - @nextDataSourceStartOffset)
    else
      return nil
    end
  end

  def each_with_index(offset = 0)
    while ((value = self.valueAt(offset)) != nil) do
      yield value, offset
      offset += 1
    end
  end
end