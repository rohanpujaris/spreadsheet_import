require 'activerecord-import'

module SpreadsheetImport
  module ActiveRecordImporter
    class BulkImporter < BaseImporter
      attr_reader :batch_size, :counter, :validate

      def initialize(model, options = {})
        super(model, options.merge!(skip_callbacks: true))
        @batch_size = options[:batch_size] || 100
        @data_in_batch = 0
        @batch = []
      end

      def create(data)
        if batch_size == @data_in_batch
          model.import data.keys, batch, validate: !skip_validations
        else
          @batch << data.values
          @data_in_batch += 1
        end
      end

      def update(records, data)
        if skip_validations
          records.update_all(data)
        else
          anoymous_model.update(records.select(:id).map(&:id), data)
        end
      end
    end
  end
end
