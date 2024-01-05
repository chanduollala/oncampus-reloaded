class Internship < ApplicationRecord
  belongs_to :user
  has_many :internship_documents
end
