module SpreadsheetImport
  class ActiveRecordImporter < BaseImporter
    attr_reader :skip_validations, :skip_callbacks, :unique_by_attributes,
      :update_existing_record, :scoped_unique

    def initialize(model, options ={})
      super
      @unique_by_attributes = options[:unique_by_attributes]
      @update_existing_record = if options[:update_existing_record].nil?
        !unique_by_attributes.nil?
      else
        options[:update_existing_record]
      end
      @scoped_unique = options[:scoped_unique]
      @skip_validation = options[:skip_validations]
      @skip_callback = options[:skip_callbacks]
    end

    def find_duplicate_for_unique_by_attributes(row)
      scoped_model.where(row.slice(*unique_by_attributes))
    end

    def create_or_update(row)
      if unique_by_attributes
        if update_existing_record
          duplicate_records = find_duplicate_for_unique_by_attributes(row)
          duplicate_records.present? ? update(duplicate_records, row) : create(row)
        end
      else
        create(row)
      end
    end

    def create(row)
      raise 'create method must be implemented by SpreadsheetLoader::ActiveRecordImporter subclass'
    end

    def update(duplicate_records, row)
      raise 'create method must be implemented by SpreadsheetLoader::ActiveRecordImporter subclass'
    end

    protected

    def scoped_model
      scoped_unique ? model.send(scoped_unique) : model
    end

    def anoymous_model
      # run_callbacks is overrided in anoymous class with super class as provided model to
      # skip callbacks and validations
      @anoymous_model ||= if skip_validations_and_callbacks
        Class.new(ActiveRecord::Base) { self.table_name = model.table_name }
      elsif skip_validations
        Class.new(model) do
          def run_callbacks(name, *_, &block)
            name.to_sym == :validate || super
          end
        end
      elsif skip_callbacks
        Class.new(model) do
          def run_callbacks(name, *_, &block)
            name.to_sym != :validate || super
          end
        end
      else
        model
      end
    end
  end
end
