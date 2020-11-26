class List < ApplicationRecord
  belongs_to :user
  has_many :items, -> { order(position: :asc) }, inverse_of: :list, dependent: :destroy
  accepts_nested_attributes_for :items, reject_if: :all_blank, allow_destroy: true

  # validates :name, presence: true

  def occupied_fieldsets
    ActionCable.server.pubsub.redis_connection_for_subscriptions.hkeys occupancy_store
  end

  def stream_id
    ActionView::RecordIdentifier.dom_id(self)
  end

  private

  def occupancy_store
    "#{stream_id}_occupancies"
  end
end
