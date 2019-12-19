require "rails_helper"

RSpec.describe SubmissionCreator do
  let(:consultation) { FactoryBot.create(:consultation) }
  let(:submission_params) { { consultation: consultation, description: "Description" } }
  let(:good_file) { uploaded_file("00988_Anonymous.pdf", "application/pdf") }
  let(:another_good_file) { uploaded_file("multi-page.pdf", "application/pdf") }
  let(:good_docx) do
    uploaded_file("single-page.docx",
                  "application/vnd.openxmlformats-officedocument.wordprocessingml.document")
  end
  let(:bad_file) { uploaded_file("croissant-logo.png", "image/png") }

  context "for a single file" do
    it "creates a single submission" do
      creator = SubmissionCreator.new(file_upload_params: [good_file],
                                      create_submission_params: submission_params)
      expect { creator.create! }.to change { Submission.count }.by(1)
    end
    it "gives an error message if the upload was unsuccessful" do
      creator = SubmissionCreator.new(file_upload_params: [bad_file],
                                      create_submission_params: submission_params)
      expect { creator.create! }.to change { Submission.count }.by(0)
      expect(creator.notice).to include("croissant-logo.png")
    end
  end

  context "for multiple files" do
    context "when all are successful" do
      let(:three_good_files) { [good_file, another_good_file, good_docx] }
      let(:creator) do
        SubmissionCreator.new(file_upload_params: three_good_files,
                              create_submission_params: submission_params)
      end

      it "creates multiple submissions" do
        expect { creator.create! }.to change { Submission.count }.by(3)
      end
      it "gives each submission the same metadata" do
        creator.create!

        creator.successful.each do |submission|
          expect(submission.description).to eq("Description")
        end
      end
    end

    context "when some are unsuccessful" do
      let(:mixed_files) { [good_file, another_good_file, bad_file] }
      let(:creator) do
        SubmissionCreator.new(file_upload_params: mixed_files,
                              create_submission_params: submission_params)
      end
      it "creates submissions for the files that are successful" do
        expect { creator.create! }.to change { Submission.count }.by(2)
      end
      it "has an error message for the files that are unsuccessful" do
        creator.create!
        expect(creator.notice).to include("croissant-logo.png")
      end
    end
  end

  def uploaded_file(name, type)
    Rack::Test::UploadedFile.new("spec/support/example_files/#{name}", type)
  end
end
