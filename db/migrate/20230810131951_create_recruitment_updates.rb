class CreateRecruitmentUpdates < ActiveRecord::Migration[7.0]
  def change
    create_table :recruitment_updates do |t|
      t.belongs_to :recruitment, null: false, foreign_key: true
      t.string :title
      t.string :description
      t.string :start
      t.string :end
      t.string :link1
      t.string :link2
      t.integer :index

      t.timestamps
    end
  end
end
