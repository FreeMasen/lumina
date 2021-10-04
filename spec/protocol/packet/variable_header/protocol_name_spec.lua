local ProtocolName = require "lumina.protocol.packet.variable_header.protocol_name"
local utils = require "spec.test_utils"
describe("ProtocolName", function()
    it("round trip encoding", function()
        local v = assert(ProtocolName.from("mqtt"))
        local bytes= assert(v:encode())
        local back = ProtocolName.decode(utils.generate_source(bytes))
        assert.are.same(v.value, back.value)
    end)
    it("encoded_length", function()
        local v = assert(ProtocolName.from("mqtt"))
        assert.are.equal(6, v:encoded_length())
    end)
end)