# encoding: ascii-8bit

# Copyright 2017 Ball Aerospace & Technologies Corp.
# All Rights Reserved.
#
# This program is free software; you can modify and/or redistribute it
# under the terms of the GNU General Public License
# as published by the Free Software Foundation; version 3 with
# attribution addendums as found in the LICENSE.txt

require 'cosmos'
require 'cosmos/interfaces/interface'
require 'cosmos/config/config_parser'

require 'ffi-rzmq'

module Cosmos
  # Base class for interfaces that send and receive messages over UDP
  class SuchaiInterface < Cosmos::Interface
    # @param hostname [String] Machine to connect to
    # @param write_dest_port [Integer] Port to write commands to
    # @param read_port [Integer] Port to read telemetry from
    # @param write_src_port [Integer] Port to allow replies if needed
    # @param interface_address [String] If the destination machine represented
    #   by hostname supports multicast, then interface_address is used to
    #   configure the outgoing multicast address.
    # @param ttl [Integer] Time To Live value. The number of intermediate
    #   routers allowed before dropping the packet.
    # @param write_timeout [Integer] Seconds to wait before aborting writes
    # @param read_timeout [Integer] Seconds to wait before aborting reads
    # @param bind_address [String] Address to bind UDP ports to
    def initialize(
      write_port,
      read_port,
      node='11',
      remote='10',
      bind_address = 'localhost')

      super()
      
      if node != ''
        @node = node.to_i().chr
      end

      if remote != ''
        @remote = remote.to_i().chr
      end

      @write_port = ConfigParser.handle_nil(write_port)
      #@write_port = write_port.to_i if @write_port
      @read_port = ConfigParser.handle_nil(read_port)
      #@read_port = read_port.to_i if @read_port
      @bind_address = ConfigParser.handle_nil(bind_address)
      @write_socket = nil
      @read_socket = nil
      @read_allowed = false unless @read_port
      @write_allowed = false unless @write_port
      @write_raw_allowed = false unless @write_port
      @reading_dir = "tcp://" + bind_address + ":" + @read_port
      @writing_dir = "tcp://" + bind_address + ":" + @write_port
      Logger.instance.info(@reading_dir)
      Logger.instance.info(@writing_dir)      
      @ctx = ZMQ::Context.new(1) 
    end

    # Creates a new {UdpWriteSocket} if the the write_dest_port was given in
    # the constructor and a new {UdpReadSocket} if the read_port was given in
    # the constructor.
    def connect
      if @reading_dir and @writing_dir
        @read_socket = @ctx.socket(ZMQ::SUB)
        @rc_r = @read_socket.connect(@reading_dir)
        @read_socket.setsockopt(ZMQ::SUBSCRIBE, @node) 
        @write_socket = @ctx.socket(ZMQ::PUB) 
        @rc_w = @write_socket.connect(@writing_dir)
      end
    end

    # @return [Boolean] Whether the active ports (read and/or write) have
    #   created sockets. Since UDP is connectionless, creation of the sockets
    #   is used to determine connection.
    def connected?
      if @write_port && @read_port
        (@rc_r && @rc_w) ? true : false
      end
    end

    # Close the active ports (read and/or write) and set the sockets to nil.
    def disconnect
      @write_socket.close
      @read_socket.close
      @write_socket = nil
      @read_socket = nil
      @rc_r = false
      @rc_W = false
    end

    # Reads from the socket if the read_port is defined
    def read_interface      
      """ Read messages from node(s) """
       puts connected?
      arr = []
      arr2 = []
	  str = String.new
	  #data = arr[0]
	  message = ZMQ::Message.create()
	  #buffer = String.new

      Logger.instance.info("Waiting data...")
      rc = @read_socket.recv_multipart(arr, arr2)
      #rc = @read_socket.recvmsg(message, flag = ZMQ::DONTWAIT)
      puts rc
      if rc == -1
        return nil
      end
      data = arr2[0].copy_out_string()
      data2 = data.dup()
      data[1] = data2[4]
      data[2] = data2[3]
      data[3] = data2[2]
      data[4] = data2[1]
	  Logger.instance.info(data)
      read_interface_base(data)
      return data
    end

    # Writes to the socket
    # @param data [String] Raw packet data
    def write_interface(data)

      puts connected?
      write_interface_base(data)
      port = 10 # TC PORT
	    #Prio SRC DST DP  SP RES HXRC
      header = "%02b%05b%05b%06b%06b00000000"
      Logger.instance.info(data)
      if data.length > 0
             # Get CSP header and data
             hdr = header % [1, @node.ord, @remote.ord, port, rand(11...64)]

             # print("con:", hdr, hex(int(hdr, 2)))
             # print("con:", parse_csp(hex(int(hdr, 2))), data)

             # Build CSP message
             hdr_b = hdr.scan(/......../).reverse
             hdr = hdr_b.map { |x| x.to_i(2).chr }

             #puts hdr
             # print("con:", hdr_b, ["{:02x}".format(int(i, 2)) for i in hdr_b])
             #hdr = bytearray([int(i,2) for i in hdr_b])
             #hdr = hdr_b.join(', ')
             #puts hdr
             #print("Node: ", @node.chr, "  Hdr: ", hdr)
             #print("Data: ",data)


             data_clean=data_cleaner(data)
             msg = [@remote.chr] + hdr + data_clean.split("")

             #msg = bytearray([node,]) + hdr + bytearray(data, "ascii")
             #print("con:", msg)
             @write_socket.send_string(msg.join)

        end

        #sleep(0.25)
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


