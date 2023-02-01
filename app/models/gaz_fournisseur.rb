class GazFournisseur < ApplicationRecord
  geocoded_by :address
  belongs_to :ville
  has_and_belongs_to_many :gaz_bottles
  validates :name, :phone, :email, presence: true
  has_many_attached :images

  def address
    [street, city, state, country].compact.join(', ')
  end
end
