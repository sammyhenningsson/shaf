# frozen_string_literal: true

module Shaf
  module Profiles
    class ShafBasic < Shaf::Profile
      name 'shaf-basic'

      rel :delete,
          http_method: :delete,
          doc: <<~DOC
            When a resource contains a link with rel 'delete', this
            means that the autenticated user (or any user if the
            current user has not been authenticated), may send a
            DELETE request to the href of the link.
            If a DELETE request is sent to this href then the corresponding
            resource will be deleted.
          DOC
    end
  end
end
