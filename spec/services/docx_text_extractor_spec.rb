require "rails_helper"

RSpec.describe DocxTextExtractor do
  context "for a single page file" do
    let(:file) do
      Rack::Test::UploadedFile.new("spec/support/example_files/single-page.docx",
                                   "application/vnd.openxmlformats-officedocument.wordprocessingml.document")
    end
    it "extracts the text" do
      text = DocxTextExtractor.call(file)
      expect(text).to eq("Text on page 1")
    end
  end

  context "for a multi page file" do
    let(:file) do
      Rack::Test::UploadedFile.new("spec/support/example_files/multi-page.docx",
                                   "application/vnd.openxmlformats-officedocument.wordprocessingml.document")
    end
    it "extracts the text" do
      text = DocxTextExtractor.call(file)
      expect(text).to eq("Text on page 1\nText on page 2")
    end
  end
end
