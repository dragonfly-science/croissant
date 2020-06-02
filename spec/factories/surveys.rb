FactoryBot.define do
  factory :survey do
    consultation
    original_file { Rack::Test::UploadedFile.new("spec/support/example_files/survey_upload.csv", "text/csv") }
  end
end
