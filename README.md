# HanamiId

Authentication solution for [Hanami](https://github.com/hanami/hanami) framework. Based on [Warden](https://github.com/wardencommunity/warden) and [Bcrypt](https://github.com/codahale/bcrypt-ruby).

HanamiId tries to be a plug-n-play solution like Devise is for Rails. But 
instead of magic intervention, it generates a separate app with controllers, views, templates full of working code that you can easily change to your liking.  
HanamiId doesn't monkey patch anything, doesn't mess with your app configuration 
and acts completely isolated.


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

Add these lines to your application's Gemfile:

```ruby
gem "hanami_id"

group :plugins do
  gem "hanami_id-generators"
end
```

And then execute:

    $ bundle

Run generator:

    $ hanami g auth --app auth --model user --modules=sessions,registrations --mode project


Use `--help` to see all available options and defaults. They are:

- --app
- --model
- --modules
- --locale
- --id_type
- --login_column
- --password_column

The above command is using Hanami CLI under the hood and will generate an 
application with all controller actions, views, templates in `apps` folder. As well as entity, repository and interactors in `lib` fodler. All relevant specs are coming soon (RSpec, Capybara).

All available modules are:

- sessions
- registrations
- passwords
- confirmations
- unlocks

Currently working modules are *sessions* and *registrations* only. Other modules' files are generated but functionality is either not implemented or not supported by mailers (mailing is to be added very soon).

During generation, when `project` mode is used, the authentication helpers, I18n and Warden are instlled project-wide in `/config/environment.rb`. When `standalone` mode is used, they are installed only inside the authentication app e.g. `apps/auth/application.rb`.   If you need to add authentication to selected few apps, you can do it manually. Automatic handling of selected option is in coming soon.


## Usage

The gem provides several helpers:
 - `authenticate_<model>!`
 - `authenticate_<model>`
 - `current_<model>`
 - `<model>_signed_in?`

Use `authenticate_<model>!` method to fail if authentications fails and `authenticate_<model>` to proceed to normal application workflow even if authentication fails.

`current_<model>` method is `nil` if no user is authenticated otherwise it represents the authenticated user.

Use `<model>_signed_in?` to check if user is authenticated.

In case of `standalone` installation, auth app will be completely isolated and HanamiId will not be injected in other apps code. For authenication usage in a specific app add Warden Rack middleware to that app:
```ruby
# apps/web/application.rb
module Web
  class Application < Hanami::Application
    configure do
      # ...
      sessions :cookie, secret: ENV["WEB_SESSIONS_SECRET"]
      include HanamiId::Warden::AppHelper
    end
  end
end
```

To use authentication in all controller actions of an app do:
```ruby
# apps/web/application.rb
module Auth
  class Application < Hanami::Application
    configure do
      controller.prepare do
        before :authenticate_user!
      end
    end
  end
end
```    

To force authentication inside a controller action use:
```ruby
# apps/web/controllers/dashboard/show.rb
module Web
  module Controllers
    module Dashboard
      class Show
        before :authenticate_user!

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
