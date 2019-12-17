class SubmissionsController < ApplicationController
  before_action :consultation
  before_action :set_submission, only: %i[show destroy]

  # GET /submissions
  def index
    @submissions = @consultation.submissions
  end

  # GET /submissions/1
  def show
  end

  # POST /submissions
  def create
    @submission = Submission.new(submission_params)
    @submission.file.attach(submission_params[:file])

    if @submission.save
      redirect_to [@consultation, @submission], notice: "Submission was successfully created."
    else
      render :new
    end
  end

  # DELETE /submissions/1
  def destroy
    @submission.destroy
    redirect_to consultation_submissions_url(@consultation), notice: "Submission was successfully destroyed."
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_submission
    @submission = consultation.submissions.find(params[:id])
  end

  def consultation
    @consultation ||= Consultation.find(params[:consultation_id])
  end

  # Only allow a trusted parameter "white list" through.
  def submission_params
    params.require(:submission).permit(:file, :description).merge(consultation: consultation)
  end
end
