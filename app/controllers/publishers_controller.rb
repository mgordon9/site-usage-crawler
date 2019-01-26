class PublishersController < ApplicationController
  def show
    if params["domain"].present?
      @domain = params["domain"]
      @domain_contries = DomainCountry.where(domain: @domain)
      @website = Website.find_by(domain: @domain)
    end
  end

  def update_publisher_data
    @domain = params['domain']
    PublisherCrawler.perform_async(@domain)
    redirect_to publishers_path(domain: @domain)
  end
end
