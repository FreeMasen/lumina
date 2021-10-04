local Packet = require "lumina.protocol.packet"
local lfs = require "lfs"
local test_utils = require "spec.test_utils"

describe("Packet", function()
    describe("flat files #f", function()
        local base_path = "test-messages"
        for file_path in lfs.dir(base_path) do
            if file_path == '.' or file_path == '..' then goto continue end
            it(file_path, function()
                local full_path = base_path .. "/" .. file_path
                local file = assert(io.open(base_path .. "/" .. file_path), "error opening " .. full_path)
                local bytes = assert(file:read("a"), "error reading " .. full_path)
                local source = test_utils.generate_source(bytes)
                local packet = assert(Packet.decode(source))
                local back = assert(packet:encode())
                local source2 = test_utils.generate_source(back)
                local second = assert(Packet.decode(source2))
                assert.are.same(packet, second)
                assert
                .message(string.format("%q\nerror matching bytes\n%s\n%s",
                    full_path,
                    "t:"..test_utils.debug_bytes(back),
                    "o:"..test_utils.debug_bytes(bytes)
                ))
                .are.same(bytes, back)
            end)
            ::continue::
        end
    end)
end)
