module RememberDeviceConcern
  extend ActiveSupport::Concern

  def save_remember_device_preference
    return unless params[:remember_device] == 'true'
    cookies.encrypted[:remember_device] = {
      value: RememberDeviceCookie.new(user_id: current_user.id, created_at: Time.zone.now).to_json,
      expires: remember_device_cookie_expiration,
    }
  end

  def check_remember_device_preference
    return unless authentication_context?
    return if remember_device_cookie.nil?
    return unless remember_device_cookie.valid_for_user?(
      user: current_user,
      expiration_interval: decorated_session.mfa_expiration_interval,
    )

    handle_valid_remember_device_cookie
  end

  def remember_device_cookie
    remember_device_cookie_contents = cookies.encrypted[:remember_device]
    return if remember_device_cookie_contents.blank?
    @remember_device_cookie ||= RememberDeviceCookie.from_json(
      remember_device_cookie_contents,
    )
  end

  def remember_device_expired_for_sp?
    return false unless user_session[:mfa_device_remembered]
    return true if remember_device_cookie.nil?

    !remember_device_cookie.valid_for_user?(
      user: current_user,
      expiration_interval: decorated_session.mfa_expiration_interval,
    )
  end

  private

  def handle_valid_remember_device_cookie
    user_session[:mfa_device_remembered] = true
    mark_user_session_authenticated
    bypass_sign_in current_user
    redirect_to after_otp_verification_confirmation_url
    reset_otp_session_data
  end

  def remember_device_cookie_expiration
    Figaro.env.remember_device_expiration_hours_aal_1.to_i.hours.from_now
  end
end
