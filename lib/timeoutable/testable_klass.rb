# frozen_string_literal: true

require 'logger'

module Timeoutable
  class TestableKlass
    BIT_NAME = 'testable_bit_change'

    # :nocov:
    def self.perform_test(warn: 2, timeout: 3, sleep_after: 0.1 , sleep_for: 0.1, logger: Logger.new($stdout))
      params = {
        warn: warn,
        timeout: timeout,
        proc: ->(thread, sec) { thread[BIT_NAME] = 1; logger.warn('at: proc -- Set Bit') },
        message: "Yoooo. Your code violently blew up. Handle it accordingly",
      }
      Timeoutable.timeout(**params) do
        new.execute(sleep_after: sleep_after, sleep_for: sleep_for)
      end
    end

    attr_reader :logger

    def initialize(logger: Logger.new($stdout))
      @logger = logger
    end

    def execute(sleep_after:, sleep_for:, max_iterations: 10_000, raise_warn: false, raise_timeout: false)
      logger.info("at: execute -- Start")
      count = 0
      while count <= max_iterations && Thread.current[BIT_NAME].nil?
        raise StandardError, 'Throwing error before warn bit' if raise_warn
        logger.info("at: execute -- sleeping for #{sleep_for}'s [#{count} iterations]")
        sleep(sleep_for)
        count += 1
      end
      raise StandardError, 'Throwing error after warn bit' if raise_timeout

      logger.info("at: execute -- Worker noticed sleep bit changed -- Cycle broken")

      logger.warn("at: execute -- sleeping 1 last time for #{sleep_after}'s")
      sleep(sleep_after)
      logger.warn("at: execute -- returning after sleep")
      logger.info("at: execute -- End")
    ensure
      logger.info("at: execute (ensure) -- ensure bit resetting")
    end

    # :nocov:
  end
end
