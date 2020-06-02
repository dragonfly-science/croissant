FactoryBot.define do
  factory :survey_question do
    survey
    question { Faker::Book.title }
  end
end
