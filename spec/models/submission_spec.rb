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
  context "for a txt upload" do
    let(:file) { Rack::Test::UploadedFile.new("spec/support/example_files/short.txt", "text/plain") }
    it "adds the text with the right encoding" do
      submission = FactoryBot.create(:submission, file: file)
      submission.file.analyze
      expect(submission.raw_text).to include("kākāpō")
    end
  end
  context "for a docx upload" do
    let(:file) do
      Rack::Test::UploadedFile.new("spec/support/example_files/single-page.docx",
                                   "application/vnd.openxmlformats-officedocument.wordprocessingml.document")
    end
    it "adds the text with the right encoding" do
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
  context "state changes" do
    let(:consultation) { FactoryBot.create(:consultation, name: "With a Space") }
    let(:taxonomy) { consultation.taxonomy }
    let!(:tag) { FactoryBot.create(:tag, taxonomy: taxonomy, name: "Bears") }

    it "creates submissions in the incoming state" do
      submission = FactoryBot.create(:submission, text: "something")
      expect(submission.state).to eq("incoming")
    end
    it "does not allow a submission with no text to be processed" do
      submission = FactoryBot.create(:submission, text: nil)
      expect(submission.can_process?).to eq(false)
    end
    it "does allows a submission with text to be processed" do
      submission = FactoryBot.create(:submission, text: "something")
      expect(submission.can_process?).to eq(true)
      submission.process
      expect(submission.state).to eq("ready")
    end
    it "does not allow a submission that is not ready to be tagged" do
      submission = FactoryBot.create(:submission, text: "something")
      expect(submission.can_tag?).to eq(false)
    end
    it "allows a submission that is ready to be tagged" do
      submission = FactoryBot.create(:submission, text: "something")
      submission.process
      expect(submission.can_tag?).to eq(true)
    end
    it "allows a submission that has been started to be tagged" do
      submission = FactoryBot.create(:submission, text: "something")
      submission.process
      submission.tag
      expect(submission.state).to eq("started")
      expect(submission.can_tag?).to eq(true)
    end
    it "allows a submission that has been tagged to be marked as complete" do
      submission = FactoryBot.create(:submission, text: "something", consultation: consultation)
      submission.process
      submission.tag
      submission.add_tag(tag: tag, start_char: 0, end_char: 2, text: "som")
      expect(submission.can_complete_tagging?).to eq(true)
    end
    it "allows a submission that has been completed to be rejected" do
      submission = FactoryBot.create(:submission, text: "something", consultation: consultation)
      submission.process
      submission.tag
      submission.add_tag(tag: tag, start_char: 0, end_char: 2, text: "som")
      submission.complete_tagging
      expect(submission.can_reject?).to eq(true)
    end
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
  describe "scopes" do
    it "allows searching by filename" do
      file = Rack::Test::UploadedFile.new("spec/support/example_files/single-page.pdf",
                                          "application/pdf")
      submission = FactoryBot.create(:submission, file: file)
      expect(Submission.search_by_filename("single-page")).to eq([submission])
    end
  end
  describe "navigation" do
    let!(:consultation) { FactoryBot.create(:consultation, :with_taxonomy_tags) }
    let!(:submissions) do
      FactoryBot.create_list(:submission, 25, :ready_to_tag, consultation: consultation,
                                                             text: "cows dogs and sheep in the ocean riding waves")
    end
    let!(:other_consultation) { FactoryBot.create(:consultation, :with_taxonomy_tags) }
    let!(:other_submissions) do
      FactoryBot.create_list(:submission, 25, :ready_to_tag, consultation: other_consultation,
                                                             text: "other submission")
    end
    describe "first" do
      it "returns the first record for the consulation" do
        second_record = consultation.submissions.second
        expect(second_record.first).to eq(consultation.submissions.first)
      end
      it "doesn't return a record from another consultation" do
        expect(other_consultation.submissions.first).not_to eq(consultation.submissions.first)
      end
    end
    describe "prev" do
      it "returns the previous record for the consulation" do
        first_record = consultation.submissions.first
        second_record = consultation.submissions.second
        expect(second_record.prev).to eq(first_record)
      end
      it "doesn't go back beyond the first one" do
        first_record = consultation.submissions.first
        expect(first_record.prev).to eq(nil)
      end
      it "doesn't return a record from another consultation" do
        second_record = consultation.submissions.second
        other_second_record = other_consultation.submissions.second
        expect(second_record.prev).not_to eq(other_second_record.prev)
      end
    end
    describe "next" do
      it "returns the next record for the consulation" do
        first_record = consultation.submissions.first
        second_record = consultation.submissions.second
        expect(first_record.next).to eq(second_record)
      end
      it "doesn't go beyond the last one" do
        first_record = consultation.submissions.last
        expect(first_record.next).to eq(nil)
      end
      it "doesn't return a record from another consultation" do
        second_record = consultation.submissions.second
        other_second_record = other_consultation.submissions.second
        expect(second_record.next).not_to eq(other_second_record.next)
      end
    end
    describe "last" do
      it "returns the last record for the consulation" do
        record = consultation.submissions.second
        expect(record.last).to eq(consultation.submissions.last)
      end
      it "doesn't return a record from another consultation" do
        expect(other_consultation.submissions.last).not_to eq(consultation.submissions.last)
      end
    end
  end
end
