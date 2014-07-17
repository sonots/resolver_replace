require 'resolv'
require 'resolver_replace'

resolver = Resolv::DNS.new(:nameserver => ['210.251.121.21'],
                           :search => ['ruby-lang.org'],
                           :ndots => 1)

addr = IPSocket.getaddress('ruby-lang.org') # Should not use ResolverReplace yet

ResolverReplace.register!(
  getaddress: Proc.new {|host| resolver.getaddress(host) },
  getaddresses: Proc.new {|host| resolver.getaddresses(host) },
  error_class: Resolv::ResolvError,
)

addr = IPSocket.getaddress('ruby-lang.org') # Should use ResolverReplace
