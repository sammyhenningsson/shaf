# frozen_string_literal: true

module Shaf
  module Profiles
    module Relations
      module Delete
        def self.extended(profile)
          profile.rel :delete,
                      http_methods: [:delete],
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
  end
end
