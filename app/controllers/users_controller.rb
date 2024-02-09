class UsersController < ApplicationController
  def index
    @users = User.search(search_params)
    if @users.any?
      render json: { html: render_to_string(partial: 'user', collection: @users) }
    else
      render json: { html: '<li style="line-height: 1.5; list-style-type: none; padding: 0.375rem 0.75rem;">Nothing matching users found</li>' }
    end
  end

  def search_params
    params.permit([:q]).to_h
  end
end
