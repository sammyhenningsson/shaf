module Shaf
  module Generator
    module StubbedOutput
      def self.extended(base)
        base.let(:output) { {} }

        base.let(:write_stub) do
          lambda do |file, content|
            output[file] = content
          end
        end

        base.before do
          assert generator, <<~ERR
            Test #{base} must specify a 'generator' varible. Like:

            let(:generator) { Factory.create(*%w(policy blog)) }

          ERR

          File.stub :write, write_stub do
            Dir.stub :exist?, true do
              Mutable.suppress_output { generator.call }
            end
          end
        end
      end
    end
  end
end
