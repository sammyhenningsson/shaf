require 'test_helper'

module Shaf
  describe Authenticator do
    let(:responder1) do
      Class.new(Responder::Base) do
        mime_type :foo, 'application/vnd.foo'
        def body; "one"; end
      end
    end
    let(:responder2) do
      Class.new(Responder::Base) do
        mime_type 'bar', 'application/vnd.bar'
        def body; "two"; end
      end
    end
    let(:responder3) do
      Class.new(Responder::Base) do
        mime_type :csv
        def body; "csv"; end
      end
    end
    let(:resource) do
      Object.new
    end

    before do
      responder1 and responder2
    end

    after do
      Responder.unregister responder1
      Responder.unregister responder2
      Responder.unregister responder3
    end

    def mock_request(preferred_type:)
      Class.new do
        def initialize(preferred_type)
          @preferred_type = preferred_type
        end

        def preferred_type(_types)
          @preferred_type
        end
      end.new(preferred_type)
    end

    it "registers subclasses" do
      count = Responder.send(:responders).size
      responder3
      assert_equal count + 1, Responder.send(:responders).size
    end

    it 'selects HAL by default' do
      request = mock_request(preferred_type: 'text/csv')
      responder = Responder.for(request, resource)

      assert_equal Responder::Hal, responder
    end

    it 'selects the right responder' do
      request = mock_request(preferred_type: 'application/vnd.foo')
      responder = Responder.for(request, resource)
      from_cache = Responder.for(request, resource)

      assert_equal responder1, responder
      assert_equal responder1, from_cache
    end

    it 'selects problem json only for errors' do
      mime_types_for = ->(resource) { Responder.send(:supported_responders_for, resource) }

      assert_includes mime_types_for.(Errors::BadRequestError.new), Responder::ProblemJson
      refute_includes mime_types_for.(resource), Responder::ProblemJson
    end
  end
end
