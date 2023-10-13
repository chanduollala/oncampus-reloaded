class CreateCampusSelections < ActiveRecord::Migration[7.0]
  def change
    create_table :campus_selections do |t|
      t.belongs_to :user, null: false, foreign_key: true
      t.belongs_to :recruitment, null: false, foreign_key: true
      t.integer :ctc

      t.timestamps
    end
  end
end
