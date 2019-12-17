class PdfTextExtractor
  def self.call(pdf)
    reader = PDF::Reader.new(pdf)
    pages = []
    reader.pages.each do |page|
      text = page.text.tr("\t", " ")
      pages << text
    end
    pages.join("\n")
  end
end
