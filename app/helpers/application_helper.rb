module ApplicationHelper
  def self.update_phone_number(phone)
    p = phone.to_s
    if p.length == 11
      new_p = p.split("237").last
      new_phone = "2376#{new_p}"
    else
      p
    end
  end

  def self.token
    "warning41644159v2rr"
  end

  def self.cloudinary(phone, img)
    require "cloudinary"
    require "cloudinary/uploader"
    require "cloudinary/utils"

    # configuration
    Cloudinary.config do |config|
      config.cloud_name = "diqsvucdn"
      config.api_key = "127829381549272"
      config.api_secret = "Bv9KguwYaSSr3BtcNuhCU2YpE84"
      config.secure = true
    end

    Cloudinary::Uploader.upload img.delete(" "), public_id: "focev_img"

    Cloudinary::Utils.cloudinary_url(
      "focev_img",
      gravity: "face",
      width: 200,
      height: 200,
      crop: "thumb"
    )
  end
end
