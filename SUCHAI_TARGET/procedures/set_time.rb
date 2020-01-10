TARGET='SUCHAI_TARGET'
TIME=Time.now.to_i+1
cmd("#{TARGET}","com_send_cmd","node" => 10, "next" => "obc_set_time #{TIME}")
