FactoryBot.define do
  factory :submission do
    consultation
    description { "A lovely submission" }
    file { Rack::Test::UploadedFile.new("spec/support/example_files/00988_Anonymous.pdf", "application/pdf") }

    trait :incoming do
      text { "Taggable submission text" }
      state { :incoming }
    end
    trait :ready_to_tag do
      text { "Taggable submission text" }
      state { :ready }
    end
    trait :started do
      text { "Taggable submission text" }
      state { :started }
    end
    trait :finished do
      text { "Taggable submission text" }
      state { :finished }
    end
    trait :archived do
      text { "Taggable submission text" }
      state { :archived }
    end
    trait :with_survey do
      survey
    end
  end
end
