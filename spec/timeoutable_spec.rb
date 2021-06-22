# frozen_string_literal: true

RSpec.describe Timeoutable do
  let(:instance) { Timeoutable::TestableKlass.new }
  let(:sleep_after) { 0.0 }
  let(:sleep_for) { 0.0 }
  let(:logger) { Logger.new('/dev/null') }
  before { allow(Logger).to receive(:new).with($stdout).and_return(logger) }
  it "has a version number" do
    expect(Timeoutable::VERSION).not_to be nil
  end

  describe '.timeout' do
    subject do
      described_class.timeout(**params) do
        instance.execute(**instance_params)
      end
    end
    before { Thread.current[Timeoutable::TestableKlass::BIT_NAME] = nil }
    let(:params) { { warn: warn, timeout: timeout, proc: proc, message: message, debug: debug}}
    let(:instance_params) do
      {
        sleep_after: sleep_after,
        sleep_for: sleep_for,
        max_iterations: max_iterations,
        raise_warn: raise_warn,
        raise_timeout: raise_timeout,
      }
    end
    let(:raise_warn) { false }
    let(:raise_timeout) { false }
    let(:warn) { 0.2 }
    let(:timeout) { 5 }
    let(:proc) { ->(thread, sec) { thread[Timeoutable::TestableKlass::BIT_NAME] = 1 } }
    let(:message) { nil }
    let(:debug) { false }
    let(:max_iterations) { 1 }

    it { expect { subject }.not_to raise_error }

    it do
      expect { subject }.not_to change { Thread.current[Timeoutable::TestableKlass::BIT_NAME] }
    end

    context 'when error occurs before warning' do
      let(:raise_warn) { true }

      it { expect { subject }.to raise_error(StandardError, /Throwing error before warn bit/) }
    end

    context 'when error occurs before warning' do
      let(:raise_timeout) { true }

      it { expect { subject }.to raise_error(StandardError, /Throwing error after warn bit/) }
    end

    context 'when error occurs after warning' do
    end

    context 'when time exceeds warning' do
      let(:sleep_for) { 0.2 }
      let(:max_iterations) { 10_000 }

      it do
        expect { subject }.to change { Thread.current[Timeoutable::TestableKlass::BIT_NAME] }
      end

      it { expect { subject }.not_to raise_error }
    end

    context 'when time exceeds timout' do
      let(:timeout) { 0.3 }
      let(:sleep_for) { 0.1 }
      let(:sleep_after) { 5 }

      it do
        expect { subject }.to raise_error(described_class::TimeoutExceeded).and change { Thread.current[Timeoutable::TestableKlass::BIT_NAME] }
      end

      it { expect { subject }.to raise_error(described_class::TimeoutExceeded, /Execution exceeded/) }
    end
  end
end
