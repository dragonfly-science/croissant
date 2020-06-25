# rubocop:disable Metrics/LineLength
class SubmissionTagMarkupService
  # Inserts milestone elements into the submission text
  # See https://en.wikipedia.org/wiki/Overlapping_markup
  def initialize(submission)
    @submission = submission
    @submission_tags = submission.submission_tags
  end

  def markup
    @markup ||= insert_tags
  end

  def markup_survey_answers
    @markup_survey_answers ||= sa_insert_tags
  end

  private

  def insert_tags
    text = @submission.text.clone
    tags_to_insert.each do |tag|
      text.insert(tag[:character], tag[:tag])
    end
    text
  end

  def sa_insert_tags
    sa_tags = []

    @submission.survey_answers.each do |sa|
      text = sa.answer.clone

      sa_tags_to_insert(sa).each do |tag|
        text.insert(tag[:character], tag[:tag])
      end

      sa_tags << { text: text, taggable_id: sa.id }
    end
    sa_tags
  end

  def tags_to_insert
    @tags_to_insert ||= generate_tags_to_insert(@submission_tags)
  end

  def sa_tags_to_insert(answer)
    generate_tags_to_insert(answer.submission_tags)
  end

  def generate_tags_to_insert(submission_tags)
    tags = []
    submission_tags.each do |submission_tag|
      tags << { character: submission_tag.start_char, tag: start_tag_for(submission_tag) }
      tags << { character: submission_tag.end_char + 1, tag: end_tag_for(submission_tag) }
      # + 1 because the hr should be before the start character, but after the end character
    end
    tags.sort_by { |tag| -tag[:character] } # reverse order by character
  end

  def start_tag_for(submission_tag)
    "<hr class=\"js-tag-milestone\" data-type=\"tag-start\" data-id=\"#{submission_tag.id}\" data-colour=\"#{submission_tag.tag.colour_number}\" data-tag-id=\"#{submission_tag.tag.id}\" />"
  end

  def end_tag_for(submission_tag)
    "<hr class=\"js-tag-milestone\" data-type=\"tag-end\" data-id=\"#{submission_tag.id}\" data-colour=\"#{submission_tag.tag.colour_number}\" data-tag-id=\"#{submission_tag.tag.id}\" />"
  end
end
# rubocop:enable Metrics/LineLength
