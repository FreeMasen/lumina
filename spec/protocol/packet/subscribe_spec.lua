local Subscribe = require "lumina.protocol.packet.subscribe"
local test_utils = require "spec.test_utils"

local function round_trip_encode(v)
    local source = test_utils.generate_source(assert(v:encode_packet()))
    local back = assert(Subscribe.decode_packet(source, v.fixed_header))
    assert.are.same(v, back)
end
describe("Subscribe", function()
    it("round trip encoding", function()
        local v = assert(Subscribe.new(1, {"sub1", "sub2"}))
        round_trip_encode(v)
    end)
    it("round trip encoding", function()
        local v = assert(Subscribe.new(1, {{ filter = "sub1"}, {filter = "sub2"}}))
        round_trip_encode(v)
    end)
    it("encoded_packet_length", function()
        local v = assert(Subscribe.new(1, {"sub"}))
        assert.are.equal(8, v:encoded_packet_length())
    end)
    it("bad topic filter", function()
        local v, err = Subscribe.new(1, {"sub/#/bad"})
        assert(not v and err)
    end)
    it("bad topic filter table", function()
        local v, err = Subscribe.new(1, {{filter = "sub/#/bad", qos = 1}})
        assert(not v and err)
    end)
    it("topic filter table no filter", function()
        local v, err = Subscribe.new(1, {{qos = 1}})
        assert(not v and err)
    end)
    it("topic filter table not table", function()
        local v, err = Subscribe.new(1, {1})
        assert(not v and err)
    end)
end)