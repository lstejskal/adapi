
# manually hardcode timeouts for HTTPI to 5 minutes (300 seconds)

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
