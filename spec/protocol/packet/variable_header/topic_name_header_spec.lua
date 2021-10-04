local TopicNameHeader = require "lumina.protocol.packet.variable_header.topic_name"
local TopicName = require "lumina.protocol.topic_name"

local utils = require "spec.test_utils"
describe("TopicNameHeader", function()
    it("round trip encoding", function()
        local name = assert(TopicName.from("topic"))
        local v = assert(TopicNameHeader.from(name))
        local bytes= assert(v:encode())
        local back = TopicNameHeader.decode(utils.generate_source(bytes))
        assert.are.same(v.value, back.value)
    end)
    it("encoded_length", function()
        local v = assert(TopicNameHeader.from(TopicName.from("topic")))
        assert.are.equal(7, v:encoded_length())
    end)
end)