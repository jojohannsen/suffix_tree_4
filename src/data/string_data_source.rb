require_relative 'base_data_source'

class StringDataSource < BaseDataSource

  def initialize(s)
    @s = s
    super()
  end

  def valueAt(offset)
    if (@s[offset] == nil) then
      return self.nextDataSourceValueAt(offset)
    else
      return @s[offset]
    end
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