class Branch < ApplicationRecord
  belongs_to :college
  has_one :college
end
