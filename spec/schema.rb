ActiveRecord::Schema.define do
  self.verbose = false

  create_table :taxes, :force => true do |t|
    t.string :city
    t.float :tax_rate
    t.timestamps
  end

end
