class CreateInternshipDocuments < ActiveRecord::Migration[7.0]
  def change
    create_table :internship_documents do |t|
      t.belongs_to :user, null: false, foreign_key: true
      t.string :title
      t.string :document_link
      t.boolean :is_verified

      t.timestamps
    end
  end
end
