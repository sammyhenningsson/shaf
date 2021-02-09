module Shaf
  module Generator
    module StubbedOutput
      def self.extended(base)
        base.let(:subject) do
          generator.call
        end

        base.let(:output) { {} }

        base.let(:write_stub) do
          lambda do |file, content|
            output[file] = content
          end
        end

        base.let(:open_stub) do
          w_stub = write_stub
          lambda do |file, flag, &block|
            raise(
              NotImplementedError,
              "Stubbing with flag #{flag} is not supported"
            ) unless flag == 'w'

            fd_mock = Object.new
            fd_mock.define_singleton_method(:write) { |str| w_stub.call(file, str) }
            fd_mock.define_singleton_method(:puts) { |str| write(str) }
            fd_mock.define_singleton_method(:close) { }

            block ? block.call(fd_mock) : fd_mock
          end
        end

        base.before do
          assert generator, <<~ERR
            Test #{base} must specify a 'generator' varible. Like:

            let(:generator) { Factory.create(*%w(policy blog)) }

          ERR

          File.stub :write, write_stub do
            File.stub :open, open_stub do
              Dir.stub :exist?, true do
                Mutable.suppress_output { subject }
              end
            end
          end
        end
      end
    end
  end
end
