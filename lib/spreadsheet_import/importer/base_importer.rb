module SpreadsheetImport
  class BaseImporter
    attr_reader :model, :data_extractor

    def initialize(model, options = {})
      @model = model
      @data_extractor = options[:data_extractor]
    end

    def import
      data_extractor.spreadsheet_rows do |row, valid|
        if valid
          handle_valid_row(row)
        else
          handle_invalid_row(row)
        end
      end
    end

    protected

    def handle_valid_row(row)
      unless record = create_or_update_record(row)
        handle_validation_failure(record)
      end
    end

    def handle_invalid_row; end

    def handle_validation_failure; end
  end
end
