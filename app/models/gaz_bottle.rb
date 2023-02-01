class GazBottle < ApplicationRecord
  belongs_to :gaz_fournisseur
  has_and_belongs_to_many :gaz_fournisseurs
  belongs_to :gaz_manufacturer

  validates :name, :image, presence: true
  has_one_attached :image

  # generate token
  before_create do 
    self.token = SecureRandom.uuid
  end
end
