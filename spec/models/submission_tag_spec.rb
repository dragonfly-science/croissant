require "rails_helper"

RSpec.describe SubmissionTag, type: :model do
  let(:consultation) { FactoryBot.create(:consultation) }
  let(:submission) { FactoryBot.create(:submission, :ready_to_tag, consultation: consultation, text: text) }
  let(:tag) { FactoryBot.create(:tag, taxonomy: consultation.taxonomy) }
  let(:text) { "My favourite animals:\n- dogs\n- cats\n- pandas" }
  let(:survey_answer) do
    FactoryBot.create(:survey_answer, answer: "My favourite animals: dogs", submission: submission)
  end

  context "when creating a new submission tag" do
    it "removes forced carriage returns from the text" do
      st = SubmissionTag.create(taggable: submission, tag: tag, text: "animals:\r\n-dogs")
      expect(st.text).to eq("animals:\n-dogs")
    end
    it "updates the position if not given" do
      st = SubmissionTag.create(taggable: submission, tag: tag, text: "cats")
      expect(st.start_char).to eq(text.index("cats"))
      expect(st.end_char).to eq(text.index("cats") + 3)
    end
    it "updates the position if given invalid position" do
      st = SubmissionTag.create(taggable: submission, tag: tag, start_char: -1, end_char: 5, text: "cats")
      expect(st.start_char).to eq(text.index("cats"))
      expect(st.end_char).to eq(text.index("cats") + 3)
    end
    it "tags the submission" do
      SubmissionTag.create(taggable: submission, tag: tag, text: "cats")
      expect(submission.state).to eq("started")
    end

    context "when the taggable object is a survey answer" do
      it "tags the survey answer" do
        SubmissionTag.create(taggable: survey_answer, tag: tag, text: "dogs")
        expect(survey_answer.submission_tags.count).to eq(1)
      end
    end
  end

  let(:dissonant_tag) do
    SubmissionTag.create(taggable: submission, tag: tag, text: "animals", start_char: 0, end_char: 4)
  end

  let(:text_absent_tag) do
    SubmissionTag.create(taggable: submission, tag: tag, text: "cows", start_char: 0, end_char: 4)
  end

  let(:concordant_tag) do
    start_char = text.index("animals")
    end_char = start_char + "animals".length - 1
    SubmissionTag.create(taggable: submission, tag: tag, text: "animals", start_char: start_char, end_char: end_char)
  end

  let(:submission_tag) do
    SubmissionTag.create(taggable: submission, tag: tag, text: "cats")
  end

  let(:survey_answer_tag) do
    SubmissionTag.create(taggable: survey_answer, tag: tag, text: "dogs")
  end

  describe "calculated position" do
    it "calculates the tag text's position in the submission text from its start and end character" do
      start_char = text.index("animals")
      end_char = start_char + "animals".length - 1
      expect(dissonant_tag.calculated_position).to eq([start_char, end_char])
    end
    it "returns nil if the tag text is not within the submission text" do
      expect(text_absent_tag.calculated_position).to eq(nil)
    end
  end

  describe "calculated text" do
    it "calculates the tag text from the start and end character" do
      expect(dissonant_tag.calculated_text).to eq(submission.text[0..4])
    end
  end

  describe "dissonant?" do
    it "returns true if the tag text is the same as the calculated text" do
      expect(dissonant_tag.dissonant?).to eq(true)
      expect(text_absent_tag.dissonant?).to eq(true)
    end
    it "returns false if the tag text is not the same as the calculated text" do
      expect(concordant_tag.dissonant?).to eq(false)
    end
  end

  describe "survey_question_token" do
    context "when the taggable type is Submission" do
      it "returns nil" do
        expect(submission_tag.survey_question_token).to eq(nil)
      end
    end

    context "when the taggable type is SurveyAnswer" do
      it "returns the survey answer token" do
        expect(survey_answer_tag.survey_question_token).to eq(survey_answer.survey_question.token)
      end
    end
  end
end
