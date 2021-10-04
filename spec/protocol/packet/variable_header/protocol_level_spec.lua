local ProtocolLevel = require "lumina.protocol.packet.variable_header.protocol_level"
describe("ProtocolLevel", function()
    it("round trip encoding", function()
        for i=3,5 do
            local v = assert(ProtocolLevel.from(i))
            local bytes= assert(v:encode())
            local back = ProtocolLevel.decode(function()
                return bytes
            end)
            assert.are.same(v, back)
        end
    end)
    it("encoded_length", function()
        local v = assert(ProtocolLevel.from(3))
        assert.are.equal(1, v:encoded_length())
    end)
    it("bad value fails", function()
        local v, err = ProtocolLevel.from(10)
        assert(not v and err)
    end)
end)