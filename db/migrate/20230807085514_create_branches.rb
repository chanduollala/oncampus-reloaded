class CreateBranches < ActiveRecord::Migration[7.0]
  def change
    create_table :branches do |t|
      t.string :title
      t.string :abbr
      t.string :des
      t.belongs_to :college, null: false, foreign_key: true

      t.timestamps
    end
  end
end
