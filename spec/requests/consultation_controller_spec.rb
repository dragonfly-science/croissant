require "rails_helper"

RSpec.describe ConsultationsController, type: :request do
  let(:consultation) { FactoryBot.create(:consultation) }
  let(:user) { FactoryBot.create(:user) }
  before do
    sign_in(user)
  end

  describe "#index" do
    subject { get consultations_path }

    it "responds with an ok status" do
      subject
      expect(response).to have_http_status(:ok)
    end

    it "assigns and instance variable with all consultations ordered alphabetically" do
      consultation2 = FactoryBot.create(:consultation, name: "Be a banana")
      consultation1 = FactoryBot.create(:consultation, name: "A hotdog")
      consultation3 = FactoryBot.create(:consultation, name: "The only apple")

      subject
      expect(assigns(:consultations).to_a).to eq([consultation1, consultation2, consultation3])
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

  describe "#export" do
    it "downloads a tag csv" do
      get consultation_export_path(consultation, format: :csv, type: "tags")
      expect(response.header["Content-Type"]).to include "text/csv"
    end
    it "downloads a submission csv" do
      get consultation_export_path(consultation, format: :csv, type: "submissions")
      expect(response.header["Content-Type"]).to include "text/csv"
    end
    it "downloads a taxonomy csv" do
      get consultation_export_path(consultation, format: :csv, type: "taxonomy")
      expect(response.header["Content-Type"]).to include "text/csv"
    end
    it "doesn't respond to html" do
      expect do
        get consultation_export_path(consultation, format: :html, type: "taxonomy")
      end.to raise_error(ActionController::UnknownFormat)
    end
    it "doesn't respond if not given a type" do
      expect { get consultation_export_path(consultation, format: :csv) }.to raise_error(ActionController::BadRequest)
    end
  end
end
