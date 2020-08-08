# frozen_string_literal: true

module Shaf
  module Profiles
    class ShafBasic < Shaf::Profile
      name 'shaf-basic'

      rel :delete,
          http_method: :delete,
          doc: <<~DOC
            When a resource contains a link with rel 'delete', this
            means that the autenticated user or any user if the
            current users has not been authenticated, may send a
            DELETE request to the links href.  The result will be
            that the resource containing this link will be deleted.
          DOC
    end
  end
end
