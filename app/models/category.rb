class Category < ApplicationRecord
  has_many :products, dependent: :destroy
  validates :name, presence: true
  has_one_attached :logo
  before_create do 
    self.token = SecureRandom.uuid
  end
end
