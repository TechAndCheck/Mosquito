# frozen_string_literal: true

require "test_helper"
require "date"

class UserTest < Minitest::Test
  def teardown
    cleanup_temp_folder
  end

  # def test_that_a_user_is_created_with_id
  #   tweets = Mosquito::User.lookup("f_obermaier")
  #   tweets.each { |user| assert_instance_of Mosquito::User, user }
  # end

  # # This could break if Frederik ever changes his info. That's probably the reason if this is failing
  # def test_that_a_user_has_correct_attributes
  #   user = Mosquito::User.lookup("f_obermaier").first
  #   assert_equal "f_obermaier", user.id
  #   assert_equal DateTime.parse("2011-11-04T07:18:00.000Z"), user.created_at
  #   assert_equal "https://nitter.ktachibana.party/pic/pbs.twimg.com%2Fprofile_images%2F1140973306889277440%2Fq3P0CIh6.jpg", user.profile_image_url
  #   assert_equal "Frederik Obermaier", user.name
  #   assert_equal "f_obermaier", user.username
  #   assert_equal "Threema FPN4FKZE  | PGP", user.location
  #   assert user.description.include? "journalist"
  #   assert_nil user.url
  #   assert_kind_of Integer, user.followers_count
  #   assert_kind_of Integer, user.following_count
  #   assert_kind_of Integer, user.tweet_count
  #   assert_kind_of Integer, user.listed_count
  #   assert user.verified == false
  #   assert user.profile_image_file_name.empty? == false

  #   # Make sure the file is created properly
  #   assert File.exist?(user.profile_image_file_name) && File.file?(user.profile_image_file_name)
  # end

  # def test_that_a_user_has_a_url
  #   user = Mosquito::User.lookup("scrippsnews").first
  #   assert_equal "https://www.scrippsnews.com/where-to-watch/", user.url
  # end

  # def test_that_a_verified_user_is_probably_marked
  #   user = Mosquito::User.lookup("jack").first
  #   assert user.verified
  # end
end
