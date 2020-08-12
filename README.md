# 🥐 croissant

Tagging for policy friends across government.

### Browser Support

This tool is built for government agencies to use, and as such needs to be a
little bit more expansive in its browser support.

| **Browser**            | **Supported Versions** |
| ---------------------- | ---------------------- |
| Internet Explorer      | 11+                    |
| Edge                   | 17+                    |
| Safari                 | Latest -2              |
| Chrome                 | Latest -4              |
| Firefox                | Latest -2              |
| iOS Safari             | Latest -2              |
| Chrome for Android     | Latest -2              |
| UC Browser for Android | Latest -2              |
| Samsung Internet       | Latest -2              |

## Project Resources:

| **Resource**        | **URL**                                                                                      |
| ------------------- | -------------------------------------------------------------------------------------------- |
| Backlog URL         | [Trello](https://trello.com/b/76mWPkzx/croissant-papa-korero)                                |
| CI URL              | [Travis](https://travis-ci.org/ServiceInnovationLab/croissant/)                              |
| Google Drive folder | [Google Drive](https://drive.google.com/drive/u/0/folders/1HzhqcG_frJknxaQJYjUIllmMGyS7K3mc) |

## People Involved

| **Role(s)**   | **Name(s)**            |
| ------------- | ---------------------- |
| Tech Lead     | Merrin Macleod         |
| Developers    | Dan Morrison           |
| Designer      | Ross Patel             |
| Scrum Master  | Felipe Bohorquez-Perry |
| Product Owner | Elias Wyber            |

## Comms:

The #croissant channel on the Service Innovation Lab Slack

### Dependencies

Before running this app and its tests locally you will need:

1. Ruby
1. PostgreSQL
1. Redis

### Running the app

1. Clone the project: `git@github.com:ServiceInnovationLab/croissant.git`
2. Run the setup script: `./bin/setup`

Then run the following commands:

```
# Terminal #1:
bundle exec rails s
```

```
# Terminal #2:
bundle exec sidekiq
```

### Running the tests

```
bundle exec rspec spec
npm run lighthouse-spec
```

## Docker

### Build the containers

```zsh
docker-compose
```

### Prime the database

Create a new `POSTGRES_PASSWORD` in `.env`, the first time the container is
started it will assign this password to the PostgreSQL database.

Add this same password in `database.yml`

### Run the setup script

```zsh
docker-compose run app bin/setup
```

### Whitelist yourself

```zsh
docker-compose up
```

Visit http://localhost:3000

Copy `config.hosts << "xxxxxx"` to `development.rb`


## Development with docker-compose

```zsh

docker-compose -f docker-compose-dev.yml build --build-arg DEPLOY=root
docker-compose -f docker-compose-dev.yml up
docker exec -ti croissant_app_1 bin/rake tmp:create
docker exec -ti croissant_app_1 bin/rake db:create
docker exec -ti croissant_app_1 bin/rake db:migrate
docker exec -ti croissant_app_1 bin/rake db:seed:dev
```

Visit http://localhost:3000
