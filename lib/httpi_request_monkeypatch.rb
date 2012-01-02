# encoding: utf-8

# manually hardcode timeouts for HTTPI to 5 minutes (300 seconds)
# HOTFIX there's no way how to do it properly through HTTPI

module HTTPI
  class Request
    def open_timeout
      300
    end

    def read_timeout
      300
    end
  end
end

# disable ssl authentication in curb
# HOTFIX for bug in HTTPI

module HTTPI
  module Adapter
    class Curb

    private

      def setup_client(request)
        basic_setup request
        setup_http_auth request if request.auth.http?
        # setup_ssl_auth request.auth.ssl if request.auth.ssl?
        # setup_ntlm_auth request if request.auth.ntlm?

        # HOTFIX for bug in curb 0.7.16, see issue:
        # https://github.com/taf2/curb/issues/96
        client.resolve_mode = :ipv4
      end
      
    end
  end
end