class Bus < ApplicationRecord
  validates :name, presence: true
  has_one_attached :image
  #belongs_to :horaire
  has_many :horaires, dependent: :destroy
  belongs_to :ville
end
