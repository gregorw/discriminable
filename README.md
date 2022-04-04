[![Ruby](https://github.com/gregorw/discriminable/actions/workflows/main.yml/badge.svg)](https://github.com/gregorw/discriminable/actions/workflows/main.yml)

# Discriminable

Single table inheritance (STI) for Ruby on Rails models (ActiveRecord) using enum, boolean, string and integer column types.


## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add discriminable

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install discriminable

## Usage

```ruby
ActiveRecord::Schema.define do
  create_table :orders do |t|
    t.integer :state, limit: 1, default: 0
  end
end

class Order < ActiveRecord::Base
  include Discriminable

  enum state: { open: 0, completed: 1 }
  discriminable state: { open: "Cart" }
end

class Cart < Order
end

Order.completed.create
=> #<Order id: 3, state: "completed">
Cart.create
=> #<Cart id: 1, state: "open">
Order.all
=> #<ActiveRecord::Relation [#<Order id: 1, state: "completed">, #<Cart id: 2, state: "open">]>```


## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/gregorw/discriminable. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/gregorw/discriminable/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Discriminable project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/gregorw/discriminable/blob/main/CODE_OF_CONDUCT.md).
