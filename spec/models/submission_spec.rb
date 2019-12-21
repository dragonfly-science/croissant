require "rails_helper"

RSpec.describe Submission, type: :model do
  let(:file) { Rack::Test::UploadedFile.new("spec/support/example_files/single-page.pdf", "application/pdf") }
  context "after analyzing" do
    it "converts the PDF to text" do
      submission = FactoryBot.create(:submission, file: file)
      submission.file.analyze
      expect(submission.raw_text).to eq("Text on page 1")
    end
  end
  it "only allows processing if there is text" do
    submission = FactoryBot.create(:submission, file: file)
    expect(submission.can_process?).to eq(false)
    submission.update(text: "something")
    expect(submission.can_process?).to eq(true)
  end
end
