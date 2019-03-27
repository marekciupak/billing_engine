# Acme Online's billing engine

[![CircleCI](https://circleci.com/gh/marekciupak/billing_engine.svg?style=svg&circle-token=ffea6874d06720a1d659913a281b81967ad7dfb3)](https://circleci.com/gh/marekciupak/billing_engine)

Internal API that handles billing for subscriptions to a "box of the month" service offered by Acme Online.

## Development

### Requirements

* Ruby 2.6.2
* PostgreSQL

### :zap: Getting started

1. Install dependencies listed in the [requirements section](#requirements). Sample instruction for macOS and RVM users:

    ```shell
    rvm install 2.6.2 && rvm use 2.6.2
    brew install postgresql && brew services start postgresql
    ```

2. Clone the repository and change the directory:

    ```shell
    git clone git@github.com:marekciupak/billing_engine.git && cd billing_engine
    ```

3. Setup the application and the database:

    ```shell
    bin/setup
    ```

#### Running tests and linters

```shell
bin/rails test
bin/bundle exec rubocop
bin/bundle exec bundle-audit check --update
bin/bundle exec brakeman -q --summary
```

#### Running the app

```shell
bin/rails server
```
