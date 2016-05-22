module FileUrlHelper
  def tax_csv_file_url
    Rails.root.join("spec/fixtures/files/tax.csv")
  end
end
