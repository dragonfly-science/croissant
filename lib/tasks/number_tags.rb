task :number_tags do
  Taxonomy.all.each do |taxonomy|
    TagNumberer.call(taxonomy)
  end
end
