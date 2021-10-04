local KeepAlive = require "lumina.protocol.packet.variable_header.keep_alive"
describe("KeepAlive", function()
    it("round trip encoding", function()
        for _, i in ipairs({0,0xFFFF, math.floor(0xFFFF/2), math.floor(0xFFFF/4), math.floor(0xFFFF/8)}) do
            local v = assert(KeepAlive.from(i))
            local bytes= assert(v:encode())
            local back = KeepAlive.decode(function()
                return bytes
            end)
            assert.are.same(v, back)
        end
    end)
    it("encoded_length", function()
        local v = assert(KeepAlive.from(1))
        assert.are.equal(2, v:encoded_length())
    end)
end)