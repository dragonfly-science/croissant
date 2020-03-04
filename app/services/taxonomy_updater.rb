require "csv"

class TaxonomyUpdater < CsvImportService
  def initialize(file, taxonomy)
    @file = file
    @taxonomy = taxonomy
    @results = []
  end

  def expected_headers
    %w[tag_id number name description]
  end

  def import!
    return false unless valid?

    results = []
    csv.each do |row|
      results << create_or_update_tag(row)
    end
    @results = results
  end

  private

  def create_or_update_tag(row)
    if identical_tag(row)
      TagResult.new(:no_change, identical_tag(row))
    elsif existing_tag(row)
      update_existing_tag(existing_tag(row), row["name"], row["number"], row["description"])
    else
      create_new_tag(row["name"], row["number"], row["description"])
    end
  end

  def identical_tag(row)
    @taxonomy.tags.find_by(name: row["name"], full_number: row["number"],
                           description: row["description"])
  end

  def existing_tag(row)
    @taxonomy.tags.find_by(id: row["tag_id"])
  end

  def update_existing_tag(tag, name, number, description)
    if tag.update(name: name, full_number: number, number: base_number(number),
                  parent: parent_tag(number), description: description)
      TagResult.new(:updated, tag)
    else
      TagResult.new(:failed, tag)
    end
  end

  def create_new_tag(name, number, description)
    tag = @taxonomy.tags.new(name: name, full_number: number, number: base_number(number),
                             parent: parent_tag(number), description: description)
    if tag.save
      TagResult.new(:created, tag)
    else
      TagResult.new(:failed, tag)
    end
  end

  def base_number(number)
    number.split(".").last
  end

  def parent_number(number)
    return nil if number.length == 1

    number.split(".")[0..-2].join(".")
  end

  def parent_tag(number)
    @taxonomy.tags.find_by(full_number: parent_number(number))
  end
end
