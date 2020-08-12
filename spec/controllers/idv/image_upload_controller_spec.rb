require 'rails_helper'

describe Idv::ImageUploadController do
  describe '#create' do
    let(:content_type) { 'application/json' }
    let(:upload_errors) { [] }
    before do
      sign_in_as_user
      request.content_type = content_type
      response_mock = instance_double(Acuant::Responses::ResponseWithPii,
                                      success?: upload_errors.empty?,
                                      errors: upload_errors,
                                      to_h: {
                                        success: upload_errors.empty?,
                                        errors: upload_errors,
                                      },
                                      pii_from_doc: {})
      client_mock = instance_double(Acuant::AcuantClient, post_images: response_mock)
      allow(subject).to receive(:client).and_return client_mock
      subject.user_session['idv/doc_auth'] = {} unless subject.user_session['idv/doc_auth']
    end
    context 'with an invalid content type' do
      let(:content_type) { 'text/plain' }
      it 'supplies an error status' do
        post :create, params: {}
        response_json = JSON.parse(response.body)
        expect(response_json['status']).to eq('error')
        expect(response_json['message']).to eq("Invalid content type #{request.content_type}")
      end
    end
    it 'returns error status when not provided image fields' do
      post :create, params: {
        not: 'right',
        back: 'back_image',
      }, format: :json
      response_json = JSON.parse(response.body)
      expect(response_json['status']).to eq('error')
      expect(response_json['message']).to eq('Missing image keys')
    end

    context 'when image upload succeeds' do
      it 'returns a successful response and modifies the session' do
        post :create, params: {
          front: 'front_image',
          back: 'back_image',
          selfie: 'selfie_image',
        }, format: :json
        response_json = JSON.parse(response.body)
        expect(response_json['status']).to eq('success')
        expect(response_json['message']).to eq('Uploaded images')
        expect(subject.user_session['idv/doc_auth']).to include('api_upload')
      end
    end
    context 'when image upload fails' do
      let(:upload_errors) { ['Too blurry', 'Wrong document'] }
      it 'returns an error response and does not modify the session' do
        post :create, params: {
          front: 'front_image',
          back: 'back_image',
          selfie: 'selfie_image',
        }, format: :json
        response_json = JSON.parse(response.body)
        expect(response_json['status']).to eq('error')
        expect(response_json['message']).to eq('Too blurry')
        expect(subject.user_session['idv/doc_auth']).not_to include('api_upload')
      end
    end
  end
end