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

First, create a customer ID.
Then register to any number of subscriptions.
For automated renewal of subscriptions, run the appropriate script once a day.

### Create a customer account

This endpoint will create a customer account's id for you, along with a secret `bearer_token` that you will use for
authentication during other requests.

```shell
# Valid request:
curl -X POST \
  -H "Content-Type: application/json" \
  http://localhost:3000/customers

# Response:
# HTTP Status: 201 Created
{"customer":{"id":"d9fcbdca-94bf-4e7a-89e3-18d5567dd1e5"},"bearer_token":"eyJh..."}
```

### Create a subscription

In `Authorization` header, send `bearer_token` assigned to your customer account.
For `plan`, you can choose: `bronze_box`, `silver_box` or `gold_box`.
Each of your subscriptions will have an individual shipping address and an individually assigned credit card.

```shell
# Valid request:
curl -X POST \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer eyJh..." \
  -d '{"shipping_address":{"line1":"Bilbo Baggins","line2":"Bag End, at the end of Bagshot Row","zip_code":"12345","city":"Hobbiton"}, "credit_card":{"numer":"4242424242424242","expiration_month":"06","expiration_year":"2021","cvv":"123","zip_code":"12345"}, "plan":"bronze_box"}' \
  http://localhost:3000/subscriptions

# Response:
# HTTP Status: 201 Created
{"subscription":{"id":4,"customer_id":"d9fcbdca-94bf-4e7a-89e3-18d5567dd1e5","expires_on":"2019-04-30"}}
```

```shell
# Invalid request:
curl -X POST \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer eyJh..." \
  -d '{"shipping_address":{"line1":"Bilbo Baggins","line2":"Bag End, at the end of Bagshot Row","zip_code":"12345","city":"Hobbiton"}, "credit_card":{"numer":"4242424242424242","expiration_month":"06","expiration_year":"2021","cvv":"123"}}' \
  http://localhost:3000/subscriptions

# Response:
# HTTP Status: 400 Bad Request
{"errors":{"credit_card":{"zip_code":["is missing"]},"plan":["is missing"]}}
```

```shell
# Sample response in case of problems with the payment:
# HTTP Status: 400 Bad Request
{"errors":{"payment":"CVV failure"}}
```

```shell
# Response in case of the network problem between the app and Fakepay (check the details of the error in the logs):
# HTTP Status: 500 Internal Server Error
{"errors":{"internal":"Something went wrong!"}}
```

```shell
# Response in case of missing or invalid bearer_token:
# HTTP Status: 403 Forbidden
{"errors":{"authorization":"Invalid or blank bearer token!"}}
```

### Renew subscriptions

```shell
# Renew any subscriptions that should be billed on 30 Apr 2019
bin/rake verbose subscriptions:renew[2019,4,30]
```

Sample output:

```
Running via Spring preloader in process 31268
I, [2019-03-30T11:08:50.337220 #31268]  INFO -- : Renewing subscriptions on 2019-04-30...
I, [2019-03-30T11:08:51.449959 #31268]  INFO -- : Subscription #4 has been renewed successfully on 2019-04-30.
W, [2019-03-30T11:08:51.450431 #31268]  WARN -- : Payment for subscription #5 failed on 2019-04-30.
I, [2019-03-30T11:08:51.450881 #31268]  INFO -- : Done.
```

For subscriptions that are assigned to a bill date on the last day of the month, if the day does not exist for the next
bill date, the engine will use the last day of the month (e.g. for January 31st, next bill date will be February 28th).
