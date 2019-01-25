# == Schema Information
#
# Table name: websites
#
#  id                 :integer          not null, primary key
#  domain             :string
#  num_external_links :integer
#  num_internal_links :integer
#  created_at         :datetime
#  updated_at         :datetime
#

class Website < ActiveRecord::Base

end
