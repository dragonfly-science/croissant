FactoryBot.define do
  factory :survey_answer do
    survey_question
    submission

    answer { Faker::Book.title }
  end
end
