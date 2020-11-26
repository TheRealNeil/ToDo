class User < ApplicationRecord
  include CableReady::Broadcaster
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :masqueradable, :database_authenticatable, :registerable, :recoverable, :rememberable, :validatable, :omniauthable

  has_one_attached :avatar
  has_person_name

  has_many :notifications, as: :recipient
  has_many :services

  PRESENCE_STORE_SUFFIX = "_presence"

  def self.presence_stores
    ActionCable.server.pubsub.redis_connection_for_subscriptions.scan(0)[1].select {|v| v=~ /\w*#{PRESENCE_STORE_SUFFIX}/}
  end

  def colour
    # Burgundy, Green, Plum, Orange, Pink, Turquoise, Purple ish
    colours = %w[90323D 4F9D69 D33E43 FBB13C D81159 218380 8F2D56]
    letters = %w[A B C D E F G H I J K L M N O P Q R S T U V W X Y Z]
    if letters.include?(initials.first)
      colours[letters.index(initials.first) % 7]
    else
      'C0C0C0'
    end
  end

  def initials
    first_name.blank? || last_name.blank? ? '??' : first_name.first + last_name.split(' ').last.first
  end

  def appear(stream, session)
    ActionCable.server.pubsub.redis_connection_for_subscriptions.hset(presence_store(stream),
                                                                      session,
                                                                      {initials: initials, colour: colour }.to_json)
    broadcast_presence(stream)
  end

  def disappear(stream, session)
    ActionCable.server.pubsub.redis_connection_for_subscriptions.hdel(presence_store(stream), session)
    broadcast_presence(stream)
  end

  def disappear_everywhere
    sessions_removed = 0
    User.presence_stores.each do |store|
      sessions = ActionCable.server.pubsub.redis_connection_for_subscriptions.hgetall(store).select { |k, _v| k =~ /^#{self[:id]}:\w*$/ }.keys
      next if sessions.blank?

      sessions_removed =+ ActionCable.server.pubsub.redis_connection_for_subscriptions.hdel(store, sessions)
      broadcast_presence(store.chomp(PRESENCE_STORE_SUFFIX))
    end
    sessions_removed
  end

  private

  def broadcast_presence(stream)
    cable_ready[stream].inner_html(
        selector: '#user_presence',
        html: ApplicationController.new.render_to_string(
            partial: 'user/present',
            collection: ActionCable.server.pubsub.redis_connection_for_subscriptions.hgetall(presence_store(stream))
        )
    )
    cable_ready.broadcast
  end

  def presence_store(stream)
    stream + PRESENCE_STORE_SUFFIX
  end
end
