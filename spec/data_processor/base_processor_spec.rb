require 'spec_helper'

describe SpreadsheetImport::BaseProcessor do
  let(:reader) do
    SpreadsheetImport::SimpleReader.new('spec/fixtures/files/tax.csv')
  end

  describe 'Public Methods' do
    describe '#initialize' do
      it 'uses SimpleReader for reading csv if reader is not specified' do
        base_processor = described_class.new(reader, {})
        expect(base_processor.reader).to be_instance_of(SpreadsheetImport::SimpleReader)
      end
    end

    describe '#spreadsheet_rows' do
      context 'only_extract_valid_rows is truthy' do
        let(:base_processor) do
          described_class.new(reader, {city: 1, tax_rate: 3},
              only_extract_valid_rows: true)
        end

        it 'yields only valid record' do
          allow(base_processor).to receive(:valid_row_for_import?)
            .and_return(true, false, true, true)
          all_rows = []
          base_processor.spreadsheet_rows do |row|
            all_rows << row
          end

          expect(all_rows).to eq([
            {city: 'city', tax_rate: 'tax rate'},
            {city: 'Mare Island (Vallejo*)', tax_rate: '8.625%'},
            {:city=>"Acampo", :tax_rate=>"8.00%"}
          ])
        end

        it 'yields block with second parameter always as true' do
          allow(base_processor).to receive(:valid_row_for_import?).and_return(true, false)
          base_processor.spreadsheet_rows do |row, valid|
            expect(valid).to eq(true)
          end
        end
      end

      context 'only_extract_valid_rows is falsy' do
        let(:base_processor) do
           described_class.new(reader, {city: 1, tax_rate: 3})
         end

        it 'yields valid as well as invalid rows' do
          allow(base_processor).to receive(:valid_row_for_import?).and_return(true, false)
          all_rows = []
          base_processor.spreadsheet_rows do |row|
            all_rows << row
          end

          expect(all_rows).to eq([
            {city: 'city', tax_rate: 'tax rate'},
            {city: 'Palm Desert', tax_rate: '8.00%'},
            {city: 'Mare Island (Vallejo*)', tax_rate: '8.625%'},
            {city: 'Acampo', tax_rate: '8.00%'}
          ])
        end

        it 'yields block with second parameter denoting whether extracted value was valid' do
          is_valid_array = [true, false ,true, true]
          is_valid_enum = is_valid_array.to_enum()
          allow(base_processor).to receive(:valid_row?).and_return(*is_valid_array)
          base_processor.spreadsheet_rows do |row, valid|
            expect(valid).to eq(is_valid_enum.next)
          end
        end
      end
    end
  end

  describe 'Protected Methods' do
    describe '#process_row' do
      it 'call process method on row_processor with unprocessed_row' do
        row_processor = Class.new do
          def self.process; end
        end
        extractor = described_class.new(reader, {}, row_processor: row_processor)

        allow(extractor).to receive(:unprocessed_row).and_return(:row)
        expect(row_processor).to receive(:process).with(:row, extractor)
        extractor.send(:process_row, :row)
      end
    end

    describe '#valid_row?' do
      it 'instantiates row_validator with row and calls validate method on it' do
        row_validator = Class.new do
          def self.validate; end
        end
        extractor = described_class.new(
          reader, {}, row_validator: row_validator)

        expect(row_validator).to receive(:validate).with(:row, extractor)
        extractor.send(:valid_row?, :row)
      end
    end
  end
end
