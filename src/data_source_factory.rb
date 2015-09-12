require_relative 'string_data_source'

class DataSourceFactory

  STRING_DATA_SOURCE = 'string'
  FILE_DATA_SOURCE = 'file'

  def newDataSource(dataSourceType, dataSourceValue)
    if (dataSourceType == STRING_DATA_SOURCE) then
      return StringDataSource.new(dataSourceValue)
    end
  end
end