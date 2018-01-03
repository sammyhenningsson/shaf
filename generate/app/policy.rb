class UserPolicy
  include HALDecorator::Policy::DSL

  attribute :username, :email

  link :self

  link :edit, :delete, :'edit-form' do
    !resource.id.nil? && current_user&.id == resource.id
  end

end
