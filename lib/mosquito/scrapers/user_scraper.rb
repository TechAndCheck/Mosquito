# frozen_string_literal: true

require "typhoeus"
require_relative "scraper"
require "nokogiri"
require "open-uri"

module Mosquito
  class UserScraper < Scraper
    def parse(username)
      # Stuff we need to get from the DOM (implemented is starred):
      # id
      # name
      # username
      # sign_up_date
      # location
      # profile_image_url
      # description
      # followers_count
      # following_count
      # tweet_count
      # listed_count
      # verified
      # url
      # profile_image_file_name

      Capybara.app_host = ENV["NITTER_URL"]

      username = username.delete("/")

      doc = Nokogiri::HTML(URI.open("#{ENV["NITTER_URL"]}/#{username}"), nil, Encoding::UTF_8.to_s)

      unless doc.xpath("//div[contains(@class, 'error-panel')]").empty?
        raise Mosquito::NoTweetFoundError
      end

      id = username
      full_name = doc.xpath("//a[contains(@class, 'profile-card-fullname')]/@title").first&.value
      username = username
      sign_up_date = DateTime.parse(doc.xpath("//div[contains(@class, 'profile-joindate')]/span/@title").first&.value)
      location = doc.xpath("//div[contains(@class, 'profile-location')]/span[last()]").first&.content
      profile_image_url = "#{Capybara.app_host}#{doc.xpath("//a[contains(@class, 'profile-card-avatar')]/@href").first&.value}"
      description = doc.xpath("//div[contains(@class, 'profile-bio')]/p").first&.content
      followers_count = doc.xpath("//li[contains(@class, 'followers')]/span[contains(@class, 'profile-stat-num')]").first&.content&.delete(",").to_i
      following_count = doc.xpath("//li[contains(@class, 'following')]/span[contains(@class, 'profile-stat-num')]").first&.content&.delete(",").to_i
      tweet_count = doc.xpath("//li[contains(@class, 'posts')]/span[contains(@class, 'profile-stat-num')]").first&.content&.delete(",").to_i
      listed_count = 0 # We can't get this from nitter, and it's not a big deal
      verified = !doc.xpath("//a[contains(@class, 'profile-card-fullname')]/div/span[contains(@title, 'Verified account')]").empty?
      url = doc.xpath("//div[contains(@class, 'profile-website')]/span[last()]/a/@href").first&.content
      profile_image_file_name = Mosquito.retrieve_media(profile_image_url)

      user = {
        id: id,
        name: full_name,
        username: username,
        sign_up_date: sign_up_date,
        location: location,
        profile_image_url: profile_image_url,
        description: description,
        followers_count: followers_count,
        following_count: following_count,
        tweet_count: tweet_count,
        listed_count: listed_count,
        verified: verified,
        url: url,
        profile_image_file_name: profile_image_file_name
      }

      user
    end

    def take_screenshot
      # First check if a post has a fact check overlay, if so, clear it.
      # The only issue is that this can take *awhile* to search. Not sure what to do about that
      # since it's Instagram's fault for having such a fucked up obfuscated hierarchy      # Take the screenshot and return it
      save_screenshot("#{Mosquito.temp_storage_location}/instagram_screenshot_#{SecureRandom.uuid}.png")
    end
  end
end
