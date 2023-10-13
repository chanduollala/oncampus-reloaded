class CreateColleges < ActiveRecord::Migration[7.0]
  def change
    create_table :colleges do |t|
      t.string :college_name
      t.string :college_code
      t.string :abbr
      t.string :address
      t.string :contact

      t.timestamps
    end
  end
end
