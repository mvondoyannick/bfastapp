module CloudinaryFocev
  include ActionView::Helpers::AssetUrlHelper

  class FaceRecognition
    def initialize(argv)
      require "cloudinary"
      require "cloudinary/uploader"
      require "cloudinary/utils"
      require "mini_magick"

      # read parameters
      @phone = argv[:phone]
      @img_url = argv[:img_url]

      # configuration
      Cloudinary.config do |config|
        config.cloud_name = "diqsvucdn"
        config.api_key = "127829381549272"
        config.api_secret = "Bv9KguwYaSSr3BtcNuhCU2YpE84"
        config.secure = true
      end

      RemoveBg.configure do |config|
        config.api_key = "Qp7kGiHaf2KSuhhEXAz3YMav"
      end

      def uploade
        # Cloudinary::Uploader.upload "https://s3.eu-central-1.amazonaws.com/ultramsgmedia/2023/4/41644/b7c3933f8f99c7a1ee090caf2da648ee", public_id: "olympic_flag"

        Cloudinary::Uploader.upload @img_url, public_id: "focev_img"

        @image_url =
          Cloudinary::Utils.cloudinary_url(
            "focev_img",
            gravity: "face",
            width: 200,
            height: 200,
            crop: "thumb"
          )

        first_image =
          MiniMagick::Image.open(
            "https://mppp-goshen.com/wp-content/uploads/2023/04/challenge.jpg"
          )
        second_image = MiniMagick::Image.open(@image_url)
        result =
          first_image.composite(second_image) do |c|
            c.compose "Over" # OverCompositeOp
            c.geometry "+330+240" # copy second_image onto first_image from (20, 20)
          end
        @tmp_name = SecureRandom.hex(10)
        result.write "app/assets/images/#{@tmp_name}.png"

        @down = Down.download(@image_url)
        FileUtils.mv(@down.path, "#{@tmp_name}.jpg")

        im = Magick::Image.read("#{@tmp_name}.jpg").first

        circle = Magick::Image.new 200, 200
        gc = Magick::Draw.new
        gc.fill "black"
        gc.circle 100, 100, 100, 1
        gc.draw circle

        mask = circle.blur_image(0, 1).negate

        # mask.matte = false
        # im.matte = true
        im.composite!(
          mask,
          Magick::CenterGravity,
          # Magick::CopyAlphaCompositeOp,
          Magick::OverCompositeOp
          # Magick::CopyOpacityCompositeOp
        )

        im.write "walter_circle.png"

        puts "saved"
        #upload photo to activeStorage
        @photo_init = Down.download(Customer.first.photo)
        @image = File.open("app/assets/images/#{@tmp_name}.png")
        Customer.first.challenge.attach(
          io: @image,
          filename: "#{@tmp_name}.png",
          content_type: "image/png"
        )

        # upload to active storage
        @image = File.open("app/assets/images/#{@tmp_name}.png")
        Customer.first.challenge.attach(
          io: @image,
          filename: "#{@tmp_name}.png",
          content_type: "image/png"
        )
      end
    end
  end
end
