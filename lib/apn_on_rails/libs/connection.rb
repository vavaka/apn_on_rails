module APN
  module Connection
    
    class << self
      
      def open_for_delivery(options = {}, &block)
        open(options, &block)
      end
      
      def open_for_feedback(options = {}, &block)
        options = {:passphrase => APN.feedback_passphrase,
                   :host => APN.feedback_host,
                   :port => APN.feedback_port}.merge(options)
        open(options, &block)
      end
      
      private
      def open(options = {}, &block) # :nodoc:
        options = {:passphrase => APN.passphrase,
                   :host => APN.host,
                   :port => APN.port}.merge(options)

        ctx = OpenSSL::SSL::SSLContext.new
        ctx.key = OpenSSL::PKey::RSA.new(options[:cert], options[:passphrase])
        ctx.cert = OpenSSL::X509::Certificate.new(options[:cert])
  
        sock = TCPSocket.new(options[:host], options[:port])
        ssl = OpenSSL::SSL::SSLSocket.new(sock, ctx)
        ssl.sync = true
        ssl.connect
  
        yield ssl, sock if block_given?
  
        ssl.close
        sock.close
      end
      
    end
    
  end # Connection
end # APN