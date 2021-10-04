local Publish = require "lumina.protocol.packet.publish"
local test_utils = require "spec.test_utils"

local function round_trip_encode(v)
    assert(v.fixed_header, debug.traceback())
    local source = test_utils.generate_source(assert(v:encode_packet()))
    local back = assert(Publish.decode_packet(source, v.fixed_header))
    assert.are.same(v, back)
end
describe("Publish", function()
    it("round trip encoding", function()
        local v = Publish.new("topic", 1, 1, "payload")
        round_trip_encode(v)
    end)
    it("encoded_packet_length", function()
        local v = assert(Publish.new("topic", 1, 1, "payload"))
        assert.are.equal(16, v:encoded_packet_length())
    end)
    it("bad qos packet id combo", function()
        local v, err = Publish.new("topic", 1, 0, "payload")
        assert(not v and err, "Expected error in bad packet id/qos")
    end)
    it("no id", function()
        local v = assert(Publish.new("topic", nil, 0, "payload"))
        round_trip_encode(v)
    end)
end)