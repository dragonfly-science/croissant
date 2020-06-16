FactoryBot.define do
  factory :survey_import do
    consultation
    file { Rack::Test::UploadedFile.new("spec/support/example_files/survey_upload.csv", "text/csv") }
  end
end
