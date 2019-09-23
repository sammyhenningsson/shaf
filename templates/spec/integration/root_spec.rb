require 'spec_helper'

describe "Root", type: :integration do

  before do
    get root_uri
    _(status).must_equal 200
  end

  it "returns links" do
    _(links).must_include :self
  end

end
