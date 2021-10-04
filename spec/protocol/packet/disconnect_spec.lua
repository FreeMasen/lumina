local Disonnect = require "lumina.protocol.packet.disconnect"
local test_utils = require "spec.test_utils"
local function round_trip_encode(v)
    local source = test_utils.generate_source(assert(v:encode_packet()))
    local back = assert(Disonnect.decode_packet(source, v.fixed_header))
    assert.are.same(v, back)
end
describe("Connect", function()
    it("round trip encoding", function()
        local v = Disonnect.new()
        round_trip_encode(v)
    end)
    it("encoded_packet_length", function()
        local v = assert(Disonnect.new())
        assert.are.equal(0, v:encoded_packet_length())
    end)
end)