local ConnReturnCode = require "lumina.protocol.packet.variable_header.connect_ret_code"
describe("ConnReturnCode", function()
    it("round trip encoding", function()
        for i=0,5 do
            local v = ConnReturnCode.from(i)
            local bytes = v:encode()
            local back = ConnReturnCode.decode(function()
                return bytes
            end)
            assert.are.same(v, back)
        end
    end)
    it("encoded_length", function()
        local v = assert(ConnReturnCode.from(1))
        assert.are.equal(1, v:encoded_length())
    end)
end)