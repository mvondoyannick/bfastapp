class TravelEntreprise < ApplicationRecord
  validates :name, :email, :phone, presence: true
  has_one_attached :image

  before_create do 
    self.token = SecureRandom.uuid
  end
end
