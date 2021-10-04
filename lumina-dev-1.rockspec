package = "lumina"
version = "dev-1"
source = {
   url = "*** please add URL for source tarball, zip or repository here ***"
}
description = {
   summary = "",
   detailed = "",
   homepage = "*** please enter a project homepage ***",
   license = "*** please specify a license ***"
}
dependencies = {
   "lua >= 5.3",
   "cosock >= 0.2-1"
}
build = {
   type = "builtin",
   modules = {
      lumina = "lumina/init.lua",
<<<<<<< HEAD
      ["lumina.protocol.packet"] = "lumina/protocol/packet.lua",
=======
      ["lumina.protocol.packet"] = "lumina/protocol/packet/init.lua",
>>>>>>> 7ec7b1a... parsing works!
      ["lumina.protocol.packet.connack"] = "lumina/protocol/packet/connack.lua",
      ["lumina.protocol.packet.connect"] = "lumina/protocol/packet/connect.lua",
      ["lumina.protocol.packet.disconnect"] = "lumina/protocol/packet/disconnect.lua",
      ["lumina.protocol.packet.fixed_header"] = "lumina/protocol/packet/fixed_header.lua",
      ["lumina.protocol.packet.packet_type"] = "lumina/protocol/packet/packet_type.lua",
      ["lumina.protocol.packet.pingreq"] = "lumina/protocol/packet/pingreq.lua",
      ["lumina.protocol.packet.pingres"] = "lumina/protocol/packet/pingres.lua",
      ["lumina.protocol.packet.pub_ack"] = "lumina/protocol/packet/pub_ack.lua",
      ["lumina.protocol.packet.pub_comp"] = "lumina/protocol/packet/pub_comp.lua",
      ["lumina.protocol.packet.pub_rec"] = "lumina/protocol/packet/pub_rec.lua",
      ["lumina.protocol.packet.pub_rel"] = "lumina/protocol/packet/pub_rel.lua",
      ["lumina.protocol.packet.publish"] = "lumina/protocol/packet/publish.lua",
      ["lumina.protocol.packet.suback"] = "lumina/protocol/packet/suback.lua",
      ["lumina.protocol.packet.subscribe"] = "lumina/protocol/packet/subscribe.lua",
      ["lumina.protocol.packet.unsuback"] = "lumina/protocol/packet/unsuback.lua",
      ["lumina.protocol.packet.unsubscribe"] = "lumina/protocol/packet/unsubscribe.lua",
      ["lumina.protocol.packet.variable_header.conn_ack_flags"] = "lumina/protocol/packet/variable_header/conn_ack_flags.lua",
      ["lumina.protocol.packet.variable_header.connect_flags"] = "lumina/protocol/packet/variable_header/connect_flags.lua",
      ["lumina.protocol.packet.variable_header.connect_ret_code"] = "lumina/protocol/packet/variable_header/connect_ret_code.lua",
      ["lumina.protocol.packet.variable_header.keep_alive"] = "lumina/protocol/packet/variable_header/keep_alive.lua",
      ["lumina.protocol.packet.variable_header.packet_id"] = "lumina/protocol/packet/variable_header/packet_id.lua",
      ["lumina.protocol.packet.variable_header.protocol_level"] = "lumina/protocol/packet/variable_header/protocol_level.lua",
      ["lumina.protocol.packet.variable_header.protocol_name"] = "lumina/protocol/packet/variable_header/protocol_name.lua",
      ["lumina.protocol.packet.variable_header.topic_name"] = "lumina/protocol/packet/variable_header/topic_name.lua",
      ["lumina.utils"] = "lumina/utils.lua",
   }
}
