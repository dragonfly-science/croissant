class AddNumberToTag < ActiveRecord::Migration[6.0]
  def change
    add_column :tags, :number, :string
    Taxonomy.all.each do |taxonomy|
      TagNumberer.call(taxonomy)
    end
  end
end
