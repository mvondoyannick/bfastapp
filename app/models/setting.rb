class Setting < ApplicationRecord
  belongs_to :customer

  def complete
    if !self.tension_droite.nil? && !self.quartier.nil? && !self.diastole_droit.nil? && !self.poul_droit.nil?
      "complete"
    else
      "uncomplete"
    end
  end
end
