module SpreadsheetImport
  class BaseImporter
    attr_reader :model, :data_processor

    def initialize(model, data_processor, options = {})
      @model = model
      @data_processor = data_processor
    end

    def import
      data_processor.spreadsheet_rows do |row, valid|
        if valid
          handle_valid_row(row)
        else
          handle_invalid_row(row)
        end
      end
    end

    protected

    def handle_valid_row(row)
      create_or_update_record(row)
    end

    def handle_invalid_row(row); end
  end
end
