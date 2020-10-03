require 'test_helper'
require 'rack/request'
require 'ostruct'

module Shaf
  describe Parser do
    let(:parser1) do
      Class.new(Parser::Base) do
        mime_type :foo, 'application/vnd.foo'
      end
    end
    let(:parser2) do
      Class.new(Parser::Base) do
        def self.can_handle?(request)
          /mock/.match? request.content_type
        end
      end
    end

    before do
      parser1 and parser2
    end

    after do
      Parser.unregister parser1
      Parser.unregister parser2
    end

    def mock_request(content_type:, body: "")
      Rack::Request.new(
        'rack.input' =>  StringIO.new(body),
        'CONTENT_TYPE' => content_type
      )
    end

    it "registers subclasses" do
      count = Parser.send(:parsers).size

      parser = Class.new(Parser::Base) do
        mime_type :bar, 'application/vnd.bar'
      end

      _(Parser.send(:parsers).size).must_equal count + 1
    ensure
      Parser.unregister parser
    end

    it 'selects the correct parser' do
      requests = [
        mock_request(content_type: 'application/vnd.foo'),
        mock_request(content_type: 'mocking'),
        mock_request(content_type: 'application/unknown'),
      ]

      parsers = requests.map { |request| Parser.for(request).class }

      _(parsers).must_equal [parser1, parser2, NilClass]
    end

    it 'returns the parsed body' do
      parser_class = Class.new(Parser::Base) do
        mime_type :test, 'testing'

        def call
          body.reverse
        end
      end

      request = mock_request(content_type: 'testing', body: '123')
      parser = Parser.for(request)

      _(parser.call.strip).must_equal '321'
    ensure
      Parser.unregister parser_class
    end
  end
end
