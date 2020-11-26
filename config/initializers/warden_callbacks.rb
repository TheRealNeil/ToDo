Warden::Manager.before_logout do |user,_auth,_opts|
  # Remove the user from all presence channels
  user.disappear_everywhere
  # Remove the user from all collaboration channels
  CollaborationChannel.vacate_everywhere(user)
end
