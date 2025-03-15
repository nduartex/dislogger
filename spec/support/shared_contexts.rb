# frozen_string_literal: true

RSpec.shared_context 'with configuration' do
  let(:webhook_url) { 'https://discord.com/api/webhooks/123/abc' }
  let(:config) do
    Dislogger::Configuration.new.tap do |c|
      c.discord_webhook_url = webhook_url
      c.environment = 'test'
      c.bot_username = 'Test Bot'
      c.enabled_environments = ['test']
    end
  end
end

RSpec.shared_context 'with error data' do
  let(:message) { 'Test error message' }
  let(:status) { 500 }
  let(:backtrace) { ['line1', 'line2', 'line3'] }
end 