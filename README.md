# Dislogger

[![Gem Version](https://badge.fury.io/rb/dislogger.svg)](https://badge.fury.io/rb/dislogger)
[![Coverage Status](https://coveralls.io/repos/github/nduartex/dislogger/badge.png?branch=master)](https://coveralls.io/github/nduartex/dislogger?branch=master)

A Ruby on Rails gem for elegant error handling and Discord notifications. Automatically capture and notify errors through Discord webhooks while maintaining clean error responses for your API.

## Features

- 🚨 Automatic error handling for Rails applications (both API and regular apps)
- 🎯 Discord notifications for errors with customizable formatting
- 📝 Detailed error information including backtrace
- 🎨 Customizable error colors for different status codes
- 🔧 Environment-based configuration
- 🛡️ Built-in support for common Rails exceptions
- ⚡ Works with both `ActionController::API` and `ActionController::Base`

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'dislogger'
```

And then execute:

```bash
$ bundle install
```

Or install it yourself as:

```bash
$ gem install dislogger
```

## Configuration

### Quick Start

After installing the gem, run the generator to create the configuration file:

```bash
$ rails generate dislogger:install
```

This will create an initializer at `config/initializers/dislogger.rb` with all available configuration options and their documentation.

### Setting up Discord Webhook

Before configuring the gem, you need to set up a webhook in your Discord server:

1. Open your Discord server
2. Right-click on the channel where you want to receive error notifications
3. Select "Edit Channel"
4. Click on "Integrations"
5. Click on "Create Webhook"
6. Give your webhook a name (e.g., "Error Logger")
7. Click "Copy Webhook URL" - This is the URL you'll need for configuration
8. Click "Save"

For security, it's recommended to store the webhook URL in your environment variables:

```ruby
# config/initializers/dislogger.rb
Dislogger.configure do |config|
  config.discord_webhook_url = ENV['DISCORD_WEBHOOK_URL']
  # ... rest of your configuration
end
```

Then add the webhook URL to your environment:

```bash
# .env
DISCORD_WEBHOOK_URL=https://discord.com/api/webhooks/your-webhook-url
```

Make sure to add `.env` to your `.gitignore` file to keep your webhook URL secure.

### Configuration Options

The generator will create an initializer with all available options:

```ruby
Dislogger.configure do |config|
  # Required: Your Discord webhook URL (preferably from environment variables)
  config.discord_webhook_url = ENV['DISCORD_WEBHOOK_URL']

  # Required: Current environment (defaults to Rails.env if available)
  config.environment = Rails.env

  # Optional: Custom bot username (default: 'Error Logger')
  config.bot_username = 'My App Error Logger'

  # Optional: Number of backtrace lines to include (default: 5)
  config.backtrace_lines_limit = 10

  # Optional: Environments where notifications are enabled (default: ['production', 'staging', 'development'])
  config.enabled_environments = ['production', 'staging', 'development']

  # Optional: Custom error colors (default values shown below)
  config.error_color_map = {
    500 => 15158332, # Red
    404 => 3447003,  # Blue
    422 => 16776960, # Yellow
    403 => 15105570, # Orange
    default: 10181046 # Gray
  }
end
```

## Usage

### Basic Setup

The gem automatically includes error handling in your Rails controllers. No additional setup is required!

```ruby
# For API applications
class ApplicationController < ActionController::API
  # Error handling is automatically included
end

# For regular Rails applications
class ApplicationController < ActionController::Base
  # Error handling is automatically included
end
```

### Handled Exceptions

The gem automatically handles the following exceptions:

- `ActiveRecord::RecordNotFound` (404)
- `ActiveRecord::RecordInvalid` (422)
- `ActionController::ParameterMissing` (422)
- `Pundit::NotAuthorizedError` (403)
- `CanCan::AccessDenied` (403)
- `StandardError` (500)

### JSON Response Format

Errors are automatically rendered as JSON with a consistent format:

```json
{
  "status": "not_found",
  "message": "Record not found",
  "details": ["Additional error details if available"]
}
```

### Discord Notifications

When an error occurs, a Discord notification will be sent with:

- Error title and status code
- Environment information
- Error message
- Backtrace (configurable number of lines)
- Custom color based on error type

### Manual Error Handling

You can also manually use the error handler in your controllers:

```ruby
class CustomController < ApplicationController
  def some_action
    # Your code here
  rescue SomeError => e
    notify_and_render_error(
      message: 'Custom error message',
      status: :unprocessable_entity,
      details: ['Additional details'],
      backtrace: e.backtrace
    )
  end
end
```

## Development

After checking out the repo, run:

```bash
$ bundle install
```

To run the tests:

```bash
$ bundle exec rspec
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b feature/my-new-feature`)
3. Add tests for your changes
4. Make your changes
5. Run the tests (`bundle exec rspec`)
6. Commit your changes (`git commit -am 'Add some feature'`)
7. Push to the branch (`git push origin feature/my-new-feature`)
8. Create a new Pull Request

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Dislogger project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](CODE_OF_CONDUCT.md).