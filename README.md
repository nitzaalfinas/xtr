# xtr

xtr is a trading engine.

At the moment, xtr only supports LMT orders and everything is stored in
the memory, and not persisted.

## Concepts

**Engine** is the core of the trading system. Engine is responsible for executing
user operations and queries.

**Instrument** is a tradeable asset. It can be stock or currency.

xtr identifies instruments simply by their codes.

**Market** is a place where one kind of asset is traded for another.
For example, a place where you can trade EUR for CNY or AAPL for USD is
a market.

There are two ways xtr identifies markets. If the market is
currency-to-currency, it's identified by a currency pair (BTC/USD,
BTC/EUR). If the market is for stocks, it is identified by a stock ticker
prepended with currency code (USD:AAPL, EUR:GOOG, CNY:TWTR, BTC:V).

**Account** is a collection of balances in different instruments. It is
identified by a UUID string returned from the `CREATE_ACCONT` command.

## Getting started

To get started, you would need to instantiate an engine and pass it the list of
instruments you want it to support. Instruments are broken down by
category. At the moment, xtr supports currency and stock instruments.

```ruby
engine = Xtr::Engine.new({
  currency: [:BTC, :USD, :EUR],
  stock: [:AAPL, :GOOG, :TWTR, :V]
})
```

Engine will then create *markets* for described instruments. By default,
it will create a market for each pair of currencies and a market for
each stock in every supported currency.

In this example, the following markets will be generated:

* currency
  * BTC/USD
  * BTC/EUR
  * USD/EUR

* stock
  * BTC:AAPL
  * USD:AAPL
  * EUR:AAPL
  * BTC:GOOG
  * USD:GOOG
  * EUR:GOOG
  * BTC:TWTR
  * USD:TWTR
  * EUR:TWTR
  * BTC:V
  * USD:V
  * EUR:V

### Accounts

To create an account, just call:

```ruby
account = engine.execute :CREATE_ACCOUNT
```

It will return account ID.

#### Balance management

Crediting and debiting account balances is easy:

```ruby
# Crediting
engine.execute :DEPOSIT, account, "USD", 100_000.00
engine.query :BALANCE, account, "USD"
# => { currency: USD, available: 100_000.00, reserved: 0.00 }

# Debiting
engine.execute :WITHDRAW, account, "USD", 25_000.00
engine.query :BALANCE, account, "USD"
# => { currency: USD, available: 75_000.00, reserved: 0.00 }
```

### Explore available markets

```ruby
engine.query :MARKETS
=> { currency: [BTC/USD, ...], stock: [USD:AAPL, USD:GOOG, ...] }
```

### Creating orders

Only LMT orders are supported currently.

```ruby
engine.execute :BUY, account, "BTC/USD", 999.99, 10
engine.execute :SELL, account, "EUR:AAPL", 600, 25
```

When the orders are matched, balance transfers are performed between the
accounts.

### Getting open orders

```ruby
engine.query :OPEN_ORDERS, account
# => [{
#       id: 'uuid',
#       market: 'BTC/USD',
#       direction: :buy,
#       price: 999.99,
#       quantity: 10,
#       remainder: 5,
#       status: :partially_filled,
#       created_at: Time
#    }]
```

### Canceling orders

```ruby
engine.execute :CANCEL, account, order
```

### Getting account balances

```ruby
engine.query :BALANCES, account
# => [{
#       instrument: 'AAPL',
#       available: 10,
#       reserved: 5
#    }]
```

### Querying tickers

```ruby
engine.query :TICKER, 'EUR:GOOG'
# => { bid: 499.90, ask: 500.30, last_price: 500.10 }
```

## TODO

* other order types (market, stop-loss, take-profit, fill-or-kill)
* margin trading
* derivative instruments (CFDs, futures, options)
* event sourcing & persistence
* snapshots
