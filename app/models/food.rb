class Food < ApplicationRecord
  has_one_attached :image
  has_many :buses, dependent: :destroy
  has_many :horaires, dependent: :destroy
end
