class AddFullNumberToTag < ActiveRecord::Migration[6.0]
  def change
    add_column :tags, :full_number, :string
    Taxonomy.all.each do |taxonomy|
      TagNumberer.call(taxonomy)
    end
  end
end
