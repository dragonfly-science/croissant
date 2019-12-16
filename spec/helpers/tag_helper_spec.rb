require "rails_helper"

describe TagHelper, type: :helper do
  describe "#tag_colours" do
    it "returns the correct list of tag colours" do
      colour_array = %w[primary info success olive warning orange danger pink purple violet]
      expect(helper.tag_colours).to eq(colour_array)
    end
  end

  describe "#tag_colour(index)" do
    context "when provided with an single digit index argument" do
      it "returns the colour at that index of the tag_colours array" do
        expect(helper.tag_colour(0)).to eq("primary")
        expect(helper.tag_colour(4)).to eq("warning")
        expect(helper.tag_colour(9)).to eq("violet")
      end
    end

    context "when provided with an index argument greater than one digit" do
      it "uses the arguments last digit to return a colour" do
        expect(helper.tag_colour(20)).to eq("primary")
        expect(helper.tag_colour(34)).to eq("warning")
        expect(helper.tag_colour(559)).to eq("violet")
      end
    end
  end
end
