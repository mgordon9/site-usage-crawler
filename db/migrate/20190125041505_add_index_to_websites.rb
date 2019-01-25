class AddIndexToWebsites < ActiveRecord::Migration
  def change
    add_index :websites, :domain, unique: true
  end
end
