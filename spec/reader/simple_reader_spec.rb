require 'spec_helper'

describe SpreadsheetImport::SimpleReader do
  describe '#initialize' do
    let(:spreadsheet) do
      described_class.new('spec/fixtures/files/tax.csv')
    end

    it 'assigns 1 to start_row if nothing is provided' do
      expect(spreadsheet.start_row).to eq(1)
    end

    it 'assigns last row count of spreasheet to end_row if nothing is provided' do
      expect(spreadsheet.end_row).to eq(4)
    end
  end

  describe '#each_row' do
    it 'yields each row if no argument is passed while object instantiation' do
      spreasheet = described_class.new('spec/fixtures/files/tax.csv')
      all_rows = []
      spreasheet.each_row do |row|
        all_rows << row
      end

      expect(all_rows).to eq([
        ['city', 'county', 'tax rate'],
        ['Palm Desert', 'Riverside*', '8.00%'],
        ['Mare Island (Vallejo*)', 'Solano', '8.625%'],
        ['Acampo', 'San Joaquin*', '8.00%']
      ])
    end

    it 'yields rows start_row and end_row options' do
      spreasheet = described_class.new('spec/fixtures/files/tax.csv',
        start_row: 2, end_row: 3)
      all_rows = []
      spreasheet.each_row do |row|
        all_rows << row
      end

      expect(all_rows).to eq([
        ['Palm Desert', 'Riverside*', '8.00%'],
        ['Mare Island (Vallejo*)', 'Solano', '8.625%']
      ])
    end

    it 'yields row with only required_columns' do
      spreasheet = described_class.new('spec/fixtures/files/tax.csv')
      all_rows = []
      spreasheet.each_row([1, 3]) do |row|
        all_rows << row
      end

      expect(all_rows).to eq([
        ['city', 'tax rate'],
        ['Palm Desert', '8.00%'],
        ['Mare Island (Vallejo*)', '8.625%'],
        ['Acampo', '8.00%']
      ])
    end
  end
end
