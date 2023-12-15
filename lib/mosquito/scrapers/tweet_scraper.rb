# frozen_string_literal: true

require "typhoeus"
require_relative "scraper"
require "nokogiri"
require "open-uri"

module Mosquito
  class TweetScraper < Scraper
    def parse(id)
      # Stuff we need to get from the DOM (implemented is starred):
      # - User
      # - Text *
      # - Image  / Images  / Video *
      # - Date *
      # - Number of likes *
      # - Hashtags

      Capybara.app_host = ENV["NITTER_URL"]

      # video slideshows https://www.instagram.com/p/CY7KxwYOFBS/?utm_source=ig_embed&utm_campaign=loading
      # login
      begin
        doc = Nokogiri::HTML(URI.open("#{ENV["NITTER_URL"]}/jack/status/#{id}"), nil, Encoding::UTF_8.to_s)
      rescue OpenURI::HTTPError
        raise Mosquito::NoTweetFoundError
      end

      unless doc.xpath("//div[contains(@class, 'error-panel')]").empty?
        raise Mosquito::NoTweetFoundError
      end

      debugger
      text = doc.xpath("//div[contains(@class, 'tweet-content media-body')]").first.content
      date = DateTime.parse(doc.xpath("//span[contains(@class, 'tweet-date')]").first.child["title"])
      id = URI.parse(doc.xpath("//link[contains(@rel, 'canonical')]").first["href"]).path.split("/").last
      number_of_likes = doc.xpath("//span[contains(@class, 'tweet-stat')][last()]/div").first.content.delete(",").to_i
      language = "en" # We can't determine this anymore with Nitter, but english will be fine, we don't actually use this anywhere... i think
      # user

      images = []
      videos = []
      video_preview_image = nil
      video_file_type = nil

      # # Single image
      # image_url = doc.xpath("//div[contains(@class, 'main-tweet')]/div/div/div/div/div/a[contains(@class, 'still-image')]/@href").first&.content
      # images << Mosquito.retrieve_media("#{Capybara.app_host}#{image_url}") unless image_url.nil?

      # debugger

      # Slideshow
      nodes = doc.xpath("//div[contains(@class, 'main-tweet')]/div/div/div[contains(@class, 'attachments')]/div[contains(@class, 'gallery-row')]/div/a/@href")
      images.concat(nodes.map { |node| Mosquito.retrieve_media("#{Capybara.app_host}#{node.value}") })

      # Video
      nodes = doc.xpath("//div[contains(@class, 'main-tweet')]/div/div/div[contains(@class, 'attachments')]/div[contains(@class, 'gallery-video')]/div/video")
      unless nodes.empty?
        video_preview_image = Mosquito.retrieve_media("#{Capybara.app_host}#{nodes.first["poster"]}", extension: ".jpg")
        videos.concat(nodes.map { |node| Mosquito.retrieve_media(node.xpath("//source").first["src"]) })
        video_file_type = "video" # This is always video now, sing a gif isn't displayed differently
      end

      # GIF
      nodes = doc.xpath("//div[contains(@class, 'main-tweet')]/div/div/div[contains(@class, 'attachments')]/div[contains(@class, 'gallery-gif')]/div/video")
      unless nodes.empty?
        video_preview_image = Mosquito.retrieve_media(nodes.first["poster"], extension: ".jpg")
        videos.concat(nodes.map { |node| Mosquito.retrieve_media("#{Capybara.app_host}#{node.xpath("//source[1]/source/@src").first&.content}") })
        video_file_type = "gif"
      end

      username = doc.xpath("//a[contains(@class, 'username')][1]/@href").first.value
      user = UserScraper.new.parse(username)

      screenshot_file = take_screenshot()

      {
        images: images,
        video: videos,
        video_preview_image: video_preview_image,
        screenshot_file: screenshot_file,
        text: text,
        date: date,
        number_of_likes: number_of_likes,
        user: user,
        id: id,
        language: language,
        video_file_type: video_file_type
      }
    end

    def take_screenshot
      # First check if a post has a fact check overlay, if so, clear it.
      # The only issue is that this can take *awhile* to search. Not sure what to do about that
      # since it's Instagram's fault for having such a fucked up obfuscated hierarchy      # Take the screenshot and return it
      save_screenshot("#{Mosquito.temp_storage_location}/instagram_screenshot_#{SecureRandom.uuid}.png")
    end
  end
end
