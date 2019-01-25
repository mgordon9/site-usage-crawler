class CreateDomainCountries < ActiveRecord::Migration
  def change
    create_table :domain_countries do |t|
      t.string :domain
      t.string :country
      t.float :percentage
      t.timestamps
    end
  end
end
