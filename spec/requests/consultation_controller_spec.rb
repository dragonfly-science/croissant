require "rails_helper"

RSpec.describe ConsultationsController, type: :request do
  let(:consultation) { FactoryBot.create(:consultation) }

  describe "#index" do
    before { get consultations_path }

    it "responds with an ok status" do
      expect(response).to have_http_status(:ok)
    end
  end

  describe "#new" do
    before { get new_consultation_path }

    it "responds with an ok status" do
      expect(response).to have_http_status(:ok)
    end
  end

  describe "#create" do
    subject { post consultations_path(params) }

    context "with a valid set of params" do
      let(:params) do
        { consultation: {
          name: "Test Consultation",
          consultation_type: "parliamentary" }
        }
      end

      it "responds with a redirect status" do
        subject
        expect(response).to have_http_status(:redirect)
      end
    end
  end

  describe "#show" do
    it "responds with an ok status" do
      get consultation_path(consultation)
      expect(response).to have_http_status(:ok)
    end
  end
end
