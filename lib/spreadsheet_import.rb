require 'spreadsheet_import/version'
require 'spreadsheet_import/extension/active_record'
require 'byebug'

module SpreadsheetImport
  autoload :BaseExtractor, 'spreadsheet_import/data_extractor/base_extractor'
  autoload :BaseReader, 'spreadsheet_import/reader/base_reader'
  autoload :SimpleReader, 'spreadsheet_import/reader/simple_reader'
  autoload :BaseImporter, 'spreadsheet_import/importer/base_importer'
  autoload :ActiveRecordImporter, 'spreadsheet_import/importer/active_record_importer/active_record_importer'
end
