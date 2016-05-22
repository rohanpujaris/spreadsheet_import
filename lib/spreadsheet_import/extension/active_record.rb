module Extension
  module ActiveRecord
    module Base
      def spreedsheet_import(file_url, options = {})
        reader = options[:reader] || SpreadsheetImport::Reader.new(file_url, start_row: 2)
        data_extractor = options[:data_extractor] ||
          SpreadsheetImport::BaseExtractor.new(reader: reader)
        (options[:importer] || BaseActiveRecordImporter)
          .new(model, options.only(:operation)).import
      end
    end
  end
end
