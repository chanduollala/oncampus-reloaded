class CreateNames < ActiveRecord::Migration[7.0]
  def change
    create_table :names do |t|
      t.string :first
      t.string :middle
      t.string :last
      t.belongs_to :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
