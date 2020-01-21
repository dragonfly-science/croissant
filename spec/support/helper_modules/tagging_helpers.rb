module TaggingHelpers
  def tag_selection(range_start, range_end)
    page.execute_script(<<~JS, range_start, range_end)
      (function(rangeStart, rangeEnd) {
        let range = new Range();
        range.setStart(submissionText.firstChild, rangeStart);
        range.setEnd(submissionText.firstChild, rangeEnd);
        window.getSelection().addRange(range);
      })(arguments[0], arguments[1])
    JS
  end
end
