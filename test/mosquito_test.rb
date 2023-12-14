# frozen_string_literal: true

require "test_helper"

class MosquitoTest < Minitest::Test
  def test_that_it_has_a_version_number
    assert_same ::Mosquito::VERSION.nil?, false
  end

  def test_that_errors_can_be_thrown
    assert_raises(Mosquito::Error) do
      raise Mosquito::Error
    end

    assert_raises(Mosquito::AuthorizationError) do
      raise Mosquito::AuthorizationError, "This is a test"
    end

    assert_raises(Mosquito::InvalidIdError) do
      raise Mosquito::InvalidIdError
    end
  end
end
