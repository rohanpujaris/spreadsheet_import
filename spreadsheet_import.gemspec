# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'spreadsheet_import/version'

Gem::Specification.new do |spec|
  spec.name          = "spreadsheet_import"
  spec.version       = SpreadsheetImport::VERSION
  spec.authors       = ["Rohan Pujari"]
  spec.email         = ["rohanpujaris@gmail.com"]
  spec.summary       = %q{
                          Import csv, xls, xls, xlsx and ods file directly to database.
                          Supports bulk update via activerecord-import gem
                        }
  spec.description   = %q{
                          Import spreadsheet directly to database.
                          Supports simple import as well as bulk import.
                          Bulk import used activerecord-import gem.
                          Options to unique record import, updating of duplicate record,
                          skipping_callback and skipping validation.
                        }
  spec.homepage      = "https://github.com/rohanpujaris/spreadsheet_import"
  spec.license       = "MIT"
  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "database_cleaner"
  spec.add_development_dependency "simple-spreadsheet"
  spec.add_development_dependency "activerecord-import"
  spec.add_development_dependency "sqlite3"
end
