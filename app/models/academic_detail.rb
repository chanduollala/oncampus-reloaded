class AcademicDetail < ApplicationRecord
  belongs_to :branch
  belongs_to :user

  has_many :campus_selections, through: :user
end
