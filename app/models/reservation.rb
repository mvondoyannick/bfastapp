class Reservation < ApplicationRecord
  has_one_attached :qr_code
  belongs_to :customer

  before_create do 
    self.token = SecureRandom.uuid
    generate_qrcode(self.token)
  end

  def generate_qrcode(code)
    # https://superails.com/products/5?abc=d+e+f
    qr_url = url_for(
      controller: 'home',
      action: 'index',
      m: code,
      host: 'travel.fly.dev',
      only_path: false,
      abc: 'from',
      udev: 'true'
    )

    # generate QR code
    qr_code = RQRCode::QRCode.new(qr_url)

    # QR code to image  
    qr_png = qr_code.as_png(
      bit_depth: 1,
      border_modules: 4,
      color_mode: ChunkyPNG::COLOR_GRAYSCALE,
      color: "black",
      file: nil,
      fill: "white",
      module_px_size: 6,
      resize_exactly_to: false,
      resize_gte_to: false,
      size: 256
    )

    # name the image
    image_name = SecureRandom.hex

    # save the image in TMP
    image = IO.binwrite("tmp/storage/#{image_name}.png", qr_png.to_s)

    # save TMP file to ActiveStorage
    # blob = ActiveStorage::Blob.create_after_upload!(
    blob = ActiveStorage::Blob.create_and_upload!(
      io: File.open("tmp/storage/#{image_name}.png"),
      filename: image_name,
      content_type: 'png'
    )

    # attach ActiveStorage::Blob to the product
    self.qr_code.attach(blob)
  end
end
