module SpreadsheetImport
  class BaseExtractor
    attr_reader :reader, :mapping, :row_processor, :row_validator,
      :only_extract_valid_rows

    def initialize(reader, mapping, options = {})
      @reader = reader
      @mapping = mapping
      @row_processor = options[:row_processor]
      @row_validator = options[:row_validator]
      @only_extract_valid_rows = options[:only_extract_valid_rows]
    end

    def spreadsheet_rows
      reader.each_row(mapping.values) do |row|
        processed_row = process_row(row)
        valid_row = valid_row?(processed_row)
        if only_extract_valid_rows
          valid_row && yield(processed_row, true)
        else
          yield(processed_row, valid_row)
        end
      end
    end

    protected

    def unprocessed_row(row)
      {}.tap do |attributes|
        mapping.keys.each_with_index do |column_name, index|
          attributes[column_name] = row[index]
        end
      end
    end

    def process_row(row)
      unprocessed_row = unprocessed_row(row)
      if row_processor
        row_processor.process(unprocessed_row, self)
      else
        process_row_before_import(unprocessed_row)
      end
    end

    def valid_row?(row)
      if row_validator
        row_validator.validate(row, self)
      else
        valid_row_for_import?(row)
      end
    end

    def process_row_before_import(row)
      row
    end

    def valid_row_for_import?(_row)
      true
    end
  end
end
