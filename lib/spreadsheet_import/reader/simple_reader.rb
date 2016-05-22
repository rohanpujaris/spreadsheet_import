require 'simple-spreadsheet'

module SpreadsheetImport
  class SimpleReader < BaseReader
    extend Forwardable
    def_delegator :spreasheet, :cell

    def initialize(file_url, options = {})
      super
      @spreasheet = SimpleSpreadsheet::Workbook.read(file_url)
      @end_row = options[:end_row] || spreasheet.last_row
    end

    def row_range
      (start_row..end_row)
    end

    def default_required_columns
      spreasheet.first_column.upto(spreasheet.last_column).to_a
    end

    def each_row(required_columns = default_required_columns)
      row_range.each do |row|
        entire_row = required_columns.each_with_object([]) do |col, acc|
          acc << spreasheet.cell(row, col)
        end
        yield entire_row
      end
    end
  end
end
