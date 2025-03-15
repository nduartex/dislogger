# frozen_string_literal: true

RSpec.describe Dislogger do
  it 'has a version number' do
    expect(Dislogger::VERSION).not_to be nil
  end

  describe '.configuration' do
    it 'returns the same configuration object' do
      expect(described_class.configuration).to eq(described_class.configuration)
    end

    it 'can be configured via block' do
      described_class.configure do |config|
        config.discord_webhook_url = 'test_url'
        config.bot_username = 'test_bot'
      end

      expect(described_class.configuration.discord_webhook_url).to eq('test_url')
      expect(described_class.configuration.bot_username).to eq('test_bot')
    end
  end

  describe '.reset' do
    before do
      described_class.configure do |config|
        config.discord_webhook_url = 'test_url'
        config.bot_username = 'test_bot'
      end
    end

    it 'resets the configuration to defaults' do
      described_class.reset

      expect(described_class.configuration.discord_webhook_url).to be_nil
      expect(described_class.configuration.bot_username).to eq('Error Logger')
    end
  end

  it 'provides error handling and Discord notifications' do
    expect(described_class::ErrorHandler).to be_a(Module)
    expect(described_class::Notifiers::DiscordNotifier).to be_a(Class)
  end
end
