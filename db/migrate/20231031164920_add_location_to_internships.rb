class AddLocationToInternships < ActiveRecord::Migration[7.0]
  def change
    add_column :internships, :location, :string
  end
end
