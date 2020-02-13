require "rails_helper"
# rubocop:disable Metrics/LineLength
RSpec.describe SubmissionTagMarkupService do
  let(:consultation) { FactoryBot.create(:consultation) }
  let(:taxonomy) { consultation.taxonomy }
  let(:submission_text) { "I love cats and dogs, but my favourite animal is red pandas." }
  let(:submission) { FactoryBot.create(:submission, :ready_to_tag, consultation: consultation, text: submission_text) }

  let(:animal_tag) { FactoryBot.create(:tag, taxonomy: taxonomy, name: "animals") }
  let(:cat_tag) { FactoryBot.create(:tag, taxonomy: taxonomy, parent: animal_tag, name: "cats") }
  let(:dog_tag) { FactoryBot.create(:tag, taxonomy: taxonomy, parent: animal_tag, name: "dogs") }
  let(:panda_tag) { FactoryBot.create(:tag, taxonomy: taxonomy, parent: animal_tag, name: "pandas") }
  let(:red_panda_tag) { FactoryBot.create(:tag, taxonomy: taxonomy, parent: panda_tag, name: "red pandas") }

  subject { SubmissionTagMarkupService.new(submission) }

  def tag_for_text(text, tag)
    start_char = submission_text.index(text)
    end_char = start_char + text.length - 1
    { tag: tag, text: text, start_char: start_char, end_char: end_char }
  end

  def milestone_for_st(tag, type)
    "<hr class=\"js-tag-milestone\" data-type=\"tag-#{type}\" data-id=\"#{tag.id}\" data-colour=\"#{tag.tag.colour_number}\" data-tag-id=\"#{tag.tag.id}\" />"
  end

  context "for a submission with no tags" do
    it "marks up the text only" do
      expect(subject.markup).to eq(submission_text)
    end
  end

  context "for a submission with no overlapping tags" do
    it "marks up the text with xml markup of the tags" do
      tag_1 = submission.add_tag(tag_for_text("cats", cat_tag))
      tag_2 = submission.add_tag(tag_for_text("my favourite animal is red pandas", red_panda_tag))
      expect(subject.markup).to eq(
        "I love #{milestone_for_st(tag_1, "start")}cats#{milestone_for_st(tag_1, "end")} and dogs, but #{milestone_for_st(tag_2, "start")}my favourite animal is red pandas#{milestone_for_st(tag_2, "end")}."
      )
    end
    it "marks up the text correctly when the same tag is used more than once" do
      tag_1 = submission.add_tag(tag_for_text("I love cats and dogs", animal_tag))
      tag_2 = submission.add_tag(tag_for_text("my favourite animal is red pandas", animal_tag))
      expect(subject.markup).to eq(
        "#{milestone_for_st(tag_1, "start")}I love cats and dogs#{milestone_for_st(tag_1, "end")}, but #{milestone_for_st(tag_2, "start")}my favourite animal is red pandas#{milestone_for_st(tag_2, "end")}."
      )
    end
  end

  context "for a submission with tags fully contained within other tags" do
    it "marks up the text with xml markup of the tags" do
      tag_1 = submission.add_tag(tag_for_text("I love cats and dogs", animal_tag))
      tag_2 = submission.add_tag(tag_for_text("cats", cat_tag))
      expect(subject.markup).to eq(
        "#{milestone_for_st(tag_1, "start")}I love #{milestone_for_st(tag_2, "start")}cats#{milestone_for_st(tag_2, "end")} and dogs#{milestone_for_st(tag_1, "end")}, but my favourite animal is red pandas."
      )
    end
  end

  context "for a submission with tags partially contained within other tags" do
    it "marks up the text with xml markup of the tags" do
      tag_1 = submission.add_tag(tag_for_text("I love cats", cat_tag))
      tag_2 = submission.add_tag(tag_for_text("cats and dogs", animal_tag))
      expect(subject.markup).to eq(
        "#{milestone_for_st(tag_1, "start")}I love #{milestone_for_st(tag_2, "start")}cats#{milestone_for_st(tag_1, "end")} and dogs#{milestone_for_st(tag_2, "end")}, but my favourite animal is red pandas."
      )
    end
  end
end
# rubocop:enable Metrics/LineLength
