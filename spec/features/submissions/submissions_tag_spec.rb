require "rails_helper"

RSpec.feature "Tagging a submission", js: true do
  let(:user) { FactoryBot.create(:user, role: "superadmin") }
  let!(:consultation) { FactoryBot.create(:consultation, :with_taxonomy_tags) }
  let!(:submission) do
    FactoryBot.create(:submission, :ready_to_tag, consultation: consultation,
                                                  text: "cows dogs and sheep in the ocean riding waves")
  end
  let!(:tags) { consultation.taxonomy.tags }
  before { sign_in(user) }

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
        highlight_selection(5, 18)
        find(".submission-tag[data-tag-name='#{tags.first.name}']").click
        expect(find(".tagged.tagged--colour-#{tags.first.colour_number}")).to have_text("dogs and sheep")
      end

      it "can apply multiple tags to a piece of text" do
        highlight_selection(5, 18)
        find(".submission-tag[data-tag-name='#{tags.first.name}']").click
        find(".submission-tag[data-tag-name='#{tags.second.name}']").click
        expect(find(".tagged")).to have_text("dogs and sheep")
      end

      it "saves the user as the tagger" do
        expect do
          highlight_selection(5, 18)
          find(".submission-tag[data-tag-name='#{tags.first.name}']").click
          sleep(0.5) # give it a moment to run through, or it'll be flaky
        end.to change { user.submission_tags.count }.by(1)
      end

      xit "can apply tags that overlap" do
        highlight_selection(5, 18)
        find(".submission-tag[data-tag-name='#{tags.first.name}']").click
        expect(find(".tagged.tagged--colour-#{tags.first.colour_number}")).to have_text("dogs and sheep")
        highlight_selection(0, 18)
        find(".submission-tag[data-tag-name='#{tags.third.name}']").click
        expect(find(".tagged.tagged--colour-#{tags.third.colour_number}")).to have_text("cows ")
        c = ".tagged.tagged--colour-#{tags.first.colour_number}.tagged--secondary-colour-#{tags.third.colour_number}"
        expect(find(c)).to have_text("dogs and sheep")
      end
    end

    xit "can remove tags that are applied to specific bits of text" do
      highlight_selection(5, 18)
      find(".submission-tag[data-tag-name='#{tags.first.name}']").click
      expect(find(".tagged[data-tag-id='#{tags.first.id}']")).to have_text("dogs and sheep")
      # still need functionality to remove tags in situ
    end

    context "when revisiting a submission with existing tags" do
      let!(:submission_tag_one) do
        FactoryBot.create(:submission_tag,
                          submission: submission,
                          tag: tags.first,
                          tagger: user,
                          start_char: 5,
                          end_char: 18,
                          text: "dogs and sheep")
      end
      let!(:submission_tag_two) do
        FactoryBot.create(:submission_tag,
                          submission: submission,
                          tag: tags.third,
                          tagger: user,
                          start_char: 20,
                          end_char: 31,
                          text: "in the ocean")
      end
      it "displays existing tags" do
        visit consultation_submission_tag_path(consultation, submission)
        expect(find(".js-tagged[data-st-ids='#{submission_tag_one.id}']")).to have_text("dogs and sheep")
        expect(find(".js-tagged[data-st-ids='#{submission_tag_two.id}']")).to have_text("in the ocean")
      end

      it "displays existing tags attached to a piece of text when that text is selected" do
        visit consultation_submission_tag_path(consultation, submission)
        find(".js-tagged[data-st-ids='#{submission_tag_one.id}']").click
        expect(find("#js-selected-tag-text")).to have_text("dogs and sheep")
        expect(find(".js-submission-tag[data-st-id='#{submission_tag_one.id}']")).to_not be_nil
      end
    end
  end
end
