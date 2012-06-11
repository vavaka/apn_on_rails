require 'socket'
require 'openssl'

module APN # :nodoc:

  module Errors # :nodoc:

    # Raised when a notification message to Apple is longer than 256 bytes.
    class ExceededMessageSizeError < StandardError

      def initialize(message) # :nodoc:
        super("The maximum size allowed for a notification payload is 256 bytes: '#{message}'")
      end

    end

    class MissingCertificateError < StandardError
      def initialize
        super("This app has no certificate")
      end
    end

  end # Errors

  module Configuration
    VALID_CONFIG_KEYS = [
      :passphrase,
      :host,
      :port,
      :feedback_passphrase,
      :feedback_host,
      :feedback_port
    ].freeze

    DEFAULT_PASSPHRASE = ''
    DEFAULT_HOST = 'gateway.sandbox.push.apple.com' #'gateway.push.apple.com'
    DEFAULT_PORT = 2195
    DEFAULT_FEEDBACK_PASSPHRASE = ''
    DEFAULT_FEEDBACK_HOST = 'feedback.sandbox.push.apple.com' #'feedback.sandbox.push.apple.com'
    DEFAULT_FEEDBACK_PORT = 2196

    attr_accessor *VALID_CONFIG_KEYS

    def self.extended(base)
      base.reset
    end

    def configure
      yield self
    end

    def reset
      self.passphrase = DEFAULT_PASSPHRASE
      self.host = DEFAULT_HOST
      self.port = DEFAULT_PORT
      self.feedback_passphrase = DEFAULT_FEEDBACK_PASSPHRASE
      self.feedback_host = DEFAULT_FEEDBACK_HOST
      self.feedback_port = DEFAULT_FEEDBACK_PORT
    end
  end

  extend Configuration

end # APN

base = File.join(File.dirname(__FILE__), 'app', 'models', 'apn', 'base.rb')
require base

Dir.glob(File.join(File.dirname(__FILE__), 'app', 'models', 'apn', '*.rb')).sort.each do |f|
  require f
end

%w{ models controllers helpers }.each do |dir|
  path = File.join(File.dirname(__FILE__), 'app', dir)
  $LOAD_PATH << path
  # puts "Adding #{path}"
  begin
    if ActiveSupport::Dependencies.respond_to? :autoload_paths
      ActiveSupport::Dependencies.autoload_paths << path
      ActiveSupport::Dependencies.autoload_once_paths.delete(path)
    else
      ActiveSupport::Dependencies.load_paths << path
      ActiveSupport::Dependencies.load_once_paths.delete(path)
    end
  rescue NameError
    Dependencies.load_paths << path
    Dependencies.load_once_paths.delete(path)
  end
end
