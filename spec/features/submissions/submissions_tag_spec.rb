require "rails_helper"

RSpec.feature "Tagging a submission", js: true do
  let!(:consultation) { FactoryBot.create(:consultation, :with_taxonomy_tags) }
  let!(:submission) do
    FactoryBot.create(:submission, :ready_to_tag, consultation: consultation,
                                                  text: "cows dogs and sheep in the ocean riding waves")
  end
  let!(:tags) { consultation.taxonomy.tags }

  before do
    visit consultation_submission_tag_path(consultation, submission)
  end

  it "renders selectable tags for the submission" do
    expect(page).to have_selector("button", text: tags.first.name)
  end

  it "renders the submissions text" do
    expect(page).to have_content(submission.text)
  end

  describe "tagging", js: true do
    context "with highlighted text" do
      it "applies a visual tag when one of the tags in the taxonomy list is selected" do
        highlight_selection(4, 19)
        find(".submission-tag[data-tag-name='#{tags.first.name}']").click
        expect(find(".tagged")).to have_text("dogs and sheep")
      end

      it "can apply multiple tags to a piece of text" do
        highlight_selection(4, 19)
        find(".submission-tag[data-tag-name='#{tags.first.name}']").click
        find(".submission-tag[data-tag-name='#{tags.second.name}']").click
        expect(find(".tagged[data-tag-name='#{tags.first.name}']")).to have_text("dogs and sheep")
        expect(find(".tagged[data-tag-name='#{tags.second.name}']")).to have_text("dogs and sheep")
      end

      xit "can apply tags that overlap"
    end

    xit "can remove tags that are applied to specific bits of text" do
      highlight_selection(4, 19)
      find(".submission-tag[data-tag-name='#{tags.first.name}']").click
      expect(find(".tagged[data-tag-name='#{tags.first.name}']")).to have_text("dogs and sheep")
      # still need functionality to remove tags in situ
    end

    it "refreshing the page displays existing tags" do
      highlight_selection(5, 19)
      find(".submission-tag[data-tag-name='#{tags.first.name}']").click
      highlight_selection(20, 32)
      find(".submission-tag[data-tag-name='#{tags.third.name}']").click
      visit consultation_submission_tag_path(consultation, submission)
      expect(find(".tagged[data-tag-name='#{tags.first.name}']")).to have_text("dogs and sheep")
      expect(find(".tagged[data-tag-name='#{tags.third.name}']")).to have_text("in the ocean")
    end
  end
end
