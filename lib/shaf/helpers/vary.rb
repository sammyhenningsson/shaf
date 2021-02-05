module Shaf
  module Vary
    def vary(*varying)
      current = headers['Vary']
      headers('Vary' => [current, *varying].compact.join(','))
    end
  end
end
