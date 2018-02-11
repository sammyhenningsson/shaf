require 'spec_helper'

describe "RootSerializer" do

  before do
    payload Serializers::Root.to_hal
  end

  it "serializes links" do
    links.keys.must_include(:self)
  end
end
