class CreateWebsites < ActiveRecord::Migration
  def change
    create_table :websites do |t|
      t.string :domain
      t.integer :num_external_links
      t.integer :num_internal_links
      t.timestamps
    end
  end
end
