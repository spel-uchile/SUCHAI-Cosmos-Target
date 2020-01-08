require 'cosmos/conversions/conversion'
require 'cosmos/packets/structure_item'

module Cosmos
  class SuchaiConversion < Conversion
    def initialize()
        super()
        @converted_type = :STRING
        @converted_bit_size = 8*4
        #@converted_array_size = nil
    end
    def call(value, packet, buffer)
      puts value
      value=value.to_s
      puts value
      return value
    end
  end
end