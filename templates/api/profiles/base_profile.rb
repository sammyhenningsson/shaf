# frozen_string_literal: true

# Base class for all profiles
# Any descriptor that is global to all profiles
# should be added here (e.g. the "delete" link relation)
class BaseProfile < Shaf::Profile
  extend Shaf::Relations::Delete
end
