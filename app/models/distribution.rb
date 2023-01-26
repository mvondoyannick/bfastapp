class Distribution < ApplicationRecord
  geocoded_by :address
  #after_validation :geocode
  before_create do 
    self.token = SecureRandom.uuid
  end

  belongs_to :entreprise
  has_many :products, dependent: :destroy
  validates :name, :logo, presence: true
  has_one_attached :logo
  has_many_attached :images
  validates :longitude, :latitude, presence: true

  def address
    #[street, city, state, country].compact.join(', ')
  end
end
