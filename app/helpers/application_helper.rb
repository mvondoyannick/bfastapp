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

  def self.cloudinary(id, phone, img)
    require "cloudinary"
    require "cloudinary/uploader"
    require "cloudinary/utils"

    @phone = phone
    @img = img
    @id = id

    # configuration
    Cloudinary.config do |config|
      config.cloud_name = "diqsvucdn"
      config.api_key = "127829381549272"
      config.api_secret = "Bv9KguwYaSSr3BtcNuhCU2YpE84"
      config.secure = true
    end

    @random_name = SecureRandom.hex(3)

    Cloudinary::Uploader.upload @img.delete(" "), public_id: @random_name

    @response =
      Cloudinary::Utils.cloudinary_url(
        @random_name,
        gravity: "face",
        width: 200,
        height: 200,
        crop: "thumb"
      )

    # update user

    @customer = Customer.find(@id)
    @customer.update(is_cropped: true)
    @customer.update(cropped: @response)

    # send notification
    @a =
      WhatsApp::WhatsappMessages.new(
        @phone,
        "Le traitement est terminée et votre image est désormais disponible. Merci de nous faire confiance."
      )
  end
end
