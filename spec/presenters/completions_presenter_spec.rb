require 'rails_helper'

describe CompletionsPresenter do
  let(:identities) do
    [
      build(
        :service_provider_identity,
        service_provider: current_sp.issuer,
        last_consented_at: nil,
      ),
    ]
  end
  let(:current_user) { create(:user, :signed_up, identities: identities) }
  let(:current_sp) { create(:service_provider, friendly_name: 'Friendly service provider') }
  let(:decrypted_pii) do
    {
      # TODO
    }
  end
  let(:requested_attributes) { ['todo'] }
  let(:ial2_requested) { false }
  let(:completion_context) { :new_sp }

  subject(:presenter) do
    described_class.new(
      current_user: current_user,
      current_sp: current_sp,
      decrypted_pii: decrypted_pii,
      requested_attributes: requested_attributes,
      ial2_requested: ial2_requested,
      completion_context: completion_context,
    )
  end

  describe '#heading' do
    context 'ial2 sign in' do
      let(:ial2_requested) { true }

      it 'renders the ial2 message' do
        expect(presenter.heading).to eq(I18n.t('titles.sign_up.completion_ial2'))
      end
    end

    context 'first time the user signs into any SP' do
      it 'renders the first time sign in message' do
        expect(presenter.heading).to eq(
          I18n.t('titles.sign_up.completion_first_sign_in', app_name: APP_NAME),
        )
      end
    end

    context 'consent has expired since the last sign in' do
      let(:identities) do
        [
          build(
            :service_provider_identity,
            service_provider: current_sp.issuer,
            last_consented_at: 2.years.ago,
          ),
        ]
      end
      let(:completion_context) { :consent_expired }

      it 'renders the expired consent message' do
        expect(presenter.heading).to eq(
          I18n.t('titles.sign_up.completion_consent_expired'),
        )
      end
    end

    context 'the sp has requested new attributes' do
      let(:identities) do
        [
          build(
            :service_provider_identity,
            service_provider: current_sp.issuer,
            last_consented_at: 1.day.ago,
          ),
        ]
      end
      let(:completion_context) { :new_attributes }

      it 'renders the new attributes message' do
        expect(presenter.heading).to eq(
          I18n.t('titles.sign_up.completion_new_attributes', sp: current_sp.friendly_name),
        )
      end
    end

    context 'the user is signing into an SP for the first time' do
      let(:identities) do
        [
          build(
            :service_provider_identity,
            service_provider: create(:service_provider).issuer,
            last_consented_at: 1.day.ago,
          ),
          build(
            :service_provider_identity,
            service_provider: current_sp.issuer,
            last_consented_at: nil,
          ),
        ]
      end
      let(:completion_context) { :new_sp }

      it 'renders the new sp message' do
        expect(presenter.heading).to eq(I18n.t('titles.sign_up.completion_new_sp'))
      end
    end
  end

  describe '#image_name' do
    context 'ial2 sign in' do
      let(:ial2_requested) { true }

      it 'renders the ial2 image' do
        expect(presenter.image_name).to eq('user-signup-ial2.svg')
      end
    end

    context 'ial1 sign in' do
      let(:ial2_requested) { false }

      it 'renders the ial1 image' do
        expect(presenter.image_name).to eq('user-signup-ial1.svg')
      end
    end
  end

  describe '#pii' do
    # TODO
  end
end
