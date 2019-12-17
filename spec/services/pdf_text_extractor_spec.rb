require "rails_helper"

RSpec.describe PdfTextExtractor do
  context "for a single page file" do
    let(:file) { file_fixture("single-page.pdf") }
    it "extracts the text" do
      text = PdfTextExtractor.call(file)
      expect(text).to eq("Text on page 1")
    end
  end

  context "for a multi page file" do
    let(:file) { file_fixture("multi-page.pdf") }
    it "extracts the text" do
      text = PdfTextExtractor.call(file)
      expect(text).to eq("Text on page 1\nText on page 2")
    end
  end
end
