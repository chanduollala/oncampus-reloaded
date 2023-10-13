class CreateAcademicDetails < ActiveRecord::Migration[7.0]
  def change
    create_table :academic_details do |t|
      t.float :current_cgpa
      t.string :rollno
      t.integer :yop
      t.belongs_to :branch, null: false, foreign_key: true
      t.string :section
      t.boolean :backlogs
      t.belongs_to :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
