TagResult = Struct.new(:status, :tag) do
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
    "#{tag.full_number} #{tag.name}: #{tag.errors.full_messages.join(",")}"
  end
end
