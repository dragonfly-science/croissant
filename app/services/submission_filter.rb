class SubmissionFilter < Filter
  attr_reader :filename
  attr_reader :state
  attr_reader :include_archived

  def default_params
    { include_archived: false }
  end

  def filter_by_filename(submissions, query)
    @filename = query
    submissions.search_by_filename(query)
  end

  def filter_by_state(submissions, query)
    @state = query
    submissions.where(state: query)
  end

  def filter_by_include_archived(submissions, value)
    @include_archived = true_or_false_value(value)
    @include_archived ? submissions : submissions.active
  end

  private

  def true_or_false_value(value)
    return false if value.blank?

    return false if value.to_s == "0"

    true
  end
end
