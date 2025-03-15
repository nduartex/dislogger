# frozen_string_literal: true

require 'action_controller'

RSpec.describe Dislogger::ErrorHandler do
  let(:dummy_class) do
    Class.new(ActionController::Base) do
      include Dislogger::ErrorHandler

      attr_reader :rendered_json, :rendered_status

      def render(json:, status:)
        @rendered_json = json
        @rendered_status = status
      end
    end
  end

  subject(:handler) { dummy_class.new }

  let(:notifier) { instance_double(Dislogger::Notifiers::DiscordNotifier) }

  before do
    allow(Dislogger::Notifiers::DiscordNotifier).to receive(:new).and_return(notifier)
    allow(notifier).to receive(:notify)
  end

  describe '#handle_not_found' do
    let(:exception) { ActiveRecord::RecordNotFound.new('Record not found') }

    it 'renders not found error' do
      handler.send(:handle_not_found, exception)

      expect(handler.rendered_json).to include(
        status: :not_found,
        message: 'Record not found'
      )
      expect(handler.rendered_status).to eq(:not_found)
    end

    it 'notifies Discord' do
      expect(notifier).to receive(:notify).with(
        message: 'Record not found',
        status: 404,
        backtrace: nil
      )

      handler.send(:handle_not_found, exception)
    end

    context 'when exception has no message' do
      let(:exception) { ActiveRecord::RecordNotFound.new('') }

      it 'uses default message' do
        handler.send(:handle_not_found, exception)
        expect(handler.rendered_json[:message]).to eq('Resource not found')
      end
    end
  end

  describe '#handle_unprocessable_entity' do
    context 'with ActiveRecord::RecordInvalid' do
      let(:record_class) do
        Class.new do
          def self.i18n_scope
            :activerecord
          end
        end
      end

      let(:record) do
        instance_double('Record',
          class: record_class,
          errors: double('Errors', full_messages: ['Name is invalid'])
        )
      end

      let(:exception) { ActiveRecord::RecordInvalid.new(record) }

      it 'renders validation error with details' do
        handler.send(:handle_unprocessable_entity, exception)

        expect(handler.rendered_json).to include(
          status: :unprocessable_entity,
          message: 'Validation failed',
          details: ['Name is invalid']
        )
      end
    end

    context 'with ActionController::ParameterMissing' do
      let(:exception) { ActionController::ParameterMissing.new('user') }

      it 'renders parameter missing error' do
        handler.send(:handle_unprocessable_entity, exception)

        expect(handler.rendered_json).to include(
          status: :unprocessable_entity,
          message: 'Validation failed',
          details: ['param is missing or the value is empty: user']
        )
      end
    end
  end

  describe '#handle_forbidden' do
    let(:exception) { StandardError.new('Not authorized') }

    it 'renders forbidden error' do
      handler.send(:handle_forbidden, exception)

      expect(handler.rendered_json).to include(
        status: :forbidden,
        message: 'Not authorized'
      )
      expect(handler.rendered_status).to eq(:forbidden)
    end

    context 'when exception has no message' do
      let(:exception) { StandardError.new('') }

      it 'uses default message' do
        handler.send(:handle_forbidden, exception)
        expect(handler.rendered_json[:message]).to eq('You are not authorized to perform this action')
      end
    end
  end

  describe '#handle_internal_server_error' do
    let(:exception) do
      StandardError.new('Something went wrong').tap do |e|
        e.set_backtrace(['line 1', 'line 2'])
      end
    end

    it 'renders internal server error' do
      handler.send(:handle_internal_server_error, exception)

      expect(handler.rendered_json).to include(
        status: :internal_server_error,
        message: 'Internal Server Error'
      )
      expect(handler.rendered_status).to eq(:internal_server_error)
    end

    it 'notifies Discord with backtrace' do
      expect(notifier).to receive(:notify).with(
        message: 'Internal Server Error',
        status: 500,
        backtrace: ['line 1', 'line 2']
      )

      handler.send(:handle_internal_server_error, exception)
    end
  end

  describe '#notify_and_render_error' do
    it 'converts symbol status to status code' do
      expect(notifier).to receive(:notify).with(
        message: 'Test message',
        status: 404,
        backtrace: nil
      )

      handler.send(:notify_and_render_error,
        message: 'Test message',
        status: :not_found
      )
    end
  end
end 