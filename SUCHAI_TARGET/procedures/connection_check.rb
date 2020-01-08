TARGET='SUCHAI_TARGET'

cmd("#{TARGET}", "com_ping", "node" => 10)
cmd("#{TARGET}", "com_ping", "node" => 1)
cmd("#{TARGET}", "com_send_cmd", "node" => 1, "next" =>"tm_send_status 10")