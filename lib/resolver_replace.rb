require 'resolver_replace/error'

class ResolverReplace
  def self.register!(params = {})
    unless @getaddress = params[:getaddress]
      raise ArgumentError, 'getaddress is required'
    end
    unless @getaddresses = params[:getaddresses]
      raise ArgumentError, 'getaddresses is required'
    end
    @error_class = params[:error_class] || StandardError
  end

  def self.getaddress(host)
    @getaddress.call(host)
  end

  def self.getaddresses(host)
    @getaddresses.call(host)
  end

  def self.error_class
    @error_class
  end

  def self.load_plugin(name)
    require "resolver_replace/plugins/#{name}"
  end
end

# reference: ruby/lib/resolv-replace.rb
require 'socket'

class << IPSocket
  # :stopdoc:
  alias original_resolver_getaddress getaddress
  # :startdoc:
  def getaddress(host)
    begin
      return ResolverReplace.getaddress(host).to_s
    rescue ResolverReplace.error_class => e
      raise SocketError, "#{e.class} #{e.message}"
    end
  end
end
 
class TCPSocket < IPSocket
  # :stopdoc:
  alias original_resolver_initialize initialize
  # :startdoc:
  def initialize(host, serv, *rest)
    rest[0] = IPSocket.getaddress(rest[0]) unless rest.empty?
    original_resolver_initialize(IPSocket.getaddress(host), serv, *rest)
  end
end
 
class UDPSocket < IPSocket
  # :stopdoc:
  alias original_resolver_bind bind
  # :startdoc:
  def bind(host, port)
    host = IPSocket.getaddress(host) if host != ""
    original_resolver_bind(host, port)
  end
 
  # :stopdoc:
  alias original_resolver_connect connect
  # :startdoc:
  def connect(host, port)
    original_resolver_connect(IPSocket.getaddress(host), port)
  end
 
  # :stopdoc:
  alias original_resolver_send send
  # :startdoc:
  def send(mesg, flags, *rest)
    if rest.length == 2
      host, port = rest
      begin
        addrs = ResolverReplace.getaddresses(host)
      rescue ResolverReplace.error_class => e
        raise SocketError, "#{e.class} #{e.message}"
      end
      addrs[0...-1].each {|addr|
        begin
          return original_resolver_send(mesg, flags, addr, port)
        rescue SystemCallError
        end
      }
      original_resolver_send(mesg, flags, addrs[-1], port)
    else
      original_resolver_send(mesg, flags, *rest)
    end
  end
end
 
class SOCKSSocket < TCPSocket
  # :stopdoc:
  alias original_resolver_initialize initialize
  # :startdoc:
  def initialize(host, serv)
    original_resolver_initialize(IPSocket.getaddress(host), port)
  end
end if defined? SOCKSSocket
