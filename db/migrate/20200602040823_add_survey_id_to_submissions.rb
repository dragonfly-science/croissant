class AddSurveyIdToSubmissions < ActiveRecord::Migration[6.0]
  def up
    change_table :submissions, bulk: true do |t|
      t.references :survey, null: true, foreign_key: true
    end
  end

  def down
    change_table :submissions do |t|
      t.remove :survey_id
    end
  end
end
