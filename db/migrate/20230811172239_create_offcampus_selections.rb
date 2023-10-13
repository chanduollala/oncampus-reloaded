class CreateOffcampusSelections < ActiveRecord::Migration[7.0]
  def change
    create_table :offcampus_selections do |t|
      t.belongs_to :user, null: false, foreign_key: true
      t.integer :ctc
      t.string :company_name
      t.string :job_type
      t.string :location
      t.string :role

      t.timestamps
    end
  end
end
