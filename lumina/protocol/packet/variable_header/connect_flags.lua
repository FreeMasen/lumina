--- @class ConnectFlags
--- @field user_name boolean
--- @field password boolean
--- @field will_retain boolean
--- @field will_qos integer
--- @field will_flag boolean
--- @field clean_session boolean
--- @field reserved boolean
local ConnectFlags = {}
ConnectFlags.__index = ConnectFlags
ConnectFlags.__tostring = function(t)
    return require "lumina.utils".packet_string("ConnectFlags", t)
end

function ConnectFlags.new(username, password, will_retain, will_qos, will_flag, clean_session, reserved)
    return setmetatable({
        username = username,
        password = password,
        will_retain = will_retain,
        will_qos = will_qos,
        will_flag = will_flag,
        clean_session = clean_session,
        reserved = reserved,
    }, ConnectFlags)
end
function ConnectFlags.empty()
    return ConnectFlags.new(false, false, false, 0, false, false, false)
end

function ConnectFlags.decode(source)
    local byte, err = source(1)
    if not byte then
        return nil, err
    end
    byte = string.byte(byte)
    return ConnectFlags.new(
        byte & 128 ~= 0,
        byte & 64 ~= 0,
        byte & 32 ~= 0,
        (byte & 24) >> 3,
        byte & 4 ~= 0,
        byte & 2 ~= 0,
        byte & 1 ~= 0
    )
end

function ConnectFlags:encode()
    local ret = ((self.username and 1) or 0) << 7
    | ((self.password and 1) or 0) << 6
    | ((self.will_retain and 1) or 0) << 5
    | self.will_qos << 3
    | ((self.will_flag and 1) or 0) << 2
    | ((self.clean_session and 1) or 0) << 1
    | ((self.reserved and 1) or 0)
    
    return string.char(ret)
end

function ConnectFlags:encoded_length()
    return 1
end

return ConnectFlags
