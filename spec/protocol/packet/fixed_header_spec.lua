local PacketType = require "lumina.protocol.packet.packet_type"
local FixedHeader = require "lumina.protocol.packet.fixed_header"
local test_utils  = require "spec.test_utils"

local samples = {{2097152, 4},{16384, 3},{128, 2}, {1, 1}}

describe("FixedHeader", function()
    it("round trip encoding", function()
        for _, test in ipairs(samples) do
            local pt = assert(PacketType.from(1, 0))
            local fh = assert(FixedHeader.from(pt, test[1]))
            local bytes = fh:encode()
            local source = test_utils.generate_source(bytes)
            local back = assert(FixedHeader.decode(source))
            assert.are.same(fh, back)
        end
    end)
    it("encoded lengths", function()
        for _, test in ipairs(samples) do
            local fh = assert(FixedHeader.from(PacketType.from(1, 0), test[1]))
            assert(fh:encoded_length(), test[2])
        end
    end)
    it("invalid length errs #p", function()
        local raw_header = string.char(
            1 << 4,255,255,255,255,255
        )
        local fh, err
        fh, err = FixedHeader.decode(
            test_utils.generate_source(raw_header)
        )
        assert(not fh and err, "Expected error from 5 byte header length")
        fh, err = FixedHeader.decode(
            test_utils.generate_source(raw_header)
        )
    end)
    it("reverse round trip", function()
        local msg = string.char(0x10, 0xC1, 0x02)
        local source = test_utils.generate_source(msg)
        local fh= assert(FixedHeader.decode(source))
        assert.are.same(PacketType.connect(), fh.packet_type)
        assert.are.same(321, fh.remaining_length)
        assert.are.equal(msg, fh:encode())
    end)
end)
