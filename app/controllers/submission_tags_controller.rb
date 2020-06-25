class SubmissionTagsController < ApplicationController
  before_action :set_submission_tag, only: :destroy
  before_action :set_taggable, only: :create

  def create
    @submission_tag = @taggable.add_tag(submission_tag_params.merge(tagger: current_user))
    authorize @submission_tag
    if @submission_tag.errors.none?
      render json: @submission_tag, include: :tag
    else
      errors = ["Tag failed to save"].concat(@submission_tag.errors.full_messages)
      render json: { errors: errors }, status: :internal_server_error
    end
  end

  def destroy
    return destroy_success if @submission_tag.destroy

    destroy_failure
  end

  def submission_tag_params
    params.require(:submission_tag).permit(:submission_id, :tag_id, :start_char,
                                           :end_char, :text, :tagger_id, :taggable_id,
                                           :taggable_type, :answer_id)
  end

  private

  def destroy_success
    respond_to do |format|
      format.json do
        render json: { submission_tag: @submission_tag }
      end
      format.html do
        redirect_to submission_url(@submission_tag.submission_id), notice: "Tag was successfully removed."
      end
    end
  end

  def destroy_failure
    respond_to do |format|
      format.json do
        render json: { errors: @submission_tag.errors.full_messages }, status: :internal_server_error
      end
      format.html do
        redirect_to submission_url(@submission_tag.submission_id), alert: t("submission_tag.destroy.failure")
      end
    end
  end

  def set_taggable
    @taggable = if submission_tag_params[:answer_id]
                  SurveyAnswer.find(submission_tag_params[:answer_id])
                else
                  Submission.find(submission_tag_params[:submission_id])
                end
  end

  def set_submission_tag
    @submission_tag = SubmissionTag.find(params[:id])
    authorize @submission_tag
  end
end
