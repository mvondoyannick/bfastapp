class GazManufacturer < ApplicationRecord
  validates :name, :link, presence: true 
  has_one_attached :image
end
