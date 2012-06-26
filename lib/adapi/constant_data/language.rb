# encoding: utf-8

# ConstantData::Language provides searching language id by its code. It is used
# a a helper function for targeting.
#
# PS: Previously it has been possible to target by language code. This is not
# supported by AdWords API anymore.

module Adapi
  class ConstantData::Language < ConstantData

    LANGUAGE_IDS = { :en => 1000, :de => 1001, :fr => 1002, :es => 1003,
      :it => 1004, :ja => 1005, :da => 1009, :nl => 1010, :fi => 1011, :ko => 1012,
      :no => 1013, :pt => 1014, :sv => 1015, :zh_CN => 1017, :zh_TW => 1018,
      :ar => 1019, :bg => 1020, :cs => 1021, :el => 1022, :hi => 1023, :hu => 1024,
      :id => 1025, :is => 1026, :iw => 1027, :lv => 1028, :lt => 1029, :pl => 1030,
      :ru => 1031, :ro => 1032, :sk => 1033, :sl => 1034, :sr => 1035, :uk => 1036,
      :tr => 1037, :ca => 1038, :hr => 1039, :vi => 1040, :ur => 1041, :tl => 1042,
      :et => 1043, :th => 1044
    }

    attr_accessor :id, :code

    def initialize(params = {})
      @id = params[:id]
      @code = params[:code]

      super(params)
    end

    # Returns AdWords API language id based for language code
    #
    def self.find(code)
      
      # TODO just in case, also allow searching by id
      if code.is_a?(Integer)
        Language.new(
          :id => code,
          :code => LANGUAGE_IDS.find { |k,v| v == code }.first
        )

      else
        Language.new(
          :id => LANGUAGE_IDS[code.to_sym.downcase],
          :code => code.to_sym.downcase
        )
      end
    end

  end
end
