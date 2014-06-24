require_relative 'spec_helper'
require 'resolver_replace'

describe ResolverReplace do
  let(:host) { 'ruby-lang.org' }
  let(:ip)   { '127.0.0.1' }

  before do
    ResolverReplace.register!(
      getaddress: Proc.new {|host| ip },
      getaddresses: Proc.new {|host| ip },
      error_class: StandardError,
    )
  end

  it 'IPSocket' do
    expect(IPSocket.getaddress(host)).to be == ip
  end

  it 'net/http' do
    require 'net/http'
    begin
      Net::HTTP.get_print(host, '/index.html')
    rescue => e
      expect(e.message).to match(/Connection refused.*127.0.0.1/)
    end
  end

  it 'mysql2' do
    require 'mysql2'
    ResolverReplace.load_plugin("mysql2")
    begin
      Mysql2::Client.new(
        host: 'foo',
        username: 'root',
        database: 'foo',
      )
    rescue => e
      expect(e.message).not_to match(/Unknown MySQL server/)
    end
  end
end
