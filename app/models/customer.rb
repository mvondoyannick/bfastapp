class Customer < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :reservation, dependent: :destroy
  
  before_create do 
    self.email = "#{self.phone}@bfast.com"
    self.token = SecureRandom.uuid
  end
end
