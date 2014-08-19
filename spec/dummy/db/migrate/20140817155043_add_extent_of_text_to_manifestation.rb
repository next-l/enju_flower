class AddExtentOfTextToManifestation < ActiveRecord::Migration
  def change
    add_column :manifestations, :extent_of_text, :text
  end
end
