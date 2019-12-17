module TagHelper
  TAG_COLOURS = %w[primary info success olive warning orange danger pink purple violet].freeze

  def tag_colour_for_index(index)
    # there are only 10 colours available for tags so we only care about
    # index values between 0 and 9 when we access them.
    colour_index = index % TAG_COLOURS.length
    TAG_COLOURS[colour_index]
  end
end
