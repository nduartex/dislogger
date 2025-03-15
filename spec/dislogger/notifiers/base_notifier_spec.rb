# frozen_string_literal: true

RSpec.describe Dislogger::Notifiers::BaseNotifier do
  include_context 'with configuration'

  subject(:notifier) { described_class.new(config) }

  describe '#notify' do
    it 'raises NotImplementedError' do
      expect {
        notifier.notify(message: 'test', status: 500)
      }.to raise_error(NotImplementedError, "#{described_class} has not implemented method 'notify'")
    end
  end

  describe '#format_message' do
    it 'raises NotImplementedError' do
      expect {
        notifier.send(:format_message, 'test', 500, nil)
      }.to raise_error(NotImplementedError, "#{described_class} has not implemented method 'format_message'")
    end
  end

  describe '#send_notification' do
    it 'raises NotImplementedError' do
      expect {
        notifier.send(:send_notification, {})
      }.to raise_error(NotImplementedError, "#{described_class} has not implemented method 'send_notification'")
    end
  end

  describe '#enabled?' do
    context 'when environment is enabled' do
      it 'returns true' do
        expect(notifier.send(:enabled?)).to be true
      end
    end

    context 'when environment is not enabled' do
      before { config.enabled_environments = [] }

      it 'returns false' do
        expect(notifier.send(:enabled?)).to be false
      end
    end
  end
end 