class Ville < ApplicationRecord
  validates :name, :latitude, :longitude, presence: true
  has_many :buses, dependent: :destroy
  has_many :agences, dependent: :destroy
end
