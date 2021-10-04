local utils = require "lumina.utils"


describe("encode string", function()
    it("failes to encode too long string", function()
        local s, e = utils.encode_string(
            string.rep("*", 65536)
        )
    end)
end)