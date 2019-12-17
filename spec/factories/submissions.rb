FactoryBot.define do
  factory :submission do
    consultation
    description { "A lovely submission" }
    file { Rack::Test::UploadedFile.new("spec/support/example_files/00988_Anonymous.pdf", "application/pdf") }
  end
end
