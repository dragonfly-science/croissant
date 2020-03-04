require "csv"

class CsvImportService
  def initialize(file)
    @file = file
    @results = []
  end

  def import_item_name
    # overwrite in subclasses
    "item"
  end

  def import!
    return false unless valid?

    results = []
    csv.each do |row|
      results << import_row(row)
    end
    @results = results
  end

  def import_row(row)
    # define in subclasses
  end

  def expected_headers
    []
  end

  def optional_headers
    []
  end

  def ignored_headers
    []
  end

  def valid?
    validity_errors.empty?
  end

  def validity_errors
    return ["Wrong format"] unless @file && @file.content_type == "text/csv"

    error_list = []
    error_list << "Wrong headers" unless contains_expected_headers? && only_contains_expected_or_optional_headers?
    error_list << "File empty" if csv.empty?
    error_list
  end

  def updated_items
    @results.select(&:updated?)
  end

  def created_items
    @results.select(&:created?)
  end

  def failed_items
    @results.select(&:failed?)
  end

  def unchanged_items
    @results.select(&:no_change?)
  end

  def results_notice
    status_group_notices.join(". ")
  end

  def errors_notice
    "#{pluralize(failed_items.length, import_item_name)} failed to import." if failed_items.any?
  end

  def contains_expected_headers?
    expected_headers - headers == []
  end

  def only_contains_expected_or_optional_headers?
    headers - expected_headers - optional_headers - ignored_headers == []
  end

  private

  def csv
    @csv ||= CSV.read(@file.open, headers: true)
  end

  def headers
    csv.headers
  end

  def pluralized_items(number)
    pluralize(number, import_item_name)
  end

  # rubocop:disable Metrics/AbcSize
  def status_group_notices
    notices = []
    notices << "#{pluralized_items(updated_items.length)} updated" if updated_items.any?
    notices << "#{pluralized_items(created_items.length)} created" if created_items.any?
    notices << "No change to #{pluralized_items(unchanged_items.length)}" if unchanged_items.any?
  end
  # rubocop:enable Metrics/AbcSize
end
