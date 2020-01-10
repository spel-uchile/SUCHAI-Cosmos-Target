TARGET='SUCHAI_TARGET'

cmd("#{TARGET}", "com_send_cmd", "node" => 10, "next" =>"tm_send_all 12 10")