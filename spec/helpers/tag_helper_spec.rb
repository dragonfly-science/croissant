require "rails_helper"

describe TagHelper, type: :helper do
  describe "#tag_colours" do
    it "returns the correct list of tag colours" do
      colour_array = %w[primary info success olive warning orange danger pink purple violet]
      expect(described_class.tag_colours).to eq(colour_array)
    end
  end

  describe "#tag_colour(index)" do
    context "when provided with an single digit index argument" do
      it "returns the colour at that index of the tag_colours array" do
      end
    end

    context "when provided with an index argument greater than one digit" do
      it "returns the colour " do
      end
    end
  end
end
