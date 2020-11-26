module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user, :session_id, :current_user_session

    def connect
      self.current_user = find_verified_user
      self.session_id = request.session.id
      self.current_user_session = "#{current_user.id}:#{session_id}"
      logger.add_tags "ActionCable", "User #{current_user.id}", "Session #{session_id}"
    end

    protected

      def find_verified_user
        if (current_user = env['warden'].user)
          current_user
        else
          reject_unauthorized_connection
        end
      end
  end
end
