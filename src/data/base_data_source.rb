class BaseDataSource
  def each_with_index(offset = 0)
    while ((value = self.valueAt(offset)) != nil) do
      yield value, offset
      offset += 1
    end
  end
end