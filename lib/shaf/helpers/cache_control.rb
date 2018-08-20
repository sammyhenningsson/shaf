module Shaf
  module CacheControl

    def cache_control(*args, **kwargs)
      return unless Shaf::Settings.http_cache
      set_max_age(kwargs)
      super(*args, **kwargs)
    end

    private

    def set_max_age(kwargs)
      max_age = kwargs[:http_cache_max_age] or return
      if max_age.is_a? Symbol
        key = "http_cache_max_age_#{max_age}".to_sym
        max_age = Settings.respond_to?(key) ? Settings.send(key) : 86400
        kwargs[:http_cache_max_age] = max_age
      end
    end
  end
end
