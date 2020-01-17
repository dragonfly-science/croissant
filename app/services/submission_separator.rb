class SubmissionSeparator
  def initialize(submission, character_limit: 32_000)
    @submission = submission
    @text = submission.text.to_s
    @character_limit = character_limit
  end

  def parts
    @parts ||= split_submission
  end

  def part_count
    parts.length
  end

  private

  def split_submission
    io = StringIO.new(@text)
    part_number = 1
    parts = []

    until io.eof?
      chunk = io.read(@character_limit)
      part = SubmissionPart.new(@submission, part_number, chunk)
      parts << part
      part_number += 1
    end

    parts << SubmissionPart.new(@submission, 1, "") if parts.empty?

    parts
  end
end
