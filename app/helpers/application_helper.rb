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

  def self.whatsApp
  end
  # Qp7kGiHaf2KSuhhEXAz3YMav

  def self.token
    "5v5at5lta1ploldb" #warning41644159v2rr"
  end

  def self.cloudinary(id, img)
    require "cloudinary"
    require "cloudinary/uploader"
    require "cloudinary/utils"

    @id = id
    @img = img

    @customer = Customer.find(@id)

    # configuration
    Cloudinary.config do |config|
      config.cloud_name = "diqsvucdn"
      config.api_key = "127829381549272"
      config.api_secret = "Bv9KguwYaSSr3BtcNuhCU2YpE84"
      config.secure = true
    end

    @random_name = SecureRandom.hex(3)

    begin
      Cloudinary::Uploader.upload @img, public_id: @customer.phone
      @response =
        Cloudinary::Utils.cloudinary_url(
          @customer.phone,
          gravity: "face",
          width: 200,
          height: 200,
          crop: "thumb",
        )

      first_image =
        MiniMagick::Image.open(
          "https://mppp-goshen.com/wp-content/uploads/2023/04/challenge-1.jpg"
        )
      second_image = MiniMagick::Image.open(@response)
      result =
        first_image.composite(second_image) do |c|
          c.compose "Over" # OverCompositeOp
          c.geometry "+330+240" # copy second_image onto first_image from (20, 20)
        end
      @tmp_name = SecureRandom.hex(10)
      result.write "#{@customer.phone}.png"

      # attach this to user
      @down = Down.download(@response)
      FileUtils.mv(@down.path, "#{@customer.phone}.png")

      #upload photo to activeStorage
      @photo_init = Down.download(Customer.first.photo)
      @image = File.open("#{@customer.phone}.png")
      Customer.first.challenge.attach(
        io: @image,
        filename: "#{@tmp_name}.png",
        content_type: "image/png",
      )

      # upload to active storage
      @image = File.open("#{@customer.phone}.png")
      Customer.first.challenge.attach(
        io: @image,
        filename: "#{@tmp_name}.png",
        content_type: "image/png",
      )

      # update user
      @customer.update(is_cropped: true)
      @customer.update(cropped: @response)

      # upload to active storage
      if @customer.challenge.attached?
        @image = File.open("#{@customer.phone}.png")
        Customer.first.challenge.attach(
          io: @image,
          filename: "#{@tmp_name}.png",
          content_type: "image/png",
        )

        @img
      else
        # nothing to do
      end
    rescue => exception
      "Impossible de mettre à jour"
    end

    # Cloudinary::Uploader.upload @img.delete(" "), public_id: @random_name
  end
end
