class StringDataSource
  def initialize(s)
    @s = s
  end

  def valueAt(offset)
    return @s[offset]
  end

  def stringValue
    return @s
  end
end