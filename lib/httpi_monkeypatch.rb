# encoding: utf-8

# manually hardcode timeouts for HTTPI to 5 minutes (300 seconds)
# TODO check if there's still no way to do it properly through HTTPI
# TODO enable user to set timeout in adapi configuration

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
