require "rails_helper"
RSpec.describe SubmissionCsvUpload do
  let(:consultation) { FactoryBot.create(:consultation) }
  let(:filename) { "submission_upload.csv" }
  let(:filetype) { "text/csv" }
  let(:file) { Rack::Test::UploadedFile.new("spec/support/example_files/#{filename}", filetype) }
  subject { SubmissionCsvUpload.new(file, consultation) }

  it "is valid" do
    expect(subject.valid?).to eq(true)
  end

  it "returns an empty list of validity errors" do
    expect(subject.validity_errors).to eq([])
  end

  it "creates submissions within the consultation" do
    subject.import!
    expect(consultation.submissions.count).to eq(4)
  end

  it "creates submissions with multiple lines of text" do
    subject.import!
    expect(consultation.submissions.first.text).to eq("ABCDEF")
  end

  it "saves the metadata from the first row of multi-part submissions" do
    subject.import!
    expect(consultation.submissions.first.description).to eq("Two-part submission")
  end
end
