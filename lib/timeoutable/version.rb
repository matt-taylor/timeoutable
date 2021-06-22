# frozen_string_literal: true

module Timeoutable
  MAJOR = 0  # With backwards incompatability. Requires annoucment and update documentation
  MINOR = 2  # With feature launch. Documentation of upgrade is useful via a changelog
  PATCH = 0  # With minor upgrades or patcing a small bug. No changelog necessary
  VERSION = [MAJOR,MINOR,PATCH].join('.')

  def self.get_version
    puts VERSION
  end
end
