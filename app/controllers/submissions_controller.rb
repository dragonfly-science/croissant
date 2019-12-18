class SubmissionsController < ApplicationController
  before_action :consultation, only: %i[index create destroy]
  before_action :set_submission, only: %i[show destroy edit update mark_process]

  # GET /submissions
  def index
    @submissions = @consultation.submissions
  end

  # GET /submissions/1
  def show
  end

  # POST /submissions
  def create
    @submission = Submission.new(create_submission_params)
    @submission.file.attach(create_submission_params[:file])

    if @submission.save
      redirect_to @submission, notice: "Submission was successfully created."
    else
      render :new
    end
  end

  # DELETE /submissions/1
  def destroy
    @submission.destroy
    redirect_to consultation_submissions_url(@consultation), notice: "Submission was successfully destroyed."
  end

  # GET /submissions/1/edit
  def edit
    @submission.populate_text_from_file_if_present if @submission.can_process?
  end

  # PUT/PATCH /submissions/1
  def update
    @submission.update(edit_submission_params)
    if @submission.save
      redirect_to submission_url(@submission), notice: "Submission was updated"
    else
      render :edit
    end
  end

  # PUT /submissions/:id/process
  def mark_process
    if @submission.process
      redirect_to submission_url(@submission, notice: "Submission is ready to tag")
    else
      redirect_back(notice: "Submission failed to process")
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_submission
    @submission = if @consultation.present?
                    consultation.submissions.find(params[:id])
                  else
                    Submission.find(params[:id])
                  end
  end

  def consultation
    @consultation ||= Consultation.find(params[:consultation_id])
  end

  # Only allow a trusted parameter "white list" through.
  def create_submission_params
    params.require(:submission).permit(:file, :description).merge(consultation: consultation)
  end

  def edit_submission_params
    params.require(:submission).permit(:description, :text)
  end
end
