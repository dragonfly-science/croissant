class SurveyAnswer < ApplicationRecord
  has_paper_trail

  belongs_to :survey_question
  belongs_to :submission

  validates :answer, presence: true
end
