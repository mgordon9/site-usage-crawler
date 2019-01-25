class CreateDomainCountries < ActiveRecord::Migration
  def change
    create_table :domain_countries do |t|
      # ActiveRecord::Migration will generate the default primary key as int
      t.string :domain
      t.string :country
      t.float :percentage

      # I find these columns very useful for every table.
      # Rails will manage updated_at and created_at columns.
      t.timestamps
    end
  end
end
