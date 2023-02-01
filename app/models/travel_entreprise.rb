class TravelEntreprise < ApplicationRecord
  validates :name, :email, :phone, presence: true
  has_one_attached :image
  has_many :travel_agences, dependent: :destroy

  before_create do 
    self.token = SecureRandom.uuid
  end
end
