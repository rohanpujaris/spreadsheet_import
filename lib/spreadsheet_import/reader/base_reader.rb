module SpreadsheetImport
  class BaseReader
    attr_reader :file_url, :spreasheet, :start_row, :end_row

    def initialize(file_url, options = {})
      @file_url = file_url
      @start_row = options[:start_row] || 1
    end

    def each_row
      raise 'each_row method must be implemented by SpreadsheetLoader::Reader subclass'
    end
  end
end
