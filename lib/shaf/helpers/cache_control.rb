module Shaf
  module CacheControl
    def cache_control(*args, **kwargs)
      __rewrite_max_age(kwargs)
      super(*args, **kwargs)
    end

    private

    def __rewrite_max_age(kwargs)
      max_age = kwargs.delete(:http_cache_max_age)
      if max_age.is_a? Symbol
        key = :"http_cache_max_age_#{max_age}"
        max_age = Settings.respond_to?(key) ? Settings.send(key) : 86_400
      end
      kwargs[:max_age] ||= max_age
    end
  end
end
