SubmissionResult = Struct.new(:status, :submission, :filename) do
  def success?
    %i[created updated].include?(status)
  end

  def created?
    status == :created
  end

  def updated?
    status == :updated
  end

  def failed?
    status == :failed
  end

  def no_change?
    status == :no_change
  end

  def formatted_error_messages
    message = filename.present? ? "#{filename}: " : ""
    message + submission.errors.full_messages.join(",").to_s
  end
end
