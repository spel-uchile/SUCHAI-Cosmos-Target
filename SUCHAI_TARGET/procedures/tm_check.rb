TARGET='SUCHAI_TARGET'

cmd("#{TARGET}", "com_send_cmd", "node" => 10, "next" =>"obc_get_sensors")
cmd("#{TARGET}", "com_send_cmd", "node" => 10, "next" =>"tm_send_all 0")