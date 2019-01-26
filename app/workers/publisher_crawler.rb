class PublisherCrawler
  include Sidekiq::Worker

  DOMAIN_USAGE_URL = "https://www.alexa.com/siteinfo/"
  LINK_TAGS = ['a', 'link'].freeze

  def perform(domain)
    parse_domain(domain)
    update_usage_statistics
    update_domain_link_counts
  rescue => e
    # since this can be run asyncronously, we should notify the monitoring service(bugsnag, datadog, etc)
    # and the service that initiated this worker or any services that need to know if this worker failed.
    # For this app, logging might be sufficient.
    logger.fatal("Encountered unhandled exception: #{e}\n#{e.backtrace}")

    # Re-raise incase we ran this syncronously and/or we want sidekiq to retry
    raise e
  end

  private

  attr_reader :domain

  def parse_domain(domain)
    if URI(domain).host
      @domain = URI(domain).host
    else
      @domain = URI("http://#{domain}").host
    end
  end

  def update_usage_statistics
    logger.info("Crawling domain for usage: '#{domain}'")

    url = URI.join(DOMAIN_USAGE_URL, domain)
    page = retrieve_html(url.to_s)
    country_percentages = parse_top_country_percentages(page)
    update_domain_countries(country_percentages)

    logger.info("Updated domain countries for domain: '#{domain}'")
  end

  def parse_top_country_percentages(page)
    rows = parse_top_usage_country_entries(page)
    country_percentages = {}
    rows.each do |row|
      country = parse_country(row)
      country_percentages[country] = parse_percentage(row)
    end

    country_percentages
  end

  def parse_top_usage_country_entries(page)
    page.at_css('table#demographics_div_country_table').css('tbody').css('tr')
  end

  def parse_country(row)
    row.css('td')[0].css('a').first.text.gsub(/\A[[:space:]]+|[[:space:]]+\z/, '')
  end

  def parse_percentage(row)
    row.css('td')[1].css('span').first.text.to_f
  end

  def update_domain_countries(country_percentages)
    ActiveRecord::Base.transaction do
      DomainCountry.where(domain: domain).destroy_all
      country_percentages.each do |country, percentage|
        DomainCountry.create!(domain: domain, country: country, percentage: percentage)
      end
    end
  end

  def update_domain_link_counts
    logger.info("Crawling domain for internal and external links: #{domain}")

    page = retrieve_html(domain)
    link_tags = extract_link_tags(page)
    external_links, internal_links = seperate_external_and_internal_tags(link_tags)
    update_website(external_links, internal_links)

    logger.info("Updated link counts for domain: #{domain}")
  end

  def retrieve_html(url)
    # TODO: handle redirects
    response = RestClient.get(url)
    Nokogiri::HTML(response)
  end

  def extract_link_tags(page)
    link_tags = LINK_TAGS.inject([]) do |total_link_tags, link_tag|
      total_link_tags += page.css(link_tag)
    end

    link_tags.select{ |tag| valid_link_tag?(tag) }
  end

  def seperate_external_and_internal_tags(link_tags)
    link_tags.partition{ |tag| external_link?(tag) }
  end

  def update_website(external_links, internal_links)
    website = Website.find_or_create_by(domain: domain)
    website.update!(num_internal_links: internal_links.count, num_external_links: external_links.count)
  end

  def valid_link_tag?(tag)
    tag.attribute('href').present?
  end

  def external_link?(tag)
    uri = URI(tag.attribute('href').value)
    uri.host.present? && uri.host != domain
  end
end
