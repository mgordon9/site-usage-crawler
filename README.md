# Site Usage Crawler

This Ruby on Rails app crawls a given domain for the number of external and internal links. It also crawls the website 'https://www.alexa.com/siteinfo/' for the top 5 countries that use that website. These two tasks utilize sidekiq for paralelism and aasymcrony. The UI will allow you to view this information for a given domain and start a background process to retrieve that information.

## Getting Started
### Prerequisites

This app require docker and docker compose to set up locally. Directions to install both can be found here https://github.com/Yelp/docker-compose/blob/master/docs/install.md


### Installing

build and start the application

```sh
docker-compose up --build -d
```

Output should end with something like this:
```
...
Successfully built d698977e022a
Successfully tagged site-usage-crawler_sidekiq:latest
Creating site-usage-crawler_redis_1 ... done
Creating site-usage-crawler_db_1    ... done
Creating site-usage-crawler_sidekiq_1 ... done
Creating site-usage-crawler_web_1     ... done
```

### Access rails console
```sh
docker-compose exec web rails console
```

### Run tests
```sh
docker-compose exec web rspec
```

### Stop the server
```sh
docker-compose down
```

## Built With

* [Ruby on Rails](https://github.com/rails/rails) - The web framework used
* [Sidekiq](https://github.com/mperham/sidekiq) - Background job framework
