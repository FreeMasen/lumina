
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

function ConnReturnCode.is_ret_code_accept(ret_code)
    if ret_code == 0 then return 1 end
    if ret_code == ConnReturnCode.UNACCEPTABLE_PROTOCOL_VERSION then
        return nil, "UNACCEPTABLE PROTOCOL VERSION"
    end
    if ret_code == ConnReturnCode.IDENTIFIER_REJECTED then
        return nil, "IDENTIFIER REJECTED"
    end
    if ret_code == ConnReturnCode.SERVICE_UNAVAILABLE then
        return nil, "SERVICE UNAVAILABLE"
    end
    if ret_code == ConnReturnCode.BAD_USER_NAME_OR_PASSWORD then
        return nil, "BAD USER NAME OR PASSWORD"
    end
    if ret_code == ConnReturnCode.NOT_AUTHORIZED then
        return nil, "NOT AUTHORIZED"
    end
    return nil, "UNKNOWN RETURN CODE " .. tostring(ret_code)
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
