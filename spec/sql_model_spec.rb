require 'spec_helper'

describe "What environment are we running in?" do
  it "Should be test" do
    assert_equal ENV['RACK_ENV'],  nil
  end
end
