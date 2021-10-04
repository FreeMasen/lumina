local ConnFlags = require "lumina.protocol.packet.variable_header.connect_flags"
-- pub user_name: bool,
-- pub password: bool,
-- pub will_retain: bool,
-- pub will_qos: u8,
-- pub will_flag: bool,
-- pub clean_session: bool,
-- // We never use this, but must decode because brokers must verify it's zero per [MQTT-3.1.2-3]
-- pub reserved: bool,
describe("ConnectFlags", function()
    describe("round trip encoding", function()
        it("all_false", function ()
            local v = ConnFlags.new(false, false, false, 0, false, false, false)
            local bytes = v:encode()
            local back = ConnFlags.decode(function()
                return bytes
            end)
            assert.are.same(v, back)
        end)
        it("all_true", function ()
            local v = ConnFlags.new(true, true, true, 0, true, true, true)
            local bytes = v:encode()
            local back = ConnFlags.decode(function()
                return bytes
            end)
            assert.are.same(v, back)
        end)
        it("qos", function ()
            for i=1,3 do
                local v = assert(ConnFlags.new(true, true, true, i, true, true, true))
                local bytes = v:encode()
                local back = assert(ConnFlags.decode(function()
                    return bytes
                end))
                assert.are.same(v, back)
            end
        end)
        it("empty source", function()
            local v, err = ConnFlags.decode(function()
                return nil, "eof"
            end)
            assert(not v and err, "expected error from empty source")
        end)
        it("encoded_length", function()
            local v = assert(ConnFlags.new(true, true, true, 0, true, true, true))
            assert.are.equal(1, v:encoded_length())
        end)
    end)
end)