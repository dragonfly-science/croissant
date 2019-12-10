require "rails_helper"

RSpec.describe ConsultationsController, type: :request do
  let(:consultation) { FactoryBot.create(:consultation) }

  describe "#index" do
    before { get consultations_path }

    it "responds with an ok status" do
      expect(response).to have_http_status(:ok)
    end

    it "assigns and instance variable with all consultations ordered alphabetically" do
      ordered_consultations = Consultation.order("name ASC")
      expect(assigns(:consultations)).to eq(ordered_consultations)
    end
  end

  describe "#new" do
    before { get new_consultation_path }

    it "responds with an ok status" do
      expect(response).to have_http_status(:ok)
    end

    it "assigns a new instance of the consultation model" do
      expect(assigns(:consultation)).to be_a_kind_of(Consultation)
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

      it "assigns a new instance of the consultation model with the provided params" do
        subject
        expect(assigns(:consultation)).to be_a_kind_of(Consultation)
        expect(assigns(:consultation).name).to eq(params[:consultation][:name])
      end
    end
  end

  describe "#show" do
    before { get consultation_path(consultation) }

    it "responds with an ok status" do
      expect(response).to have_http_status(:ok)
    end

    it "assigns the correct consultation" do
      expect(assigns(:consultation)).to eq(consultation)
    end
  end
end
