# SpreadsheetImport

SpreadsheetImport gem allows importing data from csv, xls, xls, xlsx and ods file to database.
SpreadsheetImport contains 3 part (Reader, Processor, Importer). Each part depends on seprate gems and you can replace any part without effecting other part.

- Reader: Reads data from spreadsheet file. Following class are used for this functionality.
   * SpreadsheetImport::BaseReader: Base class of every Reader class.
   * SpreadsheetImport::SimpleReader: Inherits from base reader. Provides `each_row(required_columns)` method. This class depends on simple-spreadsheet gem https://github.com/zenkay/simple-spreadsheet.

 - Processor: Processes the data read by Reader. SpreadsheetImport gem defines one processor
    * SpreadsheetImport::BaseProcessor:  BaseProcessor contains various hooks to process and validate data provided by Reader.

- Importer: Responsible for importing data recieved from data processor to database. SpreadsheetImport gem provides following importor.
  * SpreadsheetImport::BaseImporter: Base class of all importer
  * SpreadsheetImport::ActiveRecordImporter::BaseImporter: Supports import using activerecord. Depends on activerecord gem.
  * SpreadsheetImport::ActiveRecordImporter::BulkImporter: Supports import using activerecord-import gem(https://github.com/zdennis/activerecord-import)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'spreadsheet_import'
gem 'simple-spreadsheet'  # if want to use SpreadsheetImport::SimpleReader
gem 'activerecord'        # if want to use any impoter in  SpreadsheetImport::ActiveRecordImporter
gem 'activerecord-import' # if want to use SpreadsheetImport::ActiveRecordImporter::BulkImporter
```

And then execute:

    $ bundle

## Usage

```ruby
  SpreadsheetImport.import(file_url, mapping, model, options)
```
- file_url: url of csv file
- mapping: database column name to spreadsheet column number mapping hash.

  Example:

  {city: 1, tax_rate: 3}

  city and tax_rate are column name in database. 1, 3 are column number in spreadsheet file.
- model: model class for which spreadsheet needs to be imported
- options: Hash of options
  * reader: Custom reader class object
  * data_processor: Custom data processor class object
  * importer: Custom importer class object

## Details
- SpreadsheetImport::BaseReader:

  Class inheriting from BaseReader should define `each_row(required_columns)` method. Method should accept column position as array and yield value of those columns as array for each spreadsheet row. It is upto you to implement this functionality anyway you want. BaseReader also accepts start_row(row from where reader should start reading) and end_row(row at which reader should end reading) as option while intiantiating reader. So you can also handle start_row and end_row option in `each_row` method.

- SpreadsheetImport::SimpleReader:

   If you want to use this reader add simple-spreadshee gem to your project. If you dont want to use simple spreadsheet gem or have any alternative gem to read spreadsheet file then you can create your own reader class by inheriting from BaseReader. You can call all simple-spreadsheet gem method on SimpleReader object.

  Example:
  ```ruby
    reader = SimpleReader('file/abc.xls', start_row: 2, end_row: 30)
    reader.cell(1, 2) # this is simple-spreadsheet gem method
  ```

  Note: SpreadsheetImport::SimpleReader includes Enumerable module. So you can use enumerable functions like each, select etc

- Spreadsheetimport::BaseProcessor:

  If you want to process data before importing it to db then create a new processor class which inherits from BaseProcessor.
  BaseProcessor constructor accepts following parameters
     1) reader: Reader class object
     2) mapping: database column name to spreadsheet column number mapping hash
     3) options: Following options are supported row_processor, row_validator and only_extract_valid_rows.
        * row_processor:  Accepts a class which would be responsible for processing rows comming from `each_row` method of reader. Row Processor class should define `process` method. `process` method will called with unprocessed_row and current instance of data processor as arguments. unprocessed_row is in following format

         ```ruby
            {db_column_name1: value_from_spreadsheet, db_column_name1: value_from_spreadsheet}`.
         ```

          `process` method should return hash in below format.

          ```ruby
          {db_column_name1: processed_value, db_column_name1: processed_value}`
         ```

          There is alternative to process data other then providing row_processor option. You can inherit from BaseProcessor and add `process_row_before_import` method to your class. This method will recieve unprocessed_row and you should return processed row from it.
        * row_validator: Accepts a class which is responsible for validating a processed row. Row validator class should define `validate` method. This method is called with processed row returned from `process` method of row processor or `process_row_before_import` method and current instance of data processor as second argument. `validate` method should return true or false.
There is alternative to validate data other then providing row_validatir option. You can inherit from BaseProcessor and add `valid_row_for_import?` method to your class. This method will recieve processed_row and you should return return true or false.
        * only_extract_valid_rows: If true `spreadsheet_rows` method will yield on rows that are valid otherwise it will yield each row. Row is valid or not is decided either by row_validator class `validate` method or by `valid_row_for_import?` method.

   Example:

   Consider below csv file
   ```
     city,county,tax rate,
     Palm Desert,Some county, 0.2,
     Marine Corps*,Some county 2,0.9,
   ```

   ```ruby
    # Custome data processor
     class TaxFileProcessor < SpreadsheetImport::BaseProcessor
       def process_row_before_import(row)
         city = row[:city]
         if city.present?
           city = city.gsub(/[^a-zA-Z0-9\s]/,'').strip # remove special character and remove spaces from start and end
         end
         { city: city, tax_rate: row[:tax_rate].to_f * 100 }
       end

       def valid_row_for_import?(row)
         row[:city].present?
       end
    end

    reader = SimpleReader('file/abc.csv, start_row: 2)
    data_processor = TaxFileProcessor.new(reader, {city: 1, tax_rate: 3}, only_extract_valid_rows: true)
    data_processor.spreadsheet_rows {|row| puts row}
    # o/p
    # { city: 'Palm Desert', tax_rate:  20.0 }
    # { city: 'Marine Corps', tax_rate:  90.0 }
   ```
  Note: SpreadsheetImport::BaseProcessor includes Enumerable module. So you can use enumerable functions like each, select etc

- SpreadsheetImport::BaseImporter: It does not implement any functionality. It just specifies some hooks that its subclass should implement. SpreadsheetImport::BaseImporter constructor accepts model and options as argument. It accepts only one option i.e data_processor object. It uses data processor `spreadsheet_rows` method which yields processed_row and valid(true or false) to call either handle_valid_row or handle_invalid_row method. By default handle_valid_row calls `create_or_update_record(row)` method. `handle_invalid_row` is blank and you can define it in you subclass if you want to handle_invalid_rows. This may be helpful in case you want to log invalid rows from csv somewhere.

- SpreadsheetImport::ActiveRecordImporter::BaseImporter: Constructor accepts following arguments
  * model: ActiveRecord model class to which we want to import data
  * options
     * data_processor: Data processor object
     * skip_validations: Skips validation if true. false by default
     * skip_callbacks: Skips callback if true. false by default
     * unique_by_attributes: accepts list of attribute which should be unique. If its not unique then new record won't be inserted. Decision to whether update existing record is made by update_existing_record option. For finding already existing record where query is fired which does case sensitive comparision between attribute from spreedsheet and db. If you want to add some custom implementation then create your own importer which inherits from SpreadsheetImport::ActiveRecordImporter::BaseImporter and define `find_duplicate_for_unique_by_attributes(data)` method. find_duplicate_for_unique_by_attributes will be called with data(processed_row). It should return ActiveRecord::Relation object or model object or array of model object. Currently it has following implementation `scoped_model.where(data.slice(*unique_by_attributes))`.

       Note: Always use `scoped_model` method to call any ActiveRecord method
     * update_existing_record: If true will update the existing record. true by default if unique_by_attributes is present.
     * scoped_unique: class method or scope name as symbol. This scope is applied for finding record which are already present in database.

  It defines `create_or_update_record` method called by `handle_valid_row`.

- SpreadsheetImport::ActiveRecordImporter::BulkImporter: This importer utilizes activerecord-import gem. Its faster than SpreadsheetImport::ActiveRecordImporter::BaseImporter. It is recomended for large spreedsheet files. ActiveRecord callbacks will not be called when BulkImporter is used. It inherits from SpreadsheetImport::ActiveRecordImporter::BaseImporter, so its constructor supports same argument. Passing skip_callbacks as true or false doesn't have any effect and callbacks will always be skipped. This is a penalty that you have to pay for performance :). It also support addition option of batch_size. It is the number of records that would be inserted at once.
Default batch size is 100.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/spreadsheet_import. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

