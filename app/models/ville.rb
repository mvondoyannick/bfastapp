class Ville < ApplicationRecord
  validates :name, presence: true
  has_many :buses, dependent: :destroy
end
