FROM ruby:2.3.1
RUN apt-get update -qq && apt-get install -y nodejs postgresql-client
RUN mkdir /site-usage-crawler
WORKDIR /site-usage-crawler
COPY Gemfile /site-usage-crawler/Gemfile
COPY Gemfile.lock /site-usage-crawler/Gemfile.lock
RUN bundle install
COPY . /site-usage-crawler

# Add a script to be executed every time the container starts.
COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
EXPOSE 3000

# Start the main process.
CMD ["rails", "server", "-b", "0.0.0.0"]
