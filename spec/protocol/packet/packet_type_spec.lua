local PacketType = require "lumina.protocol.packet.packet_type"
local test_utils = require "spec.test_utils"

describe("PacketType", function()
    it("round trip encoding", function()
        for i=1,14 do
            local value = assert(PacketType.from(i))
            local bytes = value:encode()
            local back = assert(PacketType.decode(test_utils.generate_source(bytes)))
            assert.are.same(value, back)
        end
    end)
    it("bad ctor", function()
        for i=1,14 do
            local value, err = PacketType.from(1, "")
            assert(not value and err, "expected error for string flags")
        end
    end)
    it("invalid flags", function()
        for i=1,14 do
            local value, err = PacketType.from(1, 9)
            assert(not value and err, "expected error for invalid flags")
        end
    end)
    describe("bad from ctor", function()
        it("non-integer value", function()
            local value, err = PacketType.from(nil, 9)
            assert(not value and err, "expected error from PacketType.from(nil, ...)")
        end)
        it("value too big", function()
            local value, err = PacketType.from(20, 9)
            assert(not value and err, "expected error from PacketType.from(nil, ...)")
        end)
        it("flags too big", function()
            local value, err = PacketType.from(1, 999)
            assert(not value and err, "expected error from PacketType.from(nil, ...)")
        end)
        it("bad flags for publish", function()
            local value, err = PacketType.from(3, 15)
            assert(not value and err, "expected error from PacketType.from(nil, ...)")
        end)
    end)
end)

