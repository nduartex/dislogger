# frozen_string_literal: true

RSpec.describe Dislogger::Formatters::BaseFormatter do
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
    it 'raises NotImplementedError' do
      expect {
        formatter.format
      }.to raise_error(NotImplementedError, "#{described_class} has not implemented method 'format'")
    end
  end

  describe 'attribute readers' do
    it 'provides access to protected attributes' do
      expect(formatter.send(:message)).to eq(message)
      expect(formatter.send(:status)).to eq(status)
      expect(formatter.send(:backtrace)).to eq(backtrace)
      expect(formatter.send(:config)).to eq(config)
    end
  end
end 