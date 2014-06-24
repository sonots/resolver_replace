require 'resolve'

resolver = Resolv::DNS.new(:nameserver => ['210.251.121.21'],
                           :search => ['ruby-lang.org'],
                           :ndots => 1)

ResolverReplace.configure(
  getaddress_proc: Proc.new {|host| resolver.getaddress(host) },
  getaddresses_proc: Proc.new {|host| resolver.getaddresses(host) },
  error_class: Resolv::ResolvError,
)
