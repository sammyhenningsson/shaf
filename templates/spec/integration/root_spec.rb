require 'spec_helper'

describe Car, type: :integration do

  before do
    get root_uri
    status.must_equal 200
  end

  it "returns links" do
    links.must_include :self
  end

end
