# frozen_string_literal: true

module Users
  class RegistrationsController < Devise::RegistrationsController
    respond_to :json

    # Override the create method
    def new
      source(sign_up_params)

      resource.save
      yield resource if block_given?
      if resource.persisted?
        if resource.active_for_authentication?
          token = Warden::JWTAuth::UserEncoder.new.call(resource, :user, nil).first
          render json: { message: 'Signed up successfully.', user: resource, token: }, status: :ok
        else
          expire_data_after_sign_in!
          render json: { message: 'Signed up successfully, but inactive.', user: resource }, status: :ok
        end
      else
        clean_up_passwords(resource)
        set_minimum_password_length
        render json: { message: 'Registration failed', errors: resource.errors.full_messages },
               status: :unprocessable_entity
      end
    rescue StandardError => e
      Rails.logger.error "Error during sign up: #{e.message}"
      render json: { message: 'Registration failed', errors: [e.message] }, status: :unprocessable_entity
    end

    private

    def respond_with(resource, _opts = {})
      if resource.persisted?
        register_success
      else
        register_failed(resource)
      end
    end

    def register_success
      render json: { message: 'Signed up successfully.' }
    end

    def register_failed(resource)
      render json: { message: 'Registration failed', errors: resource.errors.full_messages },
             status: :unprocessable_entity
    end

    def sign_up_params
      params.require(:user).permit(:email, :password, :password_confirmation)
    end

    # before_action :configure_sign_up_params, only: [:create]
    # before_action :configure_account_update_params, only: [:update]

    # GET /resource/sign_up
    # def new
    #   super
    # end

    # POST /resource
    # def create
    #   super
    # end

    # GET /resource/edit
    # def edit
    #   super
    # end

    # PUT /resource
    # def update
    #   super
    # end

    # DELETE /resource
    # def destroy
    #   super
    # end

    # GET /resource/cancel
    # Forces the session data which is usually expired after sign
    # in to be expired now. This is useful if the user wants to
    # cancel oauth signing in/up in the middle of the process,
    # removing all OAuth session data.
    # def cancel
    #   super
    # end

    # protected

    # If you have extra params to permit, append them to the sanitizer.
    # def configure_sign_up_params
    #   devise_parameter_sanitizer.permit(:sign_up, keys: [:attribute])
    # end

    # If you have extra params to permit, append them to the sanitizer.
    # def configure_account_update_params
    #   devise_parameter_sanitizer.permit(:account_update, keys: [:attribute])
    # end

    # The path used after sign up.
    # def after_sign_up_path_for(resource)
    #   super(resource)
    # end

    # The path used after sign up for inactive accounts.
    # def after_inactive_sign_up_path_for(resource)
    #   super(resource)
    # end
  end
end
