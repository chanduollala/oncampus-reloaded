class AddColumnToInternships < ActiveRecord::Migration[7.0]
  def change
    add_column :internships, :turned_in, :boolean
  end
end
