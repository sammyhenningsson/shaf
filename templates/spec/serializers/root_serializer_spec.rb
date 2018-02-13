require 'spec_helper'

describe RootSerializer do

  before do
    set_payload RootSerializer.to_hal
  end

  it "serializes links" do
    links.keys.must_include(:self)
  end
end
