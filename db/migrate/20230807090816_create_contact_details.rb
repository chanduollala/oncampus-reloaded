class CreateContactDetails < ActiveRecord::Migration[7.0]
  def change
    create_table :contact_details do |t|
      t.string :email
      t.string :u_email
      t.string :phone
      t.string :alt_phone
      t.string :socials
      t.belongs_to :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
