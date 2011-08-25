module Adapi
  class Config
    @@data = nil # load ~/ad_words.yml by default

    def self.read
      @@data
    end

    def self.set(params = {})
      @@data = params
    end

    # TODO Config[key] = value (also read method)

  end
end
