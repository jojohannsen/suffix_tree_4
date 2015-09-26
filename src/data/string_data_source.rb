require_relative 'base_data_source'

class StringDataSource < BaseDataSource
  def initialize(s)
    @s = s
  end

  def valueAt(offset)
    return @s[offset]
  end

  def stringValue
    return @s
  end

  # substring
  def toString(startOffset, endOffset)
    if (endOffset >= startOffset) then
      return @s[startOffset..endOffset]
    else
      return @s[startOffset..(@s.length - 1)]
    end
  end
end