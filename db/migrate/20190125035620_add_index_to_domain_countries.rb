class AddIndexToDomainCountries < ActiveRecord::Migration
  def change
    add_index :domain_countries, [:domain, :country], unique: true
  end
end
