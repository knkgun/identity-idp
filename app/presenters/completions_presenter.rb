class CompletionsPresenter
  attr_reader :current_user, :current_sp, :decrypted_pii, :requested_attributes, :completion_context

  def initialize(
    current_user:,
    current_sp:,
    decrypted_pii:,
    requested_attributes:,
    ial2_requested:,
    completion_context:
  )
    @current_user = current_user
    @current_sp = current_sp
    @decrypted_pii = decrypted_pii
    @requested_attributes = requested_attributes
    @ial2_requested = ial2_requested
    @completion_context = completion_context
  end

  def ial2_requested?
    @ial2_requested
  end

  def heading
    if ial2_requested?
      I18n.t('titles.sign_up.completion_ial2')
    elsif first_time_signing_in?
      I18n.t('titles.sign_up.completion_first_sign_in', app_name: APP_NAME)
    elsif completion_context == :consent_expired
      I18n.t('titles.sign_up.completion_consent_expired')
    elsif completion_context == :new_attributes
      sp_name = current_sp.friendly_name || sp.agency&.name
      I18n.t('titles.sign_up.completion_new_attributes', sp: sp_name)
    else
      I18n.t('titles.sign_up.completion_new_sp')
    end
  end

  def image_name
    if ial2_requested?
      'user-signup-ial2.svg'
    else
      'user-signup-ial1.svg'
    end
  end

  def pii
    # TODO
  end

  private

  def first_time_signing_in?
    current_user.identities.where.not(last_consented_at: nil).empty?
  end
end
