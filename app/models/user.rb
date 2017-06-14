class User < Sequel::Model

  def to_api
    {
      id: 4,
      name: "hej"
    }
  end
end

