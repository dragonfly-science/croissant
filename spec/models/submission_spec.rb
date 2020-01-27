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
  it "removes forced carriage returns on save" do
    carriage_returny_text = "Your submission to Zero Carbon Bill\r\n\r\nAnonymous\r\n\r\n\r\n\r\n\r\nReference no: 15"
    submission = FactoryBot.create(:submission, file: file)
    submission.text = carriage_returny_text
    submission.save
    expect(submission.text).to eq(carriage_returny_text.gsub(/\r\n/, "\n"))
  end
  describe "file upload" do
    it "allows PDFs" do
      file = Rack::Test::UploadedFile.new("spec/support/example_files/single-page.pdf",
                                          "application/pdf")
      submission = FactoryBot.create(:submission, file: file)
      expect(submission.valid?).to eq(true)
    end
    it "allows .doc files" do
      file = Rack::Test::UploadedFile.new("spec/support/example_files/single-page.doc",
                                          "application/msword")
      submission = FactoryBot.create(:submission, file: file)
      expect(submission.valid?).to eq(true)
    end
    it "allows the long mimetype of .docx files" do
      file = Rack::Test::UploadedFile.new("spec/support/example_files/single-page.docx",
                                          "application/vnd.openxmlformats-officedocument.wordprocessingml.document")
      submission = FactoryBot.create(:submission, file: file)
      expect(submission.valid?).to eq(true)
    end
  end
end
