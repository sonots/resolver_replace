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
    require 'resolver_replace/replace.rb'
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

