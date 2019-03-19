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
      
      @remote = remote
      
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
	#         Prio SRC DST DP  SP RES HXRC
       header = "%02b%05b%05b%06b%06b00000000"

       if data.length > 0
             # Get CSP header and data
             hdr = header % [1, @node.to_i, @remote.to_i, port, 63]
             #puts hdr
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
             #print("Node: ", node.chr, "  Hdr: ", hdr, " Data: ", data)
             msg = [@remote.chr] + hdr + data.split("")

             #msg = bytearray([node,]) + hdr + bytearray(data, "ascii")
             #print("con:", msg)
             @write_socket.send_string(msg.join)
        end

        #sleep(0.25)
    end
  end
 end
