# reference: ruby/lib/resolv-replace.rb
require 'socket'
require 'resolver_replace'

class << IPSocket
  # :stopdoc:
  alias original_resolver_getaddress getaddress
  # :startdoc:
  def getaddress(host)
    begin
      host = ResolverReplace.getaddress(host).to_s if host and host != ""
      return host
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
    rest[0] = IPSocket.getaddress(rest[0]) if !rest.empty? and rest[0]
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
        addrs = (host and host != "") ? ResolverReplace.getaddresses(host) : []
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
