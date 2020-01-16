class TagNumberer
  def self.call(taxonomy)
    recursively_number_tags(taxonomy.tags.top_level)
  end

  def self.recursively_number_tags(tags)
    tags.each_with_index do |tag, index|
      tag.update(number: index + 1)
      TagNumberer.recursively_number_tags(tag.children)
    end
  end

  def self.new_number_for(numbering_context)
    initial_number = numbering_context.count + 1
    check_and_update_if_used(initial_number, numbering_context)
  end

  def self.check_and_update_if_used(number, numbering_context)
    if numbering_context.find_by(number: number.to_s)
      number += 1
      check_and_update_if_used(number, numbering_context)
    else
      number
    end
  end
end
