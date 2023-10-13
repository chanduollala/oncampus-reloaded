class AddLocationToRecruitments < ActiveRecord::Migration[7.0]
  def change
    add_column :recruitments, :location, :string
  end
end
