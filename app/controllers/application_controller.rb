# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include PublicActivity::StoreController
  include ChangelogContextApplication
  include Localization

  acts_as_token_authentication_handler_for User

  before_action :authenticate_user!
  before_action :prepare_exception_notifier

  etag { Rails.application.importmap.digest(resolver: helpers) if request.format&.html? }

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  # allow_browser versions: :modern

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception, unless: -> { request.format.json? }
  protect_from_forgery with: :null_session, if: -> { request.format.json? }

  rescue_from ActiveRecord::RecordNotFound, with: :show_not_found_error
  rescue_from ActiveRecord::RecordNotUnique, with: :show_api_error

  layout :layout_by_resource

  def after_sign_in_path_for(resource)
    # return request.env['omniauth.origin'] || stored_location_for(resource) || root_path
    #=> with our setup, omniauth.origin always contain sign_in page since user was first redirected on it
    return stored_location_for(resource) || root_path
  end

  def track_updated_values(object, new_params)
    new_params = new_params.to_unsafe_h.stringify_keys! # Avoid symbol keys
    updated_values = {}
    old_values = object.attributes
    object.assign_attributes(new_params)
    object.changed.each do |attribute|
      updated_values[attribute] = [old_values[attribute].to_s, new_params[attribute]] if old_values[attribute] != new_params[attribute]
    end
    return updated_values
  end

  # TODO: remove when fully moved in processor
  def sorted(collection)
    direction = %w[asc desc].include?(params[:sort]) ? params[:sort] : "desc"
    column = params[:sort_by]

    return collection unless column

    collection.reorder(column => direction)
  end

  private

  def prepare_exception_notifier
    request.env["exception_notifier.exception_data"] = {
      :current_user => current_user
    }
  end

  def show_not_found_error(exception)
    raise exception unless request.format == :json

    head :not_found
  end

  def show_api_error(exception)
    raise exception unless request.format == :json

    render json: { exception: { name: exception.class.name, message: exception.message } }, status: :internal_server_error
  end

  def layout_by_resource
    if devise_controller? && !user_signed_in?
      "devise"
    else
      "application"
    end
  end
end
