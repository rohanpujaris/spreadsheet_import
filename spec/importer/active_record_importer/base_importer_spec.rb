require 'spec_helper'

describe SpreadsheetImport::ActiveRecordImporter::BaseImporter do
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

  describe '#create_or_update_record' do
    before(:all) do
      Tax.create(city: 'abc, :old_namebc', tax_rate: '10%')
      Tax.create(city: 'abc', tax_rate: '12%')
    end

    context 'unique_by_attributes is present and update_existing_record is true' do
      let(:importer) do
        described_class.new(Tax, unique_by_attributes: [:city],
          update_existing_record: true)
      end

      it 'calls update_record method with duplicate_records and row if record is not unique' do
        row = { city: 'abc', tax_rate: '14%' }
        expect(importer).to receive(:update_record).with(Tax.where(city: 'abc'), row)
        importer.create_or_update_record(row)
      end

      it 'calls create_record method with row if record is unique record' do
        row = { city: 'xyz', tax_rate: '14%' }
        expect(importer).to receive(:create_record).with(row)
        importer.create_or_update_record(row)
      end
    end

    context 'unique_by_attributes is present and update_existing_record is false' do
      let(:importer) do
        described_class.new(Tax, unique_by_attributes: [:city],
          update_existing_record: false)
      end

      it 'does not call create_record and update_record method' do
        expect(importer).to_not receive(:create_record)
        expect(importer).to_not receive(:update_record)
        importer.create_or_update_record({ city: 'abc', tax_rate: '14% '})
      end
    end

    context 'unique_by_attributes is not present' do
      it 'calls create_record method with row if record is unique record' do
        row = { city: 'abc', tax_rate: '14%' }
        importer = described_class.new(Tax)
        expect(importer).to receive(:create_record).with(row)
        importer.create_or_update_record(row)
      end
    end
  end

  describe '#create_record' do
    it 'skips validation and callbacks if skip_validations and skip_callbacks is true' do
      importer = described_class.new(User, skip_validations: true, skip_callbacks: true)
      anoymous_model = importer.send(:anoymous_model)

      expect_any_instance_of(anoymous_model).to_not receive(:around_callback_method)
      expect_any_instance_of(anoymous_model).to_not receive(:callback_method)
      user = importer.create_record(email_id: 'xyz@cc.com')
      expect(user).to be_persisted
    end

    it 'skips callbacks when skip_callbacks is true' do
      importer = described_class.new(User, skip_callbacks: true)
      anoymous_model = importer.send(:anoymous_model)

      expect_any_instance_of(anoymous_model).to_not receive(:callback_method)
      expect_any_instance_of(anoymous_model).to_not receive(:around_callback_method)
      importer.create_record({name: 'Rohan'})
    end

    it 'does not skips validation when skip_callbacks true and skip_validations is false' do
      importer = described_class.new(User, skip_callbacks: true, skip_validations: false)
      anoymous_model = importer.send(:anoymous_model)

      expect_any_instance_of(anoymous_model).to_not receive(:callback_method)
      expect_any_instance_of(anoymous_model).to_not receive(:around_callback_method)
      user = importer.create_record(name: nil)
      expect(user).to be_new_record
    end

    it 'does not skip callbacks when skip_validations true and skip_callbacks is false'
  end

  describe '#update_record' do
    let!(:user) { User.create(name: 'Rohan') }

    it 'updates existing record' do
      importer = described_class.new(User)
      importer.update_record(User.where(name: 'Rohan'), email_id: 'xyz@cc.com')
      expect(user.reload.email_id).to eq('xyz@cc.com')
    end

    it 'skips validation and callbacks if skip_validations and skip_callbacks is true' do
      importer = described_class.new(User, skip_validations: true, skip_callbacks: true)

      expect(user).to_not receive(:callback_method)
      expect(user).to_not receive(:around_callback_method)
      importer.update_record(User.where(name: 'Rohan'), email_id: 'abc@cc.com')
      expect(user.reload.email_id).to eq('abc@cc.com')
    end

    it 'skips callbacks when skip_callbacks is true' do
      importer = described_class.new(User, skip_callbacks: true)

      expect(user).to_not receive(:callback_method)
      expect(user).to_not receive(:around_callback_method)
      importer.update_record(User.where(name: 'Rohan'), email_id: 'abc@cc.com')
    end

    it 'does not skips validation if skip_callbacks true and skip_validations is false' do
      importer = described_class.new(User, skip_callbacks: true, skip_validations: false)
      User.create(name: 'RohanP')

      expect(user).to_not receive(:callback_method)
      expect(user).to_not receive(:around_callback_method)
      importer.update_record(User.where(name: 'Rohan'), name: 'nil')
      expect(user.reload.name).to_not be_nil
    end

    it 'does not skip callbacks when skip_validations true and skip_callbacks is false'
  end
end
