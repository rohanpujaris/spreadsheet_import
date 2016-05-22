require 'spec_helper'

describe SpreadsheetImport::ActiveRecordImporter do
  describe '#initialize' do
    it 'sets update_existing_record to true if unique_by_attributes is present
      and update_existing_record is not provided' do
      importer = described_class.new(Tax, unique_by_attributes: [:city])
      expect(importer.update_existing_record).to eq(true)
    end

    it 'sets update_existing_record from options if it is provided' do
      importer = described_class.new(Tax, unique_by_attributes: [:city],
        update_existing_record: false)
      expect(importer.update_existing_record).to eq(false)
    end
  end

  describe '#create_or_update' do
    before(:all) do
      Tax.create(city: 'abc, :old_namebc', tax_rate: '10%')
      Tax.create(city: 'abc', tax_rate: '12%')
    end

    context 'unique_by_attributes is present and update_existing_record is true' do
      let(:importer) do
        described_class.new(Tax, unique_by_attributes: [:city],
          update_existing_record: true)
      end

      it 'calls update method with duplicate_records and row if record is not unique' do
        row = { city: 'abc', tax_rate: '14%' }
        expect(importer).to receive(:update).with(Tax.where(city: 'abc'), row)
        importer.create_or_update(row)
      end

      it 'calls create method with row if record is unique record' do
        row = { city: 'xyz', tax_rate: '14%' }
        expect(importer).to receive(:create).with(row)
        importer.create_or_update(row)
      end
    end

    context 'unique_by_attributes is present and update_existing_record is false' do
      let(:importer) do
        described_class.new(Tax, unique_by_attributes: [:city],
          update_existing_record: false)
      end

      it 'does not call create and update method' do
        expect(importer).to_not receive(:create)
        expect(importer).to_not receive(:update)
        importer.create_or_update({ city: 'abc', tax_rate: '14% '})
      end
    end

    context 'unique_by_attributes is not present' do
      it 'calls create method with row if record is unique record' do
        row = { city: 'abc', tax_rate: '14%' }
        importer = described_class.new(Tax)
        expect(importer).to receive(:create).with(row)
        importer.create_or_update(row)
      end
    end
  end

  describe '#anoymous_model' do
  end
end
