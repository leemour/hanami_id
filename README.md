# HanamiId

Authentication solution for Hanami framework. Based on Warden and Bcrypt.

## Status

[![Build Status](https://travis-ci.org/leemour/hanami_id.svg?branch=master)](https://travis-ci.org/leemour/hanami_id)
[![Gem](https://img.shields.io/gem/v/hanami_id.svg?style=flat)](http://rubygems.org/gems/hanami_id "View this project in Rubygems")
[![Known Vulnerabilities](https://snyk.io/test/github/leemour/hanami_id/badge.svg?targetFile=Gemfile.lock)](https://snyk.io/test/github/leemour/hanami_id?targetFile=Gemfile.lock)
[![Depfu](https://badges.depfu.com/badges/49e1b40e2b5a6d6d7fd89e97531bb65a/count.svg)](https://depfu.com/github/leemour/hanami_id?project_id=7886)
[![Codacy Badge](https://api.codacy.com/project/badge/Grade/c05fdf7a87204e53b79cb4a77b44f41a)](https://www.codacy.com/app/leemour/hanami_id?utm_source=github.com&amp;utm_medium=referral&amp;utm_content=leemour/hanami_id&amp;utm_campaign=Badge_Grade)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Test Coverage](https://api.codeclimate.com/v1/badges/c4c03486c0bf75b6fb44/test_coverage)](https://codeclimate.com/github/leemour/hanami_id/test_coverage)
[![Maintainability](https://api.codeclimate.com/v1/badges/c4c03486c0bf75b6fb44/maintainability)](https://codeclimate.com/github/leemour/hanami_id/maintainability)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'hanami_id'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install hanami_id

Run generator:

    $ hanami g auth --app auth --model user

This will generate an application with all controller actions, entity, 
repository and allrelevant tests.

## Usage

Add Warden Rack middleware to your project:
```ruby
# config/environment.rb
Hanami.configure do
  # ...
  use Rack::Session::Cookie, secret: "replace this with some secret key"

  middleware.use Warden::Manager do |manager|
    manager.default_strategies :password
    manager.failure_app = lambda do |env|
      Web::Controllers::Session::New.new(
        login_failed_with: env["warden"].message
      ).call(env)
    end
  end
end
```

Add Warden Rack middleware to a particular app:
```ruby
# apps/web/application.rb
module Web
  class Application < Hanami::Application
    configure do
      # ...
      sessions :cookie, secret: ENV['WEB_SESSIONS_SECRET']

      middleware.use Warden::Manager do |manager|
        manager.default_strategies :password
        manager.failure_app = lambda do |env|
          Web::Controllers::Session::New.new(
            login_failed_with: env["warden"].message
          ).call(env)
        end
      end
    end
  end
end
```

Add Warden Rack middleware to a controller action:
```ruby
# apps/web/controllers/dashboard/show.rb
module Web
  module Controllers
    module Dashboard
      class Show
        include Web::Action

        use Warden::Manager do |manager|
          manager.default_strategies :password
          manager.failure_app = lambda do |env|
            Web::Controllers::Session::New.new(
              login_failed_with: env["warden"].message
            ).call(env)
          end
        end

        def call(params)
          # ...
        end
      end
    end
  end
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/leemour/hanami_id. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## Code of Conduct

Everyone interacting in the HanamiId project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/leemour/hanami_id/CODE_OF_CONDUCT.md).
