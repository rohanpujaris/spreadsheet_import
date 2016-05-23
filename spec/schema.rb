ActiveRecord::Schema.define do
  self.verbose = false

  create_table :taxes, :force => true do |t|
    t.string :city
    t.float :tax_rate
  end

  create_table :users, :force => true do |t|
    t.string :name
    t.string :email_id
  end
end
