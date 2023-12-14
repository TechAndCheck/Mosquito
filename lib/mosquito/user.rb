# frozen_string_literal: true

module Mosquito
  class User
    # Attributes for after the response is parsed from Twitter
    attr_reader :json
    attr_reader :id
    attr_reader :name
    attr_reader :username
    attr_reader :sign_up_date
    attr_reader :location
    attr_reader :profile_image_url
    attr_reader :description
    attr_reader :url
    attr_reader :followers_count
    attr_reader :following_count
    attr_reader :tweet_count
    attr_reader :listed_count
    attr_reader :verified
    attr_reader :created_at
    attr_reader :profile_image_file_name

  private

    def self.lookup(ids = [])
      # If a single id is passed in we make it the appropriate array
      ids = [ids] unless ids.kind_of?(Array)

      # Check that the ids are at least real ids
      user_objects = ids.map { |id| Mosquito::UserScraper.new.parse(id) }

      user_objects.map do |user_object|
        User.new(user_object)
      end
    end

    def initialize(user_object)
      @id = user_object[:id]
      @name = user_object[:name]
      @username = user_object[:username]
      @created_at = user_object[:sign_up_date]
      @location = user_object[:location]

      # Removing the "normal" here gets us the full-sized image, instead of the 150x150 thumbnail
      @profile_image_url = user_object[:profile_image_url]

      @description = user_object[:description]
      @url = user_object[:url]
      @followers_count = user_object[:followers_count]
      @following_count = user_object[:following_count]
      @tweet_count = user_object[:tweet_count]
      @listed_count = user_object[:listed_count]
      @verified = user_object[:verified] # this will always be `false` but we're keeping it here for compatibility
      @profile_image_file_name = user_object[:profile_image_file_name]
    end
  end
end
