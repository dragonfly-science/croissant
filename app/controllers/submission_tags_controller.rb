class SubmissionTagsController < ApplicationController
  protect_from_forgery unless: -> { request.format.json? }
  before_action :set_submission_tag, only: :destroy
  before_action :set_submission, only: :create

  def create
    @submission_tag = @submission.add_tag(submission_tag_params)

    if @submission_tag.errors.none?
      render json: @submission_tag, include: :tag
    else
      errors = ["Tag failed to save"].concat(@submission_tag.errors.full_messages)
      render json: { errors: errors }, status: :internal_server_error
    end
  end

  def destroy
    @submission_tag.destroy
    redirect_to submission_url(@submission_tag.submission), notice: "Tag was successfully removed."
  end

  def submission_tag_params
    params.require(:submission_tag).permit(:submission_id, :tag_id, :start_char, :end_char, :text)
  end

  private

  def set_submission
    @submission = Submission.find(submission_tag_params[:submission_id])
  end

  def set_submission_tag
    @submission_tag = SubmissionTag.find(params[:id])
  end
end
