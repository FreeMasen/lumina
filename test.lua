local Client = require "lumina.client"
local cosock = require "cosock"
local utils = require "lumina.utils"

local function generate_client_id()
    return "/MQTT/freemasen/"..string.gsub(tostring(cosock.socket.gettime()), "%.", "/")
end

cosock.spawn(function()
    local c = Client.new()
    local ip = assert(cosock.socket.dns.toip("test.mosquitto.org"))
    print(ip)
    local id = "/MQTT/mosquitto"
    print(utils.table_string(assert(c:connect_mqtt(ip, 1883, id))))
    c:subscribe({"#"}, print)
end)




cosock.run()

