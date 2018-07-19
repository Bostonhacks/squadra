require "minitest/autorun"

class TestMailgun < Minitest::Test
  def setup
  end

  def test_that_will_be_skipped
    skip "test this later"
  end
end