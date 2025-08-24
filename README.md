# Focev Rails Application

This is a Ruby on Rails application that serves two main purposes:

1.  A sophisticated, bilingual (French/English) WhatsApp chatbot for the "Fondation Coeur et Vie" (Heart and Life Foundation). The chatbot, "Dr. Cardio", runs a campaign called "JE CONNAIS MA TENSION" ("I KNOW MY BLOOD PRESSURE"), guiding users through a health check-up and creating a personalized "challenge" photo for them to share.
2.  A multi-purpose API with services for travel, e-commerce, and gas delivery.

The application uses the Avo gem to provide a comprehensive administration dashboard.

## Features

*   **WhatsApp Chatbot:** An interactive, multi-step chatbot for a health campaign.
*   **Bilingual Support:** The chatbot can converse in both French and English.
*   **Health Check-up:** Guides users through a series of questions to collect health data (name, sex, age, weight, height, blood pressure).
*   **Photo Challenge:**
    *   Users can submit a photo via WhatsApp.
    *   The application processes the image using Cloudinary for face detection and `remove.bg` for background removal.
    *   It then composites the user's face onto a campaign template and adds their name using MiniMagick.
    *   The final image is sent back to the user.
*   **Referral System:** Generates a unique referral link for each user to share.
*   **Admin Dashboard:** A full-featured admin panel powered by Avo for managing customers, data, and application settings.
*   **Multi-purpose API:** A versioned API with a sandbox environment for various services.

## System Requirements

*   **Ruby version:** `3.2.0`
*   **Database:** MySQL
*   **System Dependencies:**
    *   `git`
    *   `build-essential`
    *   `default-libmysqlclient-dev`
    *   `imagemagick`
    *   `libvips-dev`
    *   `ffmpeg`
    *   `curl`
    *   `wget`
    *   `gzip`
    *   `xz-utils`

## Installation and Setup

1.  **Clone the repository:**
    ```bash
    git clone <repository-url>
    cd <repository-directory>
    ```

2.  **Install Ruby and Bundler:**
    Make sure you have Ruby `3.2.0` and Bundler installed.

3.  **Install gems:**
    ```bash
    bundle install
    ```

4.  **Set up environment variables:**
    Create a `.env` file by copying the example file:
    ```bash
    cp .env.example .env
    ```
    Then, fill in the required values in the `.env` file. You will need API keys for:
    *   **WhatsApp API (ultramsg.com):** `ULTRAMSG_TOKEN`
    *   **Cloudinary:** `CLOUDINARY_CLOUD_NAME`, `CLOUDINARY_API_KEY`, `CLOUDINARY_API_SECRET`
    *   **remove.bg:** `REMOVE_BG_API_KEY`

5.  **Create and set up the database:**
    ```bash
    rails db:create
    rails db:migrate
    rails db:seed
    ```

## Running the Application

To start the Rails server, run:

```bash
rails server
```

## Running Tests

To run the test suite, use the following command:

```bash
rails test
```

## Deployment

The application is configured for deployment with Capistrano. The deployment configuration can be found in `config/deploy.rb` and the `config/deploy/` directory.

## External Services

This application relies on the following external services:

*   **WhatsApp API:** The application uses an external API to send and receive WhatsApp messages. The current implementation uses `ultramsg.com`.
*   **Cloudinary:** For image hosting, transformations, and face detection.
*   **remove.bg:** For removing the background from images.

Make sure to obtain the necessary API keys for these services and configure them in your `.env` file.
