require 'rails_helper'

RSpec.describe PublisherCrawler do
  let(:domain) {"test.com"}
  let(:domain_usage_url) {"https://www.alexa.com/siteinfo/#{domain}"}
  let(:expected_countries) {
    [
      "United States",
      "United Kingdom",
      "Canada",
      "Germany",
      "France"
    ]
  }
  let(:example_domain_html) {
    <<-HTML
      <!DOCTYPE html>
      <html lang="en" dir="ltr">
        <head></head>
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
  let(:example_usage_of_domain_html) {
    <<-HTML
    <!DOCTYPE html>
      <html lang="en" dir="ltr">
      <head></head>
        <body>
          <table cellpadding="0" cellspacing="0" id="demographics_div_country_table" class="table  ">
            <thead>
              <tr>
                <th  style="width: 100px;" class="text-left header">Country</th>
                <th  style="" class="text-right header">Percent of Visitors</th>
                <th  style="" class="text-right header">Rank in Country</th>
              </tr>
            </thead>
            <tbody>
              <tr data-count="1" class=" ">
              <td class=''><a href='/topsites/countries/US'><img class='dynamic-icon' src='/images/flags/us.png' alt='United States Flag'/> &nbsp;United States</a></td>                            <td class='text-right' ><span class=''>41.1%</span></td>                            <td class='text-right' ><span class=''>75</span></td>                    </tr>
              <tr data-count="2" class=" ">
              <td class=''><a href='/topsites/countries/GB'><img class='dynamic-icon' src='/images/flags/gb.png' alt='United Kingdom Flag'/> &nbsp;United Kingdom</a></td>                            <td class='text-right' ><span class=''>6.9%</span></td>                            <td class='text-right' ><span class=''>90</span></td>                    </tr>
              <tr data-count="3" class=" ">
              <td class=''><a href='/topsites/countries/CA'><img class='dynamic-icon' src='/images/flags/ca.png' alt='Canada Flag'/> &nbsp;Canada</a></td>                            <td class='text-right' ><span class=''>5.4%</span></td>                            <td class='text-right' ><span class=''>38</span></td>                    </tr>
              <tr data-count="4" class=" ">
              <td class=''><a href='/topsites/countries/DE'><img class='dynamic-icon' src='/images/flags/de.png' alt='Germany Flag'/> &nbsp;Germany</a></td>                            <td class='text-right' ><span class=''>5.0%</span></td>                            <td class='text-right' ><span class=''>122</span></td>                    </tr>
              <tr data-count="5" class=" ">
              <td class=''><a href='/topsites/countries/FR'><img class='dynamic-icon' src='/images/flags/fr.png' alt='France Flag'/> &nbsp;France</a></td>                            <td class='text-right' ><span class=''>3.7%</span></td>                            <td class='text-right' ><span class=''>204</span></td>                    </tr>
            </tbody>
          </table>
        </body>
      </html>
    HTML
  }

  def create_domain_countries(domain)
    DomainCountry.create!(domain: domain, country: 'country1', percentage: 20.1)
    DomainCountry.create!(domain: domain, country: 'country2', percentage: 1.1)
    DomainCountry.create!(domain: domain, country: 'country3', percentage: 3.2)
    DomainCountry.create!(domain: domain, country: 'country4', percentage: 9.6)
    DomainCountry.create!(domain: domain, country: 'country5', percentage: 32.4)
  end

  context 'wesbite entry and domain countries entries for the given domain exist' do
    it 'updates internal and external links and changes the domain countries entries' do
      create_domain_countries(domain)
      create_domain_countries('domain2')
      Website.create!(domain: domain, num_external_links: 5, num_internal_links: 6)
      Website.create!(domain: 'domain2', num_external_links: 1, num_internal_links: 0)

      WebMock.stub_request(:get, domain_usage_url).
        and_return(status: 200, body: example_usage_of_domain_html)
      WebMock.stub_request(:get, "http://#{domain}/").
        and_return(status: 200, body: example_domain_html)

      subject.perform(domain)

      countries = DomainCountry.where(domain: domain).pluck(:country)
      expect(countries).to match_array(expected_countries)

      website = Website.find_by(domain: domain)
      expect(website.num_external_links).to eq(3)
      expect(website.num_internal_links).to eq(2)
    end

    context 'an unhandled exception is thrown' do
      context 'failure in creating a domain country' do
        it 'logs the error, re-raises, and keeps old data' do
          create_domain_countries(domain)
          Website.create!(domain: domain, num_external_links: 5, num_internal_links: 6)

          WebMock.stub_request(:get, domain_usage_url).
            and_return(status: 200, body: example_usage_of_domain_html)
          WebMock.stub_request(:get, "http://#{domain}/").
            and_return(status: 200, body: example_domain_html)

          expect(DomainCountry).to receive(:create!) {raise ActiveRecord::ActiveRecordError.new}
          expect_any_instance_of(Logger).to receive(:fatal)

          expect{subject.perform(domain)}.to raise_error(ActiveRecord::ActiveRecordError)

          countries = DomainCountry.where(domain: domain).pluck(:country)
          expect(countries).to match_array(['country1', 'country2', 'country3', 'country4', 'country5'])

          website = Website.find_by(domain: domain)
          expect(website.num_external_links).to eq(5)
          expect(website.num_internal_links).to eq(6)
        end
      end
    end
  end

  context 'wesbite entry for the given domain DOES NOT exist' do
    it 'creates a new wesbite entry' do
      create_domain_countries('domain2')
      Website.create!(domain: 'domain2', num_external_links: 1, num_internal_links: 0)

      WebMock.stub_request(:get, domain_usage_url).
        and_return(status: 200, body: example_usage_of_domain_html)
      WebMock.stub_request(:get, "http://#{domain}/").
        and_return(status: 200, body: example_domain_html)

      expect{subject.perform(domain)}.to change{Website.count}.by(1)

      countries = DomainCountry.where(domain: domain).pluck(:country)
      expect(countries).to match_array(expected_countries)

      website = Website.find_by(domain: domain)
      expect(website.num_external_links).to eq(3)
      expect(website.num_internal_links).to eq(2)
    end

    context 'domain has scheme' do
      it 'parses domain correctly' do
        WebMock.stub_request(:get, domain_usage_url).
          and_return(status: 200, body: example_usage_of_domain_html)
        WebMock.stub_request(:get, "http://#{domain}/").
          and_return(status: 200, body: example_domain_html)

        expect{subject.perform(domain)}.to change{Website.count}.by(1)

        countries = DomainCountry.where(domain: domain).pluck(:country)
        expect(countries).to match_array(expected_countries)

        website = Website.find_by(domain: domain)
        expect(website.num_external_links).to eq(3)
        expect(website.num_internal_links).to eq(2)
      end
    end

    context 'domain does not have scheme' do
      it 'parses the domain correctly' do
        WebMock.stub_request(:get, domain_usage_url).
          and_return(status: 200, body: example_usage_of_domain_html)
        WebMock.stub_request(:get, "http://#{domain}/").
          and_return(status: 200, body: example_domain_html)

        expect{subject.perform("http://#{domain}/path/to/something")}.to change{Website.count}.by(1)

        countries = DomainCountry.where(domain: domain).pluck(:country)
        expect(countries).to match_array(expected_countries)

        website = Website.find_by(domain: domain)
        expect(website.num_external_links).to eq(3)
        expect(website.num_internal_links).to eq(2)
      end
    end
  end
end
