# == Schema Information
#
# Table name: domain_countries
#
#  id         :integer          not null, primary key
#  domain     :string
#  country    :string
#  percentage :float
#  created_at :datetime
#  updated_at :datetime
#

class DomainCountry < ActiveRecord::Base

end
