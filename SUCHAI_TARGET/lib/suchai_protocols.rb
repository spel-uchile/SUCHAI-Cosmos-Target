# encoding: ascii-8bit

# Copyright 2017 Ball Aerospace & Technologies Corp.
# All Rights Reserved.
#
# This program is free software; you can modify and/or redistribute it
# under the terms of the GNU General Public License
# as published by the Free Software Foundation; version 3 with
# attribution addendums as found in the LICENSE.txt

require 'cosmos/config/config_parser'
require 'cosmos/interfaces/protocols/protocol'
require 'thread'

module Cosmos
  # Base class for all COSMOS protocols which defines a framework which must be
  # implemented by a subclass.
  class SuchaiProtocols < Protocol
    attr_accessor :interface
    attr_accessor :allow_empty_data

    # @param allow_empty_data [true/false/nil] Whether or not this protocol will allow an empty string
    # to be passed down to later Protocols (instead of returning :STOP). Can be true, false, or nil, where
    # nil is interpreted as true unless the Protocol is the last Protocol of the chain.
    def initialize(allow_empty_data = nil)
      @interface = SuchaiInterface
      @allow_empty_data = ConfigParser.handle_true_false_nil(allow_empty_data)
      reset()
    end

    def reset
    end

    def connect_reset
      reset()
    end

    def disconnect_reset
      reset()
    end

    # Ensure we have some data in case this is the only protocol
    def read_data(data)
      if (data.length <= 0)
        if @allow_empty_data.nil?
          if @interface and @interface.read_protocols[-1] == self
            # Last read interface in chain with auto @allow_empty_data
            return :STOP
          end
        elsif !@allow_empty_data
          # Don't @allow_empty_data means STOP
          return :STOP
        end
      end
      #print("THIS IS SUCHAI_PROTOCOLS: read_data\n")
      #print("read_data value: ",data)
      #print("\n")
      #data=data.to_s()
      #print("read_data post to_s value: ",data)
      #print("\n")
      return data
    end

    def read_packet(packet)

      return packet
    end

    def write_packet(packet)
      #puts "THIS IS SUCHAI PROTOCOLS: read_packet\n"
      #
      #packet.id_parameters.each do |item|
      #
      #  puts "item:#{item.name}: #{item.id_value} \n"
      #end
      return packet
    end

    def write_data(data)
      data=data_cleaner(data)
      return data
    end

    def post_write_interface(packet, data)


      return packet, data
    end

    def data_cleaner(data)#returns the command as a string ready to be read by the interface so the SUCHAI can understand it
      dataNew=data.force_encoding('ISO-8859-1')#some int coded as bytes can raise and error if this encoding is not enforced
      dataNew=escape_char(dataNew,0)
      dataNew=dataNew.split(" ")#each int and string input is separated in an array
      i=1
      while i<dataNew.size
        dataNew[i]=escape_char(dataNew[i],1) #we add the special characters after having the array, the special characters will
        #break how the string is separated
        i+=1
      end
      i=1
      while i < dataNew.size
        dataNew[i].force_encoding("UTF-8")
        if  !dataNew[i].valid_encoding?#if its invalid , its not a string
          aux=dataNew[i].unpack('N')[0].to_s
          dataNew[i]=aux

        elsif dataNew[i].split("").size==4 #can be hex
          if dataNew[i].split("").size==dataNew[i].count("a-zA-Z0-9_")#normal string
            #do nothing
          end
          aux=dataNew[i].unpack('N')[0].to_s #is a hex
          dataNew[i]=aux
        elsif dataNew[i].size>4#when strings params are sent , they are sent with extra allocation space, we remove that space here
          dataNew[i]=dataNew[i].gsub("\x00","")

        elsif dataNew[i].size<4#if its less than 4 and there is a \x00, is a hex, otherwise a small word
          if dataNew[i].include?("\x00")
            aux=(dataNew[i]+(" ")).unpack('N')[0].to_s
            dataNew[i]=aux
          else
            #do nothing
          end

        end
        i+=1
      end
      dataNew=dataNew.join(' ')
      dataNew
    end

    def escape_char(string,mode)
      #method used to clean all the escape characters from the incoming data
      if mode==0#clean especial characters
        if string.include?("\n")
          string=string.gsub("\n","FLAG::N")
        end
        if string.include?("\a")
          string=string.gsub("\a","FLAG::A")
        end
        if string.include?("\b")
          string=string.gsub("\b","FLAG::B")
        end
        if string.include?("\e")
          string=string.gsub("\e","FLAG::E")
        end
        if string.include?("\f")
          string=string.gsub("\f","FLAG::F")
        end
        if string.include?("\r")
          string=string.gsub("\r","FLAG::R")
        end
        if string.include?("\t")
          string=string.gsub("\t","FLAG::T")
        end
        if string.include?("\v")
          string=string.gsub("\v","FLAG::V")
        end
        if string.include?("  ")
          string=string.gsub("  ","DSPACE DSPACE")
        end

      else#mode==1 add special characters after separating the string into each int or string
        if string.include?("FLAG::N")
          string=string.gsub("FLAG::N","\n")
        end
        if string.include?("FLAG::A")
          string=string.gsub("FLAG::A","\a")
        end
        if string.include?("FLAG::B")
          string=string.gsub("FLAG::B","\b")
        end
        if string.include?("FLAG::E")
          string=string.gsub("FLAG::E","\e")
        end
        if string.include?("FLAG::F")
          string=string.gsub("FLAG::F","\f")
        end
        if string.include?("FLAG::R")
          string=string.gsub("FLAG::R","\r")
        end
        if string.include?("FLAG::T")
          string=string.gsub("FLAG::T","\t")
        end

        if string.include?("FLAG::V")
          string=string.gsub("FLAG::V","\v")
        end
        if string.include?("DSPACE")
          if string.size>=4+6
            string=string.gsub("DSPACE","")
          else
            string=string.gsub("DSPACE"," ")
          end
        end
      end
      string
    end


  end
end