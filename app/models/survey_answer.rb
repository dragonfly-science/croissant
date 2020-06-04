class SurveyAnswer < ApplicationRecord
  has_paper_trail

  belongs_to :survey_question
  belongs_to :submission

  validates :answer, presence: true

  def concatenate_with_question
    "****#{survey_question.token}****#{answer}\n"
  end
end
