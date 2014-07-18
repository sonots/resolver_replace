## 0.1.0 (2014/07/18)

Fixes:

* (Critical) Add nil check not to get errors in Net::HTTP#connect

## 0.0.3 (2014/07/17)

Changes:

* Fix not to apply resolver_replace just by `require`. Calling `ResolverReplace.register!` is required to apply now.

## 0.0.2 (2014/06/27)

Enhancements:

* raise PluginLoadError if a required gem for the plugin is not loaded

## 0.0.1

First version
