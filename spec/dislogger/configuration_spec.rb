# frozen_string_literal: true

RSpec.describe Dislogger::Configuration do
  describe '#initialize' do
    subject(:config) { described_class.new }

    it 'sets default values' do
      expect(config.discord_webhook_url).to be_nil
      expect(config.bot_username).to eq('Error Logger')
      expect(config.backtrace_lines_limit).to eq(5)
      expect(config.enabled_environments).to eq(%w[production staging])
      expect(config.environment).to be_nil
    end

    it 'sets default error colors' do
      expect(config.error_color_map).to include(
        500 => 15158332,
        404 => 3447003,
        422 => 16776960,
        403 => 15105570,
        default: 10181046
      )
    end
  end

  describe '#enabled?' do
    subject(:config) { described_class.new }

    context 'when environment is in enabled_environments' do
      before { config.environment = 'production' }

      it { expect(config).to be_enabled }
    end

    context 'when environment is not in enabled_environments' do
      before { config.environment = 'development' }

      it { expect(config).not_to be_enabled }
    end

    context 'when environment is nil' do
      it { expect(config).not_to be_enabled }
    end

    context 'when enabled_environments is empty' do
      before do
        config.environment = 'production'
        config.enabled_environments = []
      end

      it { expect(config).not_to be_enabled }
    end
  end

  describe 'attribute accessors' do
    subject(:config) { described_class.new }

    it 'allows setting and getting discord_webhook_url' do
      config.discord_webhook_url = 'https://example.com'
      expect(config.discord_webhook_url).to eq('https://example.com')
    end

    it 'allows setting and getting bot_username' do
      config.bot_username = 'New Bot'
      expect(config.bot_username).to eq('New Bot')
    end

    it 'allows setting and getting backtrace_lines_limit' do
      config.backtrace_lines_limit = 10
      expect(config.backtrace_lines_limit).to eq(10)
    end

    it 'allows setting and getting enabled_environments' do
      config.enabled_environments = ['test']
      expect(config.enabled_environments).to eq(['test'])
    end

    it 'allows setting and getting environment' do
      config.environment = 'test'
      expect(config.environment).to eq('test')
    end

    it 'allows setting and getting error_color_map' do
      new_colors = { 500 => 123456 }
      config.error_color_map = new_colors
      expect(config.error_color_map).to eq(new_colors)
    end
  end
end 