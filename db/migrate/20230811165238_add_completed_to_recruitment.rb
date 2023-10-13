class AddCompletedToRecruitment < ActiveRecord::Migration[7.0]
  def change
    add_column :recruitments, :completed, :boolean
  end
end
