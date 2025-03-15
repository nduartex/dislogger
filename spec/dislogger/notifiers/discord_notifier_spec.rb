# frozen_string_literal: true

RSpec.describe Dislogger::Notifiers::DiscordNotifier do
  include_context 'with configuration'

  subject(:notifier) { described_class.new(config) }

  let(:webhook_url) { 'https://discord.com/api/webhooks/123/abc' }
  let(:message) { 'Test error message' }
  let(:status) { 500 }
  let(:backtrace) { ['line 1', 'line 2'] }
  let(:current_time) { Time.utc(2024, 1, 1, 12, 0, 0) }

  before do
    config.discord_webhook_url = webhook_url
    config.environment = 'production'
    config.enabled_environments = ['production']
    config.bot_username = 'Error Logger'
    allow(Time).to receive(:current).and_return(current_time)
  end

  describe '#notify' do
    context 'when enabled and webhook_url is present' do
      let(:expected_body) do
        {
          username: 'Error Logger',
          embeds: [
            {
              title: 'Production - Error Notification (500)',
              description: message,
              color: 15158332,
              fields: [
                { name: 'Status Code', value: '500', inline: true },
                { name: 'Environment', value: 'production', inline: true },
                { name: 'Backtrace', value: "line 1\nline 2", inline: false }
              ],
              timestamp: '2024-01-01T12:00:00Z'
            }
          ]
        }
      end

      before do
        stub_request(:post, webhook_url)
          .with(
            body: expected_body,
            headers: {
              'Content-Type' => 'application/json',
              'Accept' => '*/*',
              'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
              'User-Agent' => 'Ruby'
            }
          )
          .to_return(status: 204)
      end

      it 'sends notification to Discord' do
        notifier.notify(message: message, status: status, backtrace: backtrace)
        expect(WebMock).to have_requested(:post, webhook_url)
          .with(
            body: expected_body,
            headers: {
              'Content-Type' => 'application/json',
              'Accept' => '*/*',
              'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
              'User-Agent' => 'Ruby'
            }
          )
      end
    end

    context 'when disabled' do
      before { config.environment = 'development' }

      it 'does not send notification' do
        notifier.notify(message: message, status: status)
        expect(WebMock).not_to have_requested(:post, webhook_url)
      end
    end

    context 'when webhook_url is nil' do
      before { config.discord_webhook_url = nil }

      it 'does not send notification' do
        notifier.notify(message: message, status: status)
        expect(WebMock).not_to have_requested(:post, webhook_url)
      end
    end

    context 'when request fails' do
      before do
        stub_request(:post, webhook_url).to_raise(StandardError.new('Network error'))
      end

      context 'when Rails is defined' do
        let(:logger) { double('Logger') }

        before do
          stub_const('Rails', Module.new)
          allow(Rails).to receive(:logger).and_return(logger)
          allow(logger).to receive(:error)
        end

        it 'logs error with Rails logger' do
          expect(logger).to receive(:error).with('Discord notification failed: Network error')
          notifier.notify(message: message, status: status)
        end
      end

      context 'when Rails is not defined' do
        before do
          hide_const('Rails') if defined?(Rails)
        end

        it 'logs error with warn' do
          expect_any_instance_of(Dislogger::Notifiers::DiscordNotifier).to receive(:warn).with('Discord notification failed: Network error')
          notifier.notify(message: message, status: status)
        end
      end
    end
  end
end 