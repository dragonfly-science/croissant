class SubmissionsController < ApplicationController
  before_action :consultation, only: %i[index create destroy tag]
  before_action :set_submission, only: %i[show destroy edit update mark_process tag]

  # GET /submissions
  def index
    @submissions = @consultation.submissions
  end

  # GET /submissions/1
  def show
  end

  # POST /submissions
  def create
    creator = SubmissionCreator.new(create_submission_params: create_submission_params,
                                    file_upload_params: file_upload_params)
    creator.create!
    redirect_to consultation_submissions_url(@consultation), notice: creator.notice
  end

  # DELETE /submissions/1
  def destroy
    @submission.destroy
    redirect_to consultation_submissions_url(@consultation), notice: "Submission was successfully destroyed."
  end

  # GET /submissions/1/tag
  def tag
    @submission_tags = @submission.submission_tags
  end

  # GET /submissions/1/edit
  def edit
    @submission.populate_text_from_file_if_present if @submission.incoming?
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

  def set_submission
    submission_id = params[:id] || params[:submission_id]

    @submission = if @consultation.present?
                    @consultation.submissions.find(submission_id)
                  else
                    Submission.find(submission_id)
                  end
  end

  def consultation
    @consultation ||= Consultation.find(params[:consultation_id])
  end

  # Only allow a trusted parameter "white list" through.
  def create_submission_params
    params.require(:submission).permit(%i[file].concat(Submission::METADATA_FIELDS))
          .merge(consultation: consultation)
  end

  def edit_submission_params
    params.require(:submission).permit(%i[text].concat(Submission::METADATA_FIELDS))
  end

  def file_upload_params
    params[:submission][:file]
  end
end
