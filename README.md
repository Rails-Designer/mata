# Mata

Live Reload with DOM Morphing for Rack applications using Server-Sent Events.


**Sponsored By [Rails Designer](https://railsdesigner.com/)**

<a href="https://railsdesigner.com/" target="_blank">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/Rails-Designer/mata/HEAD/.github/logo-dark.svg">
    <source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/Rails-Designer/mata/HEAD/.github/logo-light.svg">
    <img alt="Rails Designer" src="https://raw.githubusercontent.com/Rails-Designer/mata/HEAD/.github/logo-light.svg" width="240" style="max-width: 100%;">
  </picture>
</a>


## Installation

```ruby
bundle add mata --group=development
```

## Usage

### Rails

```ruby
# config/environments/development.rb
config.middleware.insert_before(
  ActionDispatch::Static,
  Mata,
  watch: %w[app/views app/assets],
  skip: %w[app/assets/build]
)
```


### Other rack-based apps

```ruby
# config.ru
require "mata"

use Mata, watch: %w[views assets], skip: %w[views/tmp]

run YourApp
```

> [!NOTE]
> Do share your snippets on how to add Mata into your specific Rack-based apps 💙


## Used in

This gem powers live reloading in [Perron](https://github.com/rails-designer/perron), a Rails-based static site generator. It can be enabled with `config.live_reload = true` in your Perron initializer.


## Why this gem?

I needed a way to reload pages for Perron-powered Rails applications. These are minimal Rails apps typically without Hotwire or ActionCable dependencies. Existing solutions either required ActionCable or provided only basic full-page reloads without state preservation.


## Who is Mata?

In the smoky cabarets of Belle Époque Paris, a dancer captivated audiences with her exotic performances and mysterious allure. Born Margaretha Geertruida Zelle in the Netherlands, she had reinvented herself as an Indonesian princess, weaving tales of sacred temple dances and Eastern mystique.

She moved through the salons of Europe's elite with remarkable ease, speaking multiple languages and charming diplomats, military officers and aristocrats alike. Her lovers included high-ranking officials from opposing sides of the Great War, giving her access to secrets that others could only dream of obtaining.

Whether she was truly the master spy of legend or simply a woman caught in the wrong place at the wrong time remains a mystery. What's certain is her ability to observe, adapt and operate seamlessly across boundaries that others found impermeable.

History remembers **Mata Hari** as the ultimate double agent. She was someone who could watch, listen and report back with precision, all while maintaining perfect cover.


## Contributing

This project uses [Standard](https://github.com/testdouble/standard) for formatting Ruby code. Please make sure to run `be standardrb` before submitting pull requests. Run tests via `rails test`.


## License

Mata is released under the [MIT License](https://opensource.org/licenses/MIT).
