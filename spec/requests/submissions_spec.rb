require "rails_helper"

RSpec.describe "Submissions", type: :request do
  let(:user) { FactoryBot.create(:user, role: "superadmin") }
  let!(:consultation) { FactoryBot.create(:consultation) }
  let!(:submission) { FactoryBot.create(:submission, :ready_to_tag) }

  before do
    sign_in(user)
  end

  describe "#index" do
    before do
      FactoryBot.create_list(:submission, 3, consultation: consultation)
      get consultation_submissions_path(consultation)
    end

    it "responds with an ok status" do
      subject
      expect(response).to have_http_status(:ok)
    end

    it "assigns a list of submissions for the current consultation" do
      subject
      expect(assigns(:submissions).to_a).to eq(consultation.submissions)
    end
  end

  describe "#show" do
    before do
      get submission_path(submission)
    end

    it "responds with an ok status" do
      expect(response).to have_http_status(:ok)
    end

    it "assigns a single submission" do
      expect(assigns(:submission)).to eq(submission)
    end
  end

  xdescribe "#create" do
    let(:params) do
      { submission: {
        file: [Rack::Test::UploadedFile.new("spec/support/example_files/00988_Anonymous.pdf",
                                            "application/pdf")] } }
    end
    subject { post consultation_submissions_path(consultation, params) }

    it "responds with an redirect status" do
      subject
      expect(response).to have_http_status(:redirect)
    end

    it "creates a new instance of the submission model" do
    end

    it "redirects to the list of submissions for the current consultation" do
    end
  end

  describe "#destroy" do
    let(:consultation_submission) { FactoryBot.create(:submission, consultation: consultation) }
    subject { delete consultation_submission_path(consultation, consultation_submission) }

    it "responds with an redirect status" do
      subject
      expect(response).to have_http_status(:redirect)
    end

    it "destroys the submission provided" do
      expect(consultation.submissions).to include(consultation_submission)
      subject
      expect(consultation.reload.submissions).not_to include(consultation_submission)
    end
  end

  describe "#tag" do
    let!(:tags) { FactoryBot.create_list(:submission_tag, 3, submission: submission) }

    before do
      get consultation_submission_tag_path(submission.consultation, submission)
    end

    it "responds with an ok status" do
      expect(response).to have_http_status(:ok)
    end

    it "assigns a list of existing submission tags for the current submission" do
      expect(assigns(:submission_tags).to_a).to eq(tags)
    end
  end

  describe "#edit" do
    before do
      get edit_submission_path(submission)
    end

    it "responds with an ok status" do
      expect(response).to have_http_status(:ok)
    end

    it "assigns an instance of the submission model" do
      expect(assigns(:submission)).to eq(submission)
    end
  end

  describe "#update" do
    let(:params) { { submission: { text: "new submission text" } } }

    before do
      put submission_path(submission, params)
    end

    it "responds with an redirect status" do
      expect(response).to have_http_status(:redirect)
    end

    it "updates the submission" do
      expect(submission.reload.text).to eq("new submission text")
    end
  end

  describe "#mark_process" do
    before do
      submission.update!(state: "incoming")
      put process_submission_path(submission)
    end

    it "responds with an redirect status" do
      expect(response).to have_http_status(:redirect)
    end

    it "changes the submission state to ready" do
      expect(submission.reload.state).to eq("ready")
    end
  end

  describe "#mark_complete" do
    before do
      submission.update!(state: "started")
      put complete_submission_path(submission)
    end

    it "responds with an redirect status" do
      expect(response).to have_http_status(:redirect)
    end

    it "changes the submission state to finished" do
      expect(submission.reload.state).to eq("finished")
    end
  end

  describe "#mark_reject" do
    before do
      submission.update!(state: "finished")
      put reject_submission_path(submission)
    end

    it "responds with an redirect status" do
      expect(response).to have_http_status(:redirect)
    end

    it "changes the submission state to started" do
      expect(submission.reload.state).to eq("started")
    end
  end

  describe "#mark_archived" do
    before do
      submission.update!(state: "started")
      put archive_submission_path(submission)
    end

    it "responds with an redirect status" do
      expect(response).to have_http_status(:redirect)
    end

    it "changes the submission state to archived" do
      expect(submission.reload.state).to eq("archived")
    end
  end

  describe "#mark_restored" do
    before do
      submission.update!(state: "archived")
      put restore_submission_path(submission)
    end

    it "responds with an redirect status" do
      expect(response).to have_http_status(:redirect)
    end

    it "changes the submission state to started" do
      expect(submission.reload.state).to eq("started")
    end
  end
end
