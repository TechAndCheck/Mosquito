# frozen_string_literal: true

require "json"
require "typhoeus"
require "date"
require "securerandom"
require "helpers/configuration"
require "fileutils"
require "terrapin"

require_relative "mosquito/version"
require_relative "mosquito/tweet"
require_relative "mosquito/user"
require_relative "mosquito/scrapers/scraper"
require_relative "mosquito/scrapers/tweet_scraper"
require_relative "mosquito/scrapers/user_scraper"

require_relative "mosquito/monkeypatch"

module Mosquito
  extend Configuration

  class Error < StandardError; end
  class AuthorizationError < Error; end
  class InvalidIdError < Error; end
  class InvalidMediaTypeError < Error; end
  class NoTweetFoundError < Error; end
  class RateLimitExceeded < Error
    attr_reader :rate_limit
    attr_reader :rate_remaining
    attr_reader :reset_time_left

    def initialize(rate_limit, rate_remaining, reset_time)
    end
  end

  define_setting :temp_storage_location, "tmp/mosquito"
  define_setting :nitter_url, ENV["NITTER_URL"]
  define_setting :save_media, true

  # The general fields to always return for Users
  def self.user_fields
    "name,created_at,location,profile_image_url,protected,public_metrics,url,username,verified,withheld,description"
  end

  # The general fields to always return for Tweets
  def self.tweet_fields
    "attachments,author_id,conversation_id,created_at,entities,geo,id,in_reply_to_user_id,lang"
  end

  # Get media from a URL and save to a temp folder set in the configuration under
  # temp_storage_location
  def self.retrieve_media(url, extension: nil)
    return "" if url.nil?
    return "" if !Mosquito.save_media

    response = Typhoeus.get(url)

    # If this is an m3u playlist, parse it it first
    if response.body.start_with?("#EXTM3U")
      temp_file_name = download_m3u_playlist(url)
      return temp_file_name
    end

    # Get the file extension if it's in the file
    if extension.nil?
      extension = url.split(".").last

      # Do some basic checks so we just empty out if there's something weird in the file extension
      # that could do some harm.
      if extension.length.positive?
        extension = extension[0...extension.index("?")]
        extension = nil unless /^[a-zA-Z0-9]+$/.match?(extension)
        extension = ".#{extension}" unless extension.nil?
      end
    end

    temp_file_name = "#{Mosquito.temp_storage_location}/#{SecureRandom.uuid}#{extension}"

    # We do this in case the folder isn't created yet, since it's a temp folder we'll just do so
    self.create_temp_storage_location
    File.binwrite(temp_file_name, response.body)
    temp_file_name
  end

private

  def self.create_temp_storage_location
    return if File.exist?(Mosquito.temp_storage_location) && File.directory?(Mosquito.temp_storage_location)
    FileUtils.mkdir_p Mosquito.temp_storage_location
  end

  def self.download_m3u_playlist(url)
    # ffmpeg -i https://nitter.ktachibana.party/video/BBAC238EE870E/https%3A%2F%2Fvideo.twimg.com%2Fext_tw_video%2F1734886533503549440%2Fpu%2Fpl%2FSwWhbDP6oC35nlvU.m3u8%3Ftag%3D12%26container%3Dfmp4 -c copy test.mp4
    line = Terrapin::CommandLine.new("ffmpeg", "-i :url -c copy :path")
    path = "#{Mosquito.temp_storage_location}/#{SecureRandom.uuid}.mp4"
    success = line.run(path: path, url: url)
    return path if success.empty?
    false
  end
end
