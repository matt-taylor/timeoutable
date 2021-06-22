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
        instance.execute(sleep_after: sleep_after, sleep_for: sleep_for, max_iterations: max_iterations)
      end
    end
    before { Thread.current[Timeoutable::TestableKlass::BIT_NAME] = nil }
    let(:params) { { warn: warn, timeout: timeout, proc: proc, message: message, debug: debug}}
    let(:warn) { 0.2 }
    let(:timeout) { 5}
    let(:proc) { ->(thread, sec) { thread[Timeoutable::TestableKlass::BIT_NAME] = 1 } }
    let(:message) { nil }
    let(:debug) { false }
    let(:max_iterations) { 1 }

    it { expect { subject }.not_to raise_error }

    it do
      expect { subject }.not_to change { Thread.current[Timeoutable::TestableKlass::BIT_NAME] }
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
