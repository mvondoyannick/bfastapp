class Entreprise < ApplicationRecord
  validates :name, :as_agence, presence: true
  has_one_attached :logo
end
