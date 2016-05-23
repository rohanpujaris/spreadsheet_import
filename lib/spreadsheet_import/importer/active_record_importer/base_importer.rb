module SpreadsheetImport
  module ActiveRecordImporter
    class BaseImporter < SpreadsheetImport::BaseImporter
      CALLBACKS_TO_SKIP = [:validation, :save, :create, :update, :commit]

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
        @skip_validations = options[:skip_validations]
        @skip_callbacks = options[:skip_callbacks]
      end

      def find_duplicate_for_unique_by_attributes(row)
        scoped_model.where(row.slice(*unique_by_attributes))
      end

      def create_or_update_record(row)
        if unique_by_attributes
          if update_existing_record
            duplicate_records = find_duplicate_for_unique_by_attributes(row)
            duplicate_records.present? ? update_record(duplicate_records, row) : create_record(row)
          end
        else
          create_record(row)
        end
      end

      def create_record(data)
        anoymous_model.create(data)
      end

      def update_record(records, data)
        if skip_validations && skip_callbacks
          records.update_all(data)
        else
          records.map { |record| record.update_attributes(data) }.all?
        end
      end

      protected

      def scoped_model
        scoped_unique ? model.send(scoped_unique) : model
      end

      def anoymous_model
        @anoymous_model ||= if skip_validations && skip_callbacks
          table_name = model.table_name
          Class.new(ActiveRecord::Base) { self.table_name = table_name }
        elsif skip_validations
          Class.new(model) do
            def self.name
              "New#{superclass.name}"
            end
            reset_callbacks :validate
            reset_callbacks :validation
          end
        elsif skip_callbacks
          Class.new(model) do
            def self.name
              "New#{superclass.name}"
            end
            CALLBACKS_TO_SKIP.each { |name| reset_callbacks(name) }
          end
        else
          model
        end
      end
    end
  end
end
