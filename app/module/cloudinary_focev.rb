module CloudinaryFocev
  class FaceRecognition
    def initialize(argv)
      require "cloudinary"
      require "cloudinary/uploader"
      require "cloudinary/utils"

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

      def uploade
        # Cloudinary::Uploader.upload "https://s3.eu-central-1.amazonaws.com/ultramsgmedia/2023/4/41644/b7c3933f8f99c7a1ee090caf2da648ee", public_id: "olympic_flag"

        Cloudinary::Uploader.upload @img_url, public_id: "focev_img"

        Cloudinary::Utils.cloudinary_url(
          "focev_img",
          gravity: "face",
          width: 200,
          height: 200,
          crop: "thumb"
        )
      end
    end
  end
end
