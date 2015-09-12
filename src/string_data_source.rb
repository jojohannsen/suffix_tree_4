class StringDataSource
  def initialize(s)
    @s = s
  end

  def valueAt(offset)
    return @s[offset]
  end


end