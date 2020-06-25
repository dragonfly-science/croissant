class SurveyAnswer < ApplicationRecord
  has_paper_trail

  belongs_to :survey_question
  belongs_to :submission

  has_many :submission_tags, as: :taggable, dependent: :destroy

  validates :answer, presence: true

  delegate :tag, to: :submission
  delegate :filename, to: :submission

  def concatenate_with_question
    "****#{survey_question.token}****#{answer}\n"
  end

  def add_tag(params)
    return false unless submission.can_tag?

    params.delete("submission_id")
    params.delete("answer_id")
    params[:taggable] = self

    submission_tags.create(params)
  end

  def text
    answer
  end
end
