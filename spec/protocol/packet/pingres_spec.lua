local PingRes = require "lumina.protocol.packet.ping_res"
local test_utils = require "spec.test_utils"
local function round_trip_encode(v)
    local source = test_utils.generate_source(assert(v:encode_packet()))
    local back = assert(PingRes.decode_packet(source, v.fixed_header))
    assert.are.same(v, back)
end
describe("PingRes", function()
    it("round trip encoding", function()
        local v = PingRes.new()
        round_trip_encode(v)
    end)
    it("encoded_packet_length", function()
        local v = assert(PingRes.new())
        assert.are.equal(0, v:encoded_packet_length())
    end)
end)