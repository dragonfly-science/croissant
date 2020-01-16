require "rails_helper"

describe TagHelper, type: :helper do
  describe "#submission_text_with_tags" do
    let(:text) { "ABC\nDEF\nGHI\nJKL" }
    let(:tag1) do
      instance_double("SubmissionTag",
                      start_char: 0,
                      end_char: 5,
                      text: "ABC\nDE",
                      colour_number: 0,
                      name: "Tag 1")
    end
    let(:tag2) do
      instance_double("SubmissionTag",
                      start_char: 6,
                      end_char: 10,
                      text: "F\nGHI",
                      colour_number: 1,
                      name: "Tag 2")
    end
    subject { submission_text_with_tags(text, [tag1, tag2]) }

    it "puts a span in the appropriate places the tags" do
      expect(subject).to include(">ABC\nDE</span>")
      expect(subject).to include(">F\nGHI</span>\nJKL")
    end
    it "includes data about the tags" do
      expect(subject).to include("tagged--colour-0")
      expect(subject).to include("tagged--colour-1")
      expect(subject).to include("Tag 1")
      expect(subject).to include("Tag 2")
    end
  end
end
