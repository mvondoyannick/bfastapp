class Product < ApplicationRecord
  belongs_to :category
  belongs_to :distribution
  validates :name, presence: true

  has_one_attached :image
  has_many_attached :galeries
end
