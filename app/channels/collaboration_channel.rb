class CollaborationChannel < ApplicationCable::Channel
  include CableReady::Broadcaster

  OCCUPANCY_STORE_SUFFIX = "_occupancies"

  def subscribed
    stream_from params[:stream]
    current_user.appear(params[:stream], current_user_session)
    broadcast_occupied_fields
  end

  def unsubscribed
    current_user.disappear(params[:stream], current_user_session)
    vacate_current_user_session
    broadcast_occupied_fields
  end

  def occupy_fieldset(data)
    ActionCable.server.pubsub.redis_connection_for_subscriptions.hsetnx(occupancy_store,
                                                                        data['fieldset'],
                                                                        current_user_session)
    broadcast_occupied_fields
  end

  def vacate_fieldset(data)
    ActionCable.server.pubsub.redis_connection_for_subscriptions.hdel(occupancy_store,
                                                                      data['fieldset'])
    broadcast_occupied_fields
  end

  def self.vacate_everywhere(user)
    occupancies_removed = 0
    CollaborationChannel.occupancy_stores.each do |store|
      occupancies = ActionCable.server.pubsub.redis_connection_for_subscriptions.hgetall(store).select { |_k, v| v =~ /^#{user.id}:\w*$/ }.keys
      next if occupancies.blank?

      occupancies_removed =+ ActionCable.server.pubsub.redis_connection_for_subscriptions.hdel(store, occupancies)
    end
    occupancies_removed
  end

  private

  def self.occupancy_stores
    ActionCable.server.pubsub.redis_connection_for_subscriptions.scan(0)[1].select {|v| v=~ /\w*#{OCCUPANCY_STORE_SUFFIX}/}
  end

  def broadcast_occupied_fields
    cable_ready[params[:stream]].set_dataset_property(
      selector: 'form[data-target*="collaboration.form"',
      name: "collaborationOccupiedFieldsets",
      value: ActionCable.server.pubsub.redis_connection_for_subscriptions.hkeys(occupancy_store)
    )
    cable_ready.broadcast
  end

  def occupancy_store
    "#{params[:stream]}_occupancies"
  end

  def vacate_current_user_session
    occupancies = ActionCable.server.pubsub.redis_connection_for_subscriptions.hgetall(occupancy_store)
    session_occupancies = occupancies.select{|_k, v| v == current_user_session}.keys.join(",")
    ActionCable.server.pubsub.redis_connection_for_subscriptions.hdel(occupancy_store, session_occupancies)
  end
end
