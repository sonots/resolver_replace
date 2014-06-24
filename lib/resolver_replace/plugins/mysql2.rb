if defined?(Mysql2)
  module Mysql2
    class Client
      alias original_resolver_connect connect
      def connect user, pass, host, port, database, socket, flags
        begin
          ip = ResolverReplace.getaddress(host).to_s
          original_resolver_connect user, pass, ip, port, database, socket, flags
        rescue ResolverReplace.error_class => e
          raise Mysql2::Error, "#{e.class}: #{e.message}"
        end
      end
    end
  end
end
