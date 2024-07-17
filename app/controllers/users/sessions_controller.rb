# frozen_string_literal: true

module Users
  class SessionsController < Devise::SessionsController
    respond_to :json
    # before_action :configure_sign_in_params, only: [:create]

    # GET /resource/sign_in
    def new
      # Authenticate the user
      self.resource = warden.authenticate!(auth_options)
      sign_in(resource_name, resource)

      # Generate JWT token
      token = Warden::JWTAuth::UserEncoder.new.call(resource, :user, nil).first

      # Return the token and user info in the response
      render json: { message: 'Signed in successfully.', user: resource, token: }, status: :ok
    rescue Warden::NotAuthenticated => e
      Rails.logger.error "Error during sign in: #{e.message}"
      render json: { message: 'Sign in failed', errors: ['Invalid email or password'] }, status: :unauthorized
    rescue StandardError => e
      Rails.logger.error "Unexpected error during sign in: #{e.message}"
      render json: { message: 'Sign in failed', errors: [e.message] }, status: :internal_server_error
    end


  def create
    # Authenticate the user
    self.resource = warden.authenticate!(auth_options)
    sign_in(resource_name, resource)

    # Generate JWT token
    token = Warden::JWTAuth::UserEncoder.new.call(resource, :user, nil).first

    # Return the token and user info in the response
    render json: { message: 'Signed in successfully.', user: resource, token: token }, status: :ok
  rescue Warden::NotAuthenticated => e
    Rails.logger.error "Error during sign in: #{e.message}"
    render json: { message: 'Sign in failed', errors: ['Invalid email or password'] }, status: :unauthorized
  rescue StandardError => e
    Rails.logger.error "Unexpected error during sign in: #{e.message}"
    render json: { message: 'Sign in failed', errors: [e.message] }, status: :internal_server_error
  end

  protected

  # Ensure no session is created
  def verify_signed_out_user; end

  def sign_in_params
    params.require(:user).permit(:email, :password)
  end

  def auth_options
    { scope: resource_name, recall: "#{controller_path}#new" }
  end

  def respond_to_on_destroy
    head :no_content
  end
    # POST /resource/sign_in
    # def create
    #   super
    # end

    # DELETE /resource/sign_out
    # def destroy
    #   super
    # end

    # protected

    # If you have extra params to permit, append them to the sanitizer.
    # def configure_sign_in_params
    #   devise_parameter_sanitizer.permit(:sign_in, keys: [:attribute])
    # end
  end
end
