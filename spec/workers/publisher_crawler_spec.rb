require 'rails_helper'

RSpec.describe PublisherCrawler do
  let(:domain) {"test.com"}
  let(:example_html) {
    <<-HTML
      <!DOCTYPE html>
      <html lang="en" dir="ltr">
      <head>
        <body>
          <div>
            <a href="https://external1.com">hello</a>
            <a href="/internal/link1">test</a>
            <link href="https://external3.com"></a>
          </div>
          <a href="https://external2.com">
            <p>
              Some stuff
            </p>
          </a>

          <link href="/internal/link2"></a>
        </body>
      </html>
    HTML
  }

  context 'wesbite entry for the given domain exists' do
    it 'updates internal and external links' do
      Website.create!(domain: domain, num_external_links: 5, num_internal_links: 6)
      Website.create!(domain: 'domain2', num_external_links: 1, num_internal_links: 0)

      WebMock.stub_request(:get, "http://#{domain}/").
        and_return(status: 200, body: example_html)

      subject.perform(domain)
      website = Website.find_by(domain: domain)
      expect(website.num_external_links).to eq(3)
      expect(website.num_internal_links).to eq(2)
    end
  end

  context 'wesbite entry for the given domain DOES NOT exist' do
    it 'creates a new wesbite entry' do
      Website.create!(domain: 'domain2', num_external_links: 1, num_internal_links: 0)

      WebMock.stub_request(:get, "http://#{domain}/").
        and_return(status: 200, body: example_html)

      expect{subject.perform(domain)}.to change{Website.count}.by(1)
      website = Website.find_by(domain: domain)
      expect(website.num_external_links).to eq(3)
      expect(website.num_internal_links).to eq(2)
    end
  end
end
