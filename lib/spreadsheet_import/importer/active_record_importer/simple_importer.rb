module SpreadsheetImport
  module ActiveRecordImporter
    class SimpleImporter < BaseImporter

      def initialize(model, options = {})
        super
      end

      def create(data)
        anoymous_model.create(data)
      end

      def update(records, data)
        if skip_validations && skip_callbacks
          records.update_all(data)
        else
          anoymous_model.update(records.select(:id).map(&:id), data)
        end
      end
    end
  end
end
