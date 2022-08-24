---
presentation:
  # presentation theme
  # === available themes ===
  # "beige.css"
  # "black.css"
  # "blood.css"
  # "league.css"
  # "moon.css"
  # "night.css"
  # "serif.css"
  # "simple.css"
  # "sky.css"
  # "solarized.css"
  # "white.css"
  # "none.css"
  theme: black.css
---

<!-- slide -->

# Rails Meetup 2022

Hoelzle AG
Gregor Wassmann

<!-- slide -->

![bg](https://assets.hoelzle.ch/image/upload/ar_16:9,c_lfill,dpr_2.0,f_auto,g_custom:face,w_450/iStock-1069742886)

<!-- slide -->

![bg](https://assets.hoelzle.ch/image/upload/ar_16:9,c_lfill,dpr_2.0,f_auto,w_450/iStock-1030386752)

<!-- slide -->

![bg](https://assets.hoelzle.ch/image/upload/c_limit,dpr_auto,f_auto,q_auto:eco,w_1200/v1585066206/Depositphotos_43697107_original)


<!-- slide -->

![image](./h-logo-white.png)

<!-- slide -->

We’re a team of four Ruby on Rails developers rethinking and migrating a legacy ERP system.


<!-- slide -->

Please find slides and source code on
[github.com/gregorw/discriminable/tree/demo](https://github.com/gregorw/discriminable/tree/demo)


<!-- slide -->

# Discriminable

[github.com/gregorw/discriminable](https://github.com/gregorw/discriminable)

More powerful STI

<!-- slide -->

**Single-table inheritance** means using different classes for the same database table.

A **discriminator** figures out the class from a record based on some attribute value.

<!-- slide -->

```dot
digraph g1 {
  bgcolor = transparent
  fontcolor=white
  fontname=helvetica
  fontsize=30
  nodesep=.6
  rankdir=BT

  node [
    fontname=helvetica,
    fontsize=30,
    shape=box,
    color=white,
    fontcolor=white
    margin=".3,.1"
  ];

  edge [
    color=white,
  ];

  subgraph cluster_db {
    fontcolor=white
    bgcolor=black

    DB [label=" " shape=cylinder]
    DB -> properties
  }

  Property
  properties -> Option, Value, Range

  edge[arrowhead=empty]
  Option -> Property
  Value -> Property
  Range -> Property
}
```

<!-- slide -->

# Motivation

<!-- slide -->

![bg](./filters2.png)

<!-- slide -->

## A

```ruby
class Order
  enum state: { open: 1, completed: 2 }
end
```

## B

```ruby
class Cart < Order
end
```

<!-- slide -->

![bg](pr.png)

<!-- slide -->


```ruby
class Property < ApplicationRecord
  include Discriminable

  discriminable_attribute :kind
end

class Property::Number < Property
  discriminable_value 1
end

class Property::Option < Property
  discriminable_values 2, 3, 4 # The first mention becomes the default value
end
```

<!-- slide -->

## Benefits of separate classes

- Separation of concerns / adhere to **single responsibility principle**
- Use separate partials using Rails naming convention
- Option for separate controllers
- **Open-closed principle**: Add more types without modifing the existing class
- Overall better code quality, extensibility and maintainability
- **Less database queries** required


<!-- slide -->

## Rails STI

| *value* | string | integer | boolean | enum | … |
|--|--|--|--|--|--|
| single | 🟡 `class.name` only | 🔴 |  🔴 |  🔴 |  🔴 |
| multiple | 🔴 | 🔴 |  🔴 |  🔴 |  🔴 |

<!-- slide -->

## Discriminable Gem

| *value* | string | integer | boolean | enum | … |
|--|--|--|--|--|--|
| single | 🟢 | 🟢 |  🟢 |  🟢 |  🟢 |
| multiple | 🟢 | 🟢 |  🟢 |  🟢 |  🟢 |

<!-- slide -->

## Why discriminable?

- Useable with existing data (model)
- More flexibility
- Support for multiple values
- Refactor class names without the need for a data migration (loose coupling)
- 70 lines of code

<!-- slide -->

![bg](./discriminable2.png)


<!-- slide -->

## Experience of writing a Gem

- Great ecosystem (Rubygems, Bundler, Github Actions, etc.)
- Learning happens outside your comfort zone (Minitest, Github Matrix, Rails source code)
- Rails can (and should) learn from Java and Python, too

<!-- slide -->

## Hash memoization

```ruby
Hash.new do |map, value|
  map[value] = value.constantize._discriminable_values&.first
end
```

<!-- slide -->

I hope `discriminable` will be useful to *you*.

<!-- slide -->

Questions?

<!-- slide -->

Thanks

<!-- slide -->

# Agenda

- Data Modelling
- Rails STI
- Limitations
- Related work / Java
- How to release a gem?

<!-- slide -->

# Data Modeling

<!-- slide -->

## ORM

```dot
digraph g1 {
  bgcolor = transparent
  color=white
  fontcolor=white
  fontname=helvetica
  fontsize=30

  node [
    fontname=helvetica,
    fontsize=30,
    shape=box,
    color=white,
    fontcolor=white
    margin=".6,.3"
  ];

  edge [
    color=white,
  ];

  subgraph cluster_db {
    color=white
    fontcolor=white
    margin=".6,.3"
    pad=1

    DB [label=" " shape=cylinder]
    customers
    products
  }
  Customer -> customers -> DB
  Product -> products -> DB
}
```

<!-- slide -->

## Multitable inheritence MTI

```dot
digraph g1 {
  bgcolor = transparent
  fontcolor=white
  fontname=helvetica
  fontsize=30
  nodesep=.5

  node [
    fontname=helvetica,
    fontsize=30,
    shape=box,
    color=white,
    fontcolor=white
    margin=".3,.1"
  ];

  edge [
    color=white,
  ];

  subgraph cluster_db {
    fontcolor=white
    margin=".6,.3"
    bgcolor=marine

    DB [label=" " shape=cylinder]
    events, orders, interactions -> DB
  }

  Event [shape=record label="{Event | date}"]
  Event -> events
  edge[arrowhead=empty]
  Order [shape=record label="{Order | price}"]
  Interaction [shape=record label="{Interaction | note}"]
  Interaction -> Event
  Interaction -> interactions
  Order -> Event
  Order -> orders
}
```

<!-- slide -->

## Multitable inheritence MTI2

```dot
digraph g1 {
  bgcolor = transparent
  fontcolor=white
  fontname=helvetica
  fontsize=30
  nodesep=.5
  rankdir=BT

  node [
    fontname=helvetica,
    fontsize=30,
    shape=box,
    color=white,
    fontcolor=white
    margin=".3,.1"
  ];

  edge [
    color=white,
  ];

  subgraph cluster_db {
    fontcolor=white
    margin=".6,.3"
    bgcolor=marine

    DB [label=" " shape=cylinder]
    DB -> events, orders, interactions
  }

  Event [shape=record label="{Event | date}"]
  events -> Event
  interactions -> Interaction
  orders -> Order

  edge[arrowhead=empty]
  Order [shape=record label="{Order | price}"]
  Interaction [shape=record label="{Interaction | note}"]
  Interaction -> Event

  Order -> Event
}
```