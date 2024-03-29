class Customer < ApplicationRecord
  has_one_attached :qr_code
  has_one_attached :challenge
  has_one_attached :photos
  has_one_attached :face
  has_rich_text :body
  after_create :generate_qr
  after_create :generate_link
  has_many :settings
  has_many :erreurs
  def self.ransackable_attributes(auth_object = nil)
    %w[
      age
      created_at
      id
      ip
      link
      phone
      pushname
      quartier
      sexe
      tension_droit
      tension_gauche
      updated_at
    ]
  end

  # customer appelation with sexe
  def appelation
    if self.real_name.nil?
      case self.sexe
      when "feminin"
        case self.lang
        when "fr"
          "Mme/Mlle *#{self.pushname.upcase}*"
        when "en"
          "Mrs *#{self.pushname.upcase}*"
        end
      when "masculin"
        case self.lang
        when "fr"
          "Mr *#{self.pushname.upcase}*"
        when "en"
          "Mr. *#{self.pushname.upcase}*"
        end
      else
        "*#{self.pushname.upcase}*"
      end
    else
      case self.sexe
      when "feminin"
        case self.lang
        when "fr"
          "Mme/Mlle *#{self.real_name.upcase}*"
        when "en"
          "Mrs *#{self.real_name.upcase}*"
        end
      when "masculin"
        case self.lang
        when "fr"
          "Mr *#{self.real_name.upcase}*"
        when "en"
          "Mr. *#{self.real_name.upcase}*"
        end
      else
        "*#{self.real_name.upcase}*"
      end
    end
  end

  # generate link
  def generate_link
    phone = Base64.encode64(self.phone)
    qr_url =
      url_for(
        # protocol: "https",
        controller: "main",
        action: "index",
        # id: self.code,
        host: "coeur-vie.org",
        only_path: false,
        coev: phone,
      )

    # add link to record
    self.linked = "coeur-vie.org/challenge?cid=#{phone}" #qr_url
  end

  # correct phone number
  def phone_number(phone)
    p = self.phone.to_s
    if p.length == 11
      new_p = p.split("237").last
      new_phone = "2376#{new_p}"
    else
      p
    end
  end

  def generate_qr
    require "rqrcode"

    # https://superails.com/products/5?abc=d+e+f
    qr_url =
      url_for(
        controller: "main",
        action: "index",
        id: self.code,
        host: "superails.com",
        only_path: false,
        abc: "fcv",
      )

    # generate QR code
    qr_code = RQRCode::QRCode.new(qr_url)

    # QR code to image
    qr_png =
      qr_code.as_png(
        bit_depth: 1,
        border_modules: 4,
        color_mode: ChunkyPNG::COLOR_GRAYSCALE,
        color: "black",
        file: nil,
        fill: "white",
        module_px_size: 6,
        resize_exactly_to: false,
        resize_gte_to: false,
        size: 128,
      )

    # name the image
    image_name = "qr_#{SecureRandom.hex}"

    # save the image in TMP
    image = IO.binwrite("tmp/storage/#{image_name}.png", qr_png.to_s)

    # save TMP file to ActiveStorage
    blob =
      ActiveStorage::Blob.create_and_upload!(
        io: File.open("tmp/storage/#{image_name}.png"),
        filename: image_name,
        content_type: "png",
      )

    # attach ActiveStorage::Blob to the product
    self.qr_code.attach(blob)
  end
end
