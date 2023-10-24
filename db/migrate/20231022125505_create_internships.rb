class CreateInternships < ActiveRecord::Migration[7.0]
  def change
    create_table :internships do |t|
      t.belongs_to :user, null: false, foreign_key: true
      t.string :company_name
      t.string :role_title
      t.integer :stipend
      t.string :start_date
      t.string :end_date
      t.boolean :noc

      t.timestamps
    end
  end
end
