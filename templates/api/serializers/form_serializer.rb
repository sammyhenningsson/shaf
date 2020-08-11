require 'serializers/base_serializer'
require 'shaf/formable'

class FormSerializer < BaseSerializer
  model Shaf::Formable::Form
  profile 'shaf-form'

  attribute :method do
    (options[:method] || resource&.method || 'POST').to_s.upcase
  end

  %i[name title href type submit].each do |sym|
    attribute sym do
      options[sym] || resource&.public_send(sym)
    end
  end

  link :self do
    options[:self_link] || resource&.self_link
  end

  post_serialize do |hash|
    fields = resource&.fields
    next if fields.nil? || fields.empty?
    hash[:fields] = fields.map do |field|
      {
        name: field.name,
        type: field.type
      }.tap do |f|
        f[:title] = field.title if field.title
        f[:value] = field.value if field.has_value?
        f[:required] = true if field.required
        f[:hidden] = true if field.hidden
      end
    end
  end
end
