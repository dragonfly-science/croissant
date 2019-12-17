require "rails_helper"

describe TagHelper, type: :helper do
  describe "#tag_colours" do
    it "returns the correct list of tag colours" do
      colour_array = %w[primary info success olive warning orange danger pink purple violet]
      expect(TagHelper::TAG_COLOURS).to eq(colour_array)
    end
  end

  describe "#tag_colour_for_index(index)" do
    context "when provided with an single digit index argument" do
      it "returns the colour at that index of the tag_colours array" do
        expect(helper.tag_colour_for_index(0)).to eq("primary")
        expect(helper.tag_colour_for_index(4)).to eq("warning")
        expect(helper.tag_colour_for_index(9)).to eq("violet")
      end
    end

    context "when provided with an index argument greater than one digit" do
      it "uses the arguments last digit to return a colour" do
        expect(helper.tag_colour_for_index(20)).to eq("primary")
        expect(helper.tag_colour_for_index(34)).to eq("warning")
        expect(helper.tag_colour_for_index(559)).to eq("violet")
      end
    end
  end
end
