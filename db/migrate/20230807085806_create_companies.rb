class CreateCompanies < ActiveRecord::Migration[7.0]
  def change
    create_table :companies do |t|
      t.string :company_name
      t.string :address
      t.string :contact
      t.string :passkey
      t.string :des

      t.timestamps
    end
  end
end
