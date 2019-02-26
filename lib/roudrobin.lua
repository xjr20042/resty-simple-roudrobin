local gmatch = string.gmatch
local bytes = require "resty.random".bytes
local random = math.random
local randomseed = math.randomseed
local floor = math.floor
local byte = string.byte
local now = ngx.now
local log = ngx.log
local NOTICE = ngx.NOTICE

local _M = {
    _VERSION = '0.01',
}

local mt = { __index = _M }

local faillist = {}

local function seed()
    local a,b,c,d = bytes(4):byte(1, 4)
    return randomseed(a * 0x1000000 + b * 0x10000 + c * 0x100 + d)
end

function _M.new(self, addrs)
    local list = {}
    for v in gmatch(addrs, "[^,]+") do
        list[#list + 1] = v
    end
    local index = floor(random()*100 % #list + 1)

    return setmetatable({list = list, index = index, faillist = faillist}, mt)
end

function _M.get(self)
    local idx = self.index
    local list = self.list
    local flist = self.faillist
    local addr = nil
    local now = now()
    for i=1, #list do
        addr = list[idx % #list + 1]
        local expire = flist[addr]
        if not expire or now > expire then
            break
        else
            idx = idx + 1
            addr = nil
        end
    end
    if not addr then
        log(NOTICE, 'all addresses failed, clean all failure flag')
        for k, _ in pairs(flist) do
            flist[k] = nil
        end
        addr = list[idx % #list + 1]
    end
    self.index = idx + 1
    return addr
end

function _M.set_invalid(self, addr, timeout)
    local timeout = timeout
    if not timeout then
        timeout = 600
    end
    log(NOTICE, "set invalid:" .. addr)
    self.faillist[addr] = timeout + now()
end
seed()
return _M
