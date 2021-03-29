class LinkDecisionHelper
  ALLOWED_TYPES = [
    NAVBAR_LOGGED_IN = :n_logged_in,
    NAVBAR_LOGGED_OUT = :n_logged_out
  ]

  DEFAULT_TITLE = 'Default Title'
  DEFAULT_URL = '/' # root

  class NotOnAllowListError < StandardError; end;

  def self.clear_type!(type:)
    raise "Unexpected type [#{type}]. Expected #{ALLOWED_TYPES}" unless ALLOWED_TYPES.include?(type)
    Rails.application.config.public_send("#{type}=", [])
  end

  def initialize(title:, url:, type:, default_type: nil, config: nil)
    raise NotOnAllowListError, "Unexpected type [#{type}]. Expected #{ALLOWED_TYPES}" unless ALLOWED_TYPES.include?(type)

    @config = config
    @type = type
    @url = url
    @title = title

    if default_type && ALLOWED_TYPES.include?(default_type)
      assign_default!
    elsif default_type && !ALLOWED_TYPES.include?(default_type)
      raise NotOnAllowListError, 'unexpected default value'
    end
  end

  def assign!
    config.public_send(@type).push(self)
  end

  def url
    get_value(@url)
  end

  def title
    get_value(@title)
  end

  private

  def get_value(thing)
    thing.is_a?(Proc) ? thing.call : thing
  end

  def assign_default!
    case @type
    when NAVBAR_LOGGED_IN
      @url = DEFAULT_URL
      @title = DEFAULT_TITLE
    end
  end

  def config
    @config ||= Rails.application.config
  end
end
