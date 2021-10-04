local TopicFilter = require "lumina.protocol.topic_filter"
local good_names = {"#","sport/tennis/player1","sport/tennis/player1/ranking","sport/tennis/player1/#","#","sport/tennis/#","+","+/tennis/#","sport/+/player1","+/+","$SYS/#","$SYS"}
local bad_names = {"sport/tennis#","sport/tennis/#/ranking","sport+","+sport", "#sport", "", string.rep("a", 0xFFFF1)}

describe("TopicName", function()
    it("ctor success", function()
        for _, topic in ipairs(good_names) do
            assert(TopicFilter.new(topic))
        end
    end)
    it("ctor fails with bad value #a", function()
        for _, topic in ipairs(bad_names) do
            local v, err = TopicFilter.new(topic)
            assert(not v and err, string.format("expected error from bad topic name %q", topic))
        end
    end)
end)