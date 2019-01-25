class PublisherCrawler
  include Sidekiq::Worker

  DOMAIN_USAGE_URL = "https://www.alexa.com/siteinfo/"
  LINK_TAGS = ['a', 'link'].freeze

  attr_reader :domain

  def perform(domain)
    # TODO: handle unhandled errors
    @domain = domain
    # TODO: parse out 'http://' and 'https://'
    # TODO: Get usage for domain
    logger.info("Crawling domain for usage: #{domain}")



    logger.info("Crawling domain for internal and external links: #{domain}")

    page = retrieve_html(domain)
    link_tags = extract_link_tags(page)
    external_links, internal_links = seperate_external_and_internal_tags(link_tags)
    update_website(external_links, internal_links)
  end

  private

  def find_links
    page = retrieve_html
    link_tags = extract_link_tags(page)
    external_links, internal_links = seperate_external_and_internal_tags(link_tags)
    update_website(external_links, internal_links)
  end

  def retrieve_html
    response = RestClient.get(domain)
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
