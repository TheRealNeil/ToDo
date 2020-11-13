class Item < ApplicationRecord
  belongs_to :list, inverse_of: :items
  acts_as_list scope: :list
end
