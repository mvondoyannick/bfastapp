class TravelAgence < ApplicationRecord
  geocoded_by :address
  belongs_to :travel_entreprise
  belongs_to :ville
  has_one_attached :image

  validates :name, :latitude, :longitude, presence: true

  def address
    [street, city, state, country].compact.join(', ')
  end
end
