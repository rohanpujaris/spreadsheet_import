require 'spreadsheet_import/version'

module SpreadsheetImport
  autoload :BaseExtractor, 'spreadsheet_import/data_extractor/base_extractor'
  autoload :BaseReader, 'spreadsheet_import/reader/base_reader'
  autoload :SimpleReader, 'spreadsheet_import/reader/simple_reader'
  autoload :BaseImporter, 'spreadsheet_import/importer/base_importer'

  module ActiveRecordImporter
    autoload :BaseImporter, 'spreadsheet_import/importer/active_record_importer/base_importer'
    autoload :BulkImporter, 'spreadsheet_import/importer/active_record_importer/bulk_importer'
  end
end
