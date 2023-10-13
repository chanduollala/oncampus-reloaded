class CreateRecruitments < ActiveRecord::Migration[7.0]
  def change
    create_table :recruitments do |t|
      t.belongs_to :college, null: false, foreign_key: true
      t.belongs_to :company, null: false, foreign_key: true
      t.string :role
      t.string :des
      t.string :jd_link
      t.string :ctc
      t.string :last_date
      t.string :eligibility
      t.string :role_type

      t.timestamps
    end
  end
end
