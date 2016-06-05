require 'spreadsheet_import/version'

module SpreadsheetImport
  autoload :BaseProcessor, 'spreadsheet_import/data_processor/base_processor'
  autoload :BaseReader, 'spreadsheet_import/reader/base_reader'
  autoload :SimpleReader, 'spreadsheet_import/reader/simple_reader'
  autoload :BaseImporter, 'spreadsheet_import/importer/base_importer'

  module ActiveRecordImporter
    autoload :BaseImporter, 'spreadsheet_import/importer/active_record_importer/base_importer'
    autoload :BulkImporter, 'spreadsheet_import/importer/active_record_importer/bulk_importer'
  end

  def self.import(file_url, mapping, model, options = {})
    reader = options[:reader] || SimpleReader.new(file_url, start_row: 2)
    data_processor = options[:data_processor] || BaseProcessor.new(reader, mapping)
    (options[:importer] || ActiveRecordImporter::BaseImporter)
      .new(model, data_processor).import
  end
end
