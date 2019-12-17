module TagHelper
  TAG_COLOURS = %w[primary info success olive warning orange danger pink purple violet].freeze

  def tag_colour_for_index(index)
    colour_index = index % TAG_COLOURS.length
    TAG_COLOURS[colour_index]
  end
end
