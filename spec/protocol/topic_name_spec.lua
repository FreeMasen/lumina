local TopicName = require "lumina.protocol.topic_name"
describe("TopicName", function()
    it("ctor fails with bad value", function()
        local v, err = TopicName.from("bad#topic")
        assert(not v and err, "expected error from bad topic name")
    end)
end)