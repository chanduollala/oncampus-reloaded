class Recruitment < ApplicationRecord
  belongs_to :college
  belongs_to :company
  has_many :recruitment_updates
end
