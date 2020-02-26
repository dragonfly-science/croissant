class SubmissionsController < ApplicationController # rubocop:disable Metrics/ClassLength
  before_action :consultation, only: %i[index create destroy tag]
  before_action :set_submission, only: %i[show destroy edit update tag
                                          mark_process mark_complete mark_reject
                                          mark_archived mark_restored ]
  before_action :markup_submission, only: %i[show tag]
  before_action :submission_crumbs, only: %i[index show edit update tag]

  # GET /submissions
  def index
    authorize @consultation, :consultation_access?
    @submissions = @consultation.submissions
  end

  # GET /submissions/1
  def show
    breadcrumb "Submission #{@submission.id}", :submission_path
  end

  # POST /submissions
  def create
    authorize @consultation, :consultation_write_access?
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
    breadcrumb "Submission #{@submission.id}", submission_path(@submission)
    breadcrumb "Tag", :consultation_submission_tag_path
    @submission_tags = @submission.submission_tags
  end

  # GET /submissions/1/edit
  def edit
    breadcrumb "Submission #{@submission.id}", submission_path(@submission)
    breadcrumb "Edit", edit_submission_path(id: @submission.id)
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

  # PUT /submissions/:id/complete
  def mark_complete
    if @submission.complete_tagging
      redirect_to submission_url(@submission, notice: "Submission is marked as complete")
    else
      redirect_back(notice: "Submission failed to complete")
    end
  end

  # PUT /submissions/:id/reject
  def mark_reject
    if @submission.reject
      redirect_to submission_url(@submission, notice: "Submission has been rejected, can be tagged again")
    else
      redirect_back(notice: "Submission failed to reject")
    end
  end

  def mark_archived
    if @submission.archive!
      redirect_to submission_url(@submission, notice: "Submission has been archived")
    else
      redirect_back(notice: "Failed to archive submission")
    end
  end

  def mark_restored
    if @submission.restore!
      redirect_to submission_url(@submission, notice: "Submission has been restored")
    else
      redirect_back(notice: "Failed to restore submission")
    end
  end

  private

  def set_submission
    submission_id = params[:id] || params[:submission_id]
    if @consultation.present?
      @submission = @consultation.submissions.find(submission_id)
    else
      @submission = Submission.find(submission_id)
      @consultation = @submission.consultation
    end
    authorize @submission
  end

  def markup_submission
    return unless @submission && @submission.text.present?

    markup_service = SubmissionTagMarkupService.new(@submission)
    @marked_up_text = markup_service.markup
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

  def submission_crumbs
    breadcrumb "Consultations", :consultations_path, match: :exclusive
    breadcrumb @consultation.name, consultation_submissions_path(consultation_id: @consultation.id), match: :exclusive
  end
end
