module SafeParams
  def safe_params(*fields)
    return {} unless payload
    {}.tap do |allowed|
      fields.each do |field|
        f = field.to_s.downcase
        allowed[f.to_sym] = payload[f] if payload[f]
      end
    end
  end
end
