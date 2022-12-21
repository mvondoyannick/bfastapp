class Horaire < ApplicationRecord
  #has_many :buses, dependent: :destroy
  belongs_to :bus
  belongs_to :food
  belongs_to :drink
end
