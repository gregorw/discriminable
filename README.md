

# Discriminable

[![Gem Version](https://badge.fury.io/rb/discriminable.svg)](https://rubygems.org/gems/discriminable)
[![CI](https://github.com/gregorw/discriminable/actions/workflows/main.yml/badge.svg)](https://github.com/gregorw/discriminable/actions/workflows/main.yml)
[![Maintainability](https://api.codeclimate.com/v1/badges/94041c5f946b64040368/maintainability)](https://codeclimate.com/github/gregorw/discriminable/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/94041c5f946b64040368/test_coverage)](https://codeclimate.com/github/gregorw/discriminable/test_coverage)

Single table inheritance (STI) for Ruby on Rails models (ActiveRecord) using enum, boolean, string and integer column types.

In other words, use any _existing_ model attribute for STI instead of storing class names in a `type` column.

**Related work**

The idea was originally described in [“Bye Bye STI, Hello Discriminable Model”](https://www.salsify.com/blog/engineering/bye-bye-sti-hello-discriminable-model) by Randy Burkes and this Gem has started out with [his code](https://gist.github.com/rlburkes/798e186acb2f93e787a5).


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

Cart.create
=> #<Cart id: 1, state: "open">
Order.all
=> #<ActiveRecord::Relation [#<Cart id: 1, state: "open">]>
```


## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/gregorw/discriminable. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/gregorw/discriminable/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Discriminable project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/gregorw/discriminable/blob/main/CODE_OF_CONDUCT.md).
