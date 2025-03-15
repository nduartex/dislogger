# frozen_string_literal: true

RSpec.describe Dislogger::Formatters::DiscordFormatter do
  include_context 'with configuration'
  include_context 'with error data'

  subject(:formatter) do
    described_class.new(
      message: message,
      status: status,
      backtrace: backtrace,
      config: config
    )
  end

  describe '#format' do
    subject(:formatted_message) { formatter.format }

    it 'formats the message correctly' do
      expect(formatted_message).to include(
        username: config.bot_username,
        embeds: [
          hash_including(
            title: "#{config.environment.capitalize} - Error Notification (#{status})",
            description: message,
            color: config.error_color_map[status],
            fields: array_including(
              { name: 'Status Code', value: status.to_s, inline: true },
              { name: 'Environment', value: config.environment, inline: true },
              { name: 'Backtrace', value: backtrace.first(5).join("\n"), inline: false }
            )
          )
        ]
      )
    end

    context 'when backtrace is nil' do
      let(:backtrace) { nil }

      it 'excludes backtrace field' do
        fields = formatted_message[:embeds].first[:fields]
        expect(fields.map { |f| f[:name] }).not_to include('Backtrace')
      end
    end

    context 'when status color is not mapped' do
      let(:status) { 418 }

      it 'uses default color' do
        expect(formatted_message[:embeds].first[:color]).to eq(config.error_color_map[:default])
      end
    end
  end
end 