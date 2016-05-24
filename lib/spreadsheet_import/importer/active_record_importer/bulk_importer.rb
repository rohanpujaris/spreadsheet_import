require 'activerecord-import'

module SpreadsheetImport
  module ActiveRecordImporter
    class BulkImporter < BaseImporter
      attr_reader :batch_size, :counter, :validate

      def initialize(model, options = {})
        super(model, options.merge!(skip_callbacks: true))
        @batch_size = options[:batch_size] || 100
        @batch = []
      end

      def import
        super
        !@batch.length.zero? && execute_batch
      end

      def create_record(data)
        if unique_by_attributes.nil? || unique_in_batch?(data)
          @batch << data
          batch_size == @batch.length && execute_batch
        end
      end

      def unique_in_batch?(data)
        @batch.find do |batch_record|
          unique_by_attributes.all? do |attr_name|
            data[attr_name] == batch_record[attr_name]
          end
        end.nil?
      end

      def execute_batch
        model.import(data_extractor.mapping.keys,
          @batch.map(&:values), validate: !skip_validations)
        @batch = []
      end
    end
  end
end
