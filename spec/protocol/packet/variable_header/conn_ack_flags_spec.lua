local ConnAckFlags = require "lumina.protocol.packet.variable_header.conn_ack_flags"
describe("ConnAckFlags", function()
    it("round trip encoding", function()
        for i=1,2 do
            local v = assert(ConnAckFlags.new(i == 1))
            local bytes = v:encode()
            local back = ConnAckFlags.decode(function()
                return bytes
            end)
            assert.are.same(v, back)
        end
    end)
    it("empty source", function()
        local v, err = ConnAckFlags.decode(function()
            return nil, "eof"
        end)
        assert(not v and err, "expected error on empty source")
    end)
    it("bad source value", function()
        local v, err = ConnAckFlags.decode(function()
            return "3"
        end)
        assert(not v and err, "expected error on empty source")
    end)
    it("encoded_length", function()
        local v = assert(ConnAckFlags.new(true))
        assert.are.equal(1, v:encoded_length())
    end)
end)