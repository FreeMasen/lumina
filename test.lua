<<<<<<< HEAD
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
    print(utils.table_string(assert(c:connect_mqtt(ip, 1883, generate_client_id()))))
    c:subscribe({"#"}, print)
end)
=======
-- local Client = require "lumina.client"
-- local cosock = require "cosock"
-- local utils = require "lumina.utils"

-- local function generate_client_id()
--     return "/MQTT/freemasen/"..string.gsub(tostring(cosock.socket.gettime()), "%.", "/")
-- end

-- cosock.spawn(function()
--     local c = Client.new()
--     local ip = assert(cosock.socket.dns.toip("test.mosquitto.org"))
--     print(ip)
--     print(utils.table_string(assert(c:connect_mqtt(ip, 1883, generate_client_id()))))
--     c:subscribe({"#"}, print)
-- end)
>>>>>>> 7ec7b1a... parsing works!




<<<<<<< HEAD
cosock.run()

=======
-- cosock.run()

local f = assert(io.open("test-messages/publish-04.mqtt"))
local c = assert(f:read('a'))
print(c:byte(2, 3))
print(c:sub(4, 15))
>>>>>>> 7ec7b1a... parsing works!

