# resolver-replace

Replace the DNS resolver.

## Installation

```bash
gem install resolver_replace
```

## How it works

Ruby comes with a pure Ruby replacement, [resolv-replace](https://github.com/ruby/ruby/blob/b1f2effda85efd03bd4ad5c06e0aae5e14f3f864/lib/resolv-replace.rb). 
It replaces the libc resolver with the built-in [Resolv](http://apidock.com/ruby/Resolv) class which is a thread-aware DNS resolver library.

This gem works similarly, but allows to replace the resolver with your favorite resolver. 

## How to use

For example, if you want to replace the resolver with `Resolv::DNS`, write as followings:

```ruby
require 'resolve' # Resolve::DNS
require 'resolver-replace' # ResolverReplace

resolver = Resolv::DNS.new(:nameserver => ['210.251.121.21'],
                           :search => ['ruby-lang.org'],
                           :ndots => 1)

ResolverReplace.configure(
  getaddress: Proc.new {|host| resolver.getaddress(host) },
  getaddresses: Proc.new {|host| resolver.getaddresses(host) },
  error_class: Resolv::ResolvError,
)
```

## Plugin

Some gems like `mysql2` implement its connection in its C extension without using ruby library. 
In such case, another monkeypatch must be applied. A plugin scheme of ResolveReplace is ready for such case.

The `mysql2` plugin is available for example. Use as followings:

```ruby
ResolverReplace.load_plugin('mysql2')
ResolverReplace.configure(
  getaddress: Proc.new {|host| resolver.getaddress(host) },
  getaddresses: Proc.new {|host| resolver.getaddresses(host) },
  error_class: Resolv::ResolvError,
)
```

## ChangeLog

See [CHANGELOG.md](CHANGELOG.md) for details.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new [Pull Request](../../pull/new/master)

## Copyright

Copyright (c) 2014 Naotoshi Seo. See [LICENSE.txt](LICENSE.txt) for details.

