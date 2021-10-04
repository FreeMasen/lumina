local PubComp = require "lumina.protocol.packet.pub_comp"
local test_utils = require "spec.test_utils"
local function round_trip_encode(v)
    local source = test_utils.generate_source(assert(v:encode_packet()))
    local back = assert(PubComp.decode_packet(source, v.fixed_header))
    assert.are.same(v, back)
end
describe("PubAck", function()
    it("round trip encoding", function()
        local v = PubComp.new(1)
        round_trip_encode(v)
    end)
    it("encoded_packet_length", function()
        local v = assert(PubComp.new(1))
        assert.are.equal(2, v:encoded_packet_length())
    end)
end)