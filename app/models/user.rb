class User < ApplicationRecord
  has_secure_password
  has_one :name, dependent: :destroy
  belongs_to :college
  has_one :personal_detail, dependent: :destroy
  has_one :contact_detail, dependent: :destroy
  has_one :academic_detail, dependent: :destroy
  has_one :branch, through: :academic_detail

  has_many :campus_selections, dependent: :destroy

  accepts_nested_attributes_for :name,:allow_destroy => true
  accepts_nested_attributes_for :college
  accepts_nested_attributes_for :academic_detail,:allow_destroy => true
  accepts_nested_attributes_for :personal_detail,:allow_destroy => true
  accepts_nested_attributes_for :contact_detail,:allow_destroy => true

  validates :username, presence: true, uniqueness: true
  has_one_attached :image
end
