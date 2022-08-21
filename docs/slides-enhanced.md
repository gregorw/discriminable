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

We’re a team of four Ruby on Rails developers rethinking and migrating a legacy ERP system.

Franco Sebregondi
Aleixis Reigel
Yves Senn
Gregor Wassmann


<!-- slide -->

Please find slides and source code on
[github.com/gregorw/discriminable](https://github.com/gregorw/discriminable)

<!-- slide -->

# Discriminable

[github.com/gregorw/discriminable](https://github.com/gregorw/discriminable)

The why and how of STI

Bonus: Experience creating a gem.


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

## Pros

- Useable with existing data (model)
- More flexibility
- Support for multiple values
- Refactor class names without the need for a data migration (loose coupling)

<!-- slide -->

There is no right or wrong.
Be pragmatic.

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
