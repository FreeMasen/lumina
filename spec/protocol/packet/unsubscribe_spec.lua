local Unsubscribe = require "lumina.protocol.packet.unsubscribe"
local test_utils = require "spec.test_utils"

local function round_trip_encode(v)
    local source = test_utils.generate_source(assert(v:encode_packet()))    
    local back = assert(Unsubscribe.decode_packet(source, v.fixed_header))
    assert.are.same(v, back)
end
describe("Unsubscribe", function()
    it("round trip encoding #p", function()
        local v = assert(Unsubscribe.new(1, {"unsub1"}))
        round_trip_encode(v)
    end)
    it("encoded_packet_length", function()
        local v = assert(Unsubscribe.new(1, {"unsub2"}))
        assert.are.equal(10, v:encoded_packet_length())
    end)
end)