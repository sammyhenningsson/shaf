require 'set'

module LetBang
  module ClassMethods
    def let!(name, &block)
      return unless respond_to? :let
      let(name, &block)
      let_bangs << name
    end

    def let_bangs
      @let_bangs ||= Set.new
    end
  end

  def self.included(base)
    base.extend ClassMethods
  end

  def let_bangs
    klass = self.class
    Set.new.tap do |bangs|
      loop do
        bangs.merge(klass.let_bangs) if klass.respond_to? :let_bangs
        klass = klass.superclass
        break if Object == klass
      end
    end
  end
end

