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

## API

### Create a subscription

For id of the `plan`, you can choose: `bronze_box`, `silver_box` or `gold_box`.

```shell
# Valid request:
curl -X POST \
  -H "Content-Type: application/json" \
  -d '{"shipping_address":{"line1":"Bilbo Baggins","line2":"Bag End, at the end of Bagshot Row","zip_code":"12345","city":"Hobbiton"}, "credit_card":{"numer":"4242424242424242","expiration_month":"06","expiration_year":"2021","cvv":"123","zip_code":"12345"}, "plan":"bronze_box"}' \
  http://localhost:3000/subscriptions

# Response:
# HTTP Status: 201 Created
```

```shell
# Invalid request:
curl -X POST \
  -H "Content-Type: application/json" \
  -d '{"shipping_address":{"line1":"Bilbo Baggins","line2":"Bag End, at the end of Bagshot Row","zip_code":"12345","city":"Hobbiton"}, "credit_card":{"numer":"4242424242424242","expiration_month":"06","expiration_year":"2021","cvv":"123"}}' \
  http://localhost:3000/subscriptions

# Response:
# HTTP Status: 400 Bad Request
{"errors":{"credit_card":{"zip_code":["is missing"]},"plan":["is missing"]}}
```

```shell
# Response in case of the network problem between the app and Fakepay (check the details of the error in the logs):
# HTTP Status: 500 Internal Server Error
{"errors":{"internal":"Something went wrong!"}}
```

### Renew subscriptions

```shell
# Renew any subscriptions that should be billed on 30 Jan 2019
bin/rake verbose subscriptions:renew[2019,1,30]
```

For subscriptions that are assigned to a bill date on the last day of the month, if the day does not exist for the next
bill date, the engine will use the last day of the month (e.g. for January 31st, next bill date will be February 28th).
