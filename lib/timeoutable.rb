# frozen_string_literal: true

require_relative 'timeoutable/version'
require 'logger'

module Timeoutable
  class TimeoutExceeded < StandardError; end

  PROC = Proc.new do |warn_sec, timeout_sec, proc, exception, message, debug, &block|
    LOGGER.info "at: PROC; begining" if debug

    sec_to_raise = timeout_sec - warn_sec
    begin
      from = debug ? "from #{caller_locations(1, 1)[0]}" : nil
      x = Thread.current
      # do everything in a new thread
      y = Thread.start {
        LOGGER.info "at: PROC; second thread; about to start" if debug
        Thread.current.name = from
        # block for warning in new thread
        begin
          LOGGER.info "at: PROC; second thread; starting warn time for #{warn_sec}'s " if debug
          sleep warn_sec
        rescue => e
          x.raise e
        else
          # yield back during warning time so downstream can do some prep work
          LOGGER.info "at: PROC; second thread; trying to warn in main thread" if debug
          proc.call(x, warn_sec)
        end

        # block additional seconds to raise for
        begin
          LOGGER.info "at: PROC; second thread; starting violent exection time for #{sec_to_raise}'s " if debug
          sleep sec_to_raise
        rescue => e
          LOGGER.info "at: PROC; second thread; Error occured" if debug
          x.raise e
        else
          LOGGER.info "at: PROC; second thread; trying to raise in main thread" if debug
          x.raise exception, message
        end
      }
      LOGGER.info "at: PROC; second thread; fully spooled" if debug
      # after thread starts, yield back to calle function with max timout
      block.call(timeout_sec)
    ensure
      if y
        LOGGER.info "at: PROC; Second thread still exists. Returned in time" if debug
        y.kill
        y.join
      else
        LOGGER.info "at: PROC; Second thread no longer exists. Failed to return in time" if debug
      end
    end
  end

  LOGGER = Logger.new($stdout)

  def self.timeout(warn:, timeout:, proc: ->(_, _) {}, exception: TimeoutExceeded, message: nil, debug: false, &block)
    raise ArgumentError, 'Block not given' unless block_given?

    LOGGER.info "at: timeout; valid bock given" if debug
    message ||= "Execution exceeded #{timeout} seconds."
    PROC.call(warn, timeout, proc, exception, message, debug, &block)
  end
end
