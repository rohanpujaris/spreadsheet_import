require 'simple-spreadsheet'

module SpreadsheetImport
  class SimpleReader < BaseReader
    def initialize(file_url, options = {})
      super
      @spreadsheet = SimpleSpreadsheet::Workbook.read(file_url)
      @end_row = options[:end_row] || spreadsheet.last_row
    end

    def row_range
      (start_row..end_row)
    end

    def default_required_columns
      spreadsheet.first_column.upto(spreadsheet.last_column).to_a
    end

    def each_row(required_columns = default_required_columns)
      row_range.each do |row|
        entire_row = required_columns.each_with_object([]) do |col, acc|
          acc << spreadsheet.cell(row, col)
        end
        yield entire_row
      end
    end

    # delegate all methods to SimpleSpreadsheet gem
    def method_missing(method, *args)
      if spreadsheet.respond_to?(method)
        spreadsheet.public_send(method, *args)
      else
        super
      end
    end

    def respond_to_missing?(method_name, include_private = false)
      spreadsheet.respond_to?(method_name, include_private) || super
    end
  end
end
