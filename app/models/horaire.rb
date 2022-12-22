class Horaire < ApplicationRecord
  #has_many :buses, dependent: :destroy

  before_create do 
    self.name = self.departure.strftime('%H')
  end

end
