module TagHelper
  def submission_text_with_tags(text, tags) # rubocop:disable Metrics/AbcSize
    ordered_tags = tags.sort_by(&:start_char)
    additional_characters = 0
    full_text = text.clone # to avoid side effects

    ordered_tags.each do |tag|
      highlighted_tag = build_content_tag(tag)

      start_char = tag.start_char + additional_characters
      end_char = tag.end_char + additional_characters

      full_text[start_char..end_char] = ""
      full_text.insert(start_char, highlighted_tag)
      additional_characters += (highlighted_tag.length - tag.text.length)
    end

    full_text
  end

  def build_content_tag(tag)
    content_tag("span", tag.text,
                class: "tagged tagged--colour-#{tag.colour_number}",
                data: { tag_name: tag.name,
                        start_character: tag.start_char,
                        end_character: tag.end_char })
  end
end
