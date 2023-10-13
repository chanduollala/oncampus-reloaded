class CreatePersonalDetails < ActiveRecord::Migration[7.0]
  def change
    create_table :personal_details do |t|
      t.blob :photo
      t.string :gender
      t.string :dob
      t.string :mother_name
      t.string :father_name
      t.string :nationality
      t.string :passport
      t.string :PAN
      t.belongs_to :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
