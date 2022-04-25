

# Discriminable

[![Gem Version](https://badge.fury.io/rb/discriminable.svg)](https://rubygems.org/gems/discriminable)
[![CI](https://github.com/gregorw/discriminable/actions/workflows/main.yml/badge.svg?event=push)](https://github.com/gregorw/discriminable/actions/workflows/main.yml)
[![Maintainability](https://api.codeclimate.com/v1/badges/94041c5f946b64040368/maintainability)](https://codeclimate.com/github/gregorw/discriminable/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/94041c5f946b64040368/test_coverage)](https://codeclimate.com/github/gregorw/discriminable/test_coverage)

Single table inheritance (STI) for Ruby on Rails models (ActiveRecord) using enum, boolean, string and integer column types.

In other words, use any (existing?) model attribute to discriminate between different classes in your class hierarchy. This makes storing class names in a `type` column redundant.

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add discriminable

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install discriminable

## Usage

```ruby
class Order < ActiveRecord::Base
  include Discriminable

  enum state: { open: 0, completed: 1 }

  discriminable_by :state
end

class Cart < Order
  discriminable_as :open
end

Cart.create
# => #<Cart id: 1, state: "open">
Order.all
# => #<ActiveRecord::Relation [#<Cart id: 1, state: "open">]>
```

## Features

## Aliased attributes

In case you are working with a legacy database and cannot change the column name easily it’s easy to reference an aliased attribute in the `discriminable_by` definition.

```ruby
class Property < ActiveRecord::Base
  include Discriminable

  alias_attribute :kind, :kind_with_legacy_postfix

  # Aliased attributes are supported when specifying the discriminable attribute
  discriminable_by :kind
end

class NumberProperty < Property
  discriminable_as 1
end
```

### Multiple values

Sometimes, in a real project, you may want to map a number of values to a single class. This is possible by specifying:

```ruby
class OptionProperty < Property
  # The first mention becomes the default value
  discriminable_as 2, 3, 4
end
```

Note that when creating new records with e.g. `OptionPropert.create` a _default_ value needs to be set in the database for this discriminable class. The Discriminable gem uses the _first_ value in the list as the default value.
## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/gregorw/discriminable. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/gregorw/discriminable/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Discriminable project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/gregorw/discriminable/blob/main/CODE_OF_CONDUCT.md).

## Related Work

The idea for this Gem was influenced by [“Bye Bye STI, Hello Discriminable Model”](https://www.salsify.com/blog/engineering/bye-bye-sti-hello-discriminable-model) by Randy Burkes. This Gem has started out with [his code](https://gist.github.com/rlburkes/798e186acb2f93e787a5).

See also:

- Rails [single table inheritance](https://api.rubyonrails.org/classes/ActiveRecord/Inheritance.html) and [DelegatedType](https://api.rubyonrails.org/classes/ActiveRecord/DelegatedType.html)
- Java [JPA discrimanator](https://openjpa.apache.org/builds/1.0.2/apache-openjpa-1.0.2/docs/manual/jpa_overview_mapping_discrim.html)
- Python [model inheritance](https://docs.djangoproject.com/en/4.0/topics/db/models/#model-inheritance-1)
- [Discriminator](https://github.com/gdpelican/discriminator) gem.
