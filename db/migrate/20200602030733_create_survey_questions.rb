class CreateSurveyQuestions < ActiveRecord::Migration[6.0]
  def change
    create_table :survey_questions do |t|
      t.references :survey, null: false, foreign_key: true
      t.text :question, null: false
      t.string :token

      t.timestamps
    end
  end
end
