module ApplicationHelper

  def self.update_phone_number(phone)
    p = phone.to_s 
    if p.length == 11
      new_p = p.split('237').last 
      new_phone = "2376#{new_p}"
    else
      p
    end
  end

  def self.token
    'warning41644159v2rr'
  end
  
end
