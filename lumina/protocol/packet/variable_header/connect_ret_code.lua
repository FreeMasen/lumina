
local known_names = {
    [0x00] = "CONNECTION_ACCEPTED",
    [0x01] = "UNACCEPTABLE_PROTOCOL_VERSION",
    [0x02] = "IDENTIFIER_REJECTED",
    [0x03] = "SERVICE_UNAVAILABLE",
    [0x04] = "BAD_USER_NAME_OR_PASSWORD",
    [0x05] = "NOT_AUTHORIZED",
}

--- @class ConnReturnCode
--- @field value integer
--- @field is_reserved boolean
local ConnReturnCode = {
    CONNECTION_ACCEPTED = 0x00,
    UNACCEPTABLE_PROTOCOL_VERSION = 0x01,
    IDENTIFIER_REJECTED = 0x02,
    SERVICE_UNAVAILABLE = 0x03,
    BAD_USER_NAME_OR_PASSWORD = 0x04,
    NOT_AUTHORIZED = 0x05,
}
ConnReturnCode.__index = ConnReturnCode
ConnReturnCode.__tostring = function(t)
    return require "lumina.utils".packet_string("ConnReturnCode", t)
end

function ConnReturnCode.from(value)
    return setmetatable({
        value = value,
        is_reserved = value > 5
    }, ConnReturnCode)
end

function ConnReturnCode.decode(source)
    local byte, err = source(1)
    if not byte then return nil, err end
    return ConnReturnCode.from(string.byte(byte))
end

function ConnReturnCode:encode()
    return string.char(self.value)
end

function ConnReturnCode:encoded_length()
    return 1
end

return ConnReturnCode
