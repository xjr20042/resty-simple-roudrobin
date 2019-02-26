local sleep = ngx.sleep
local rb = require "roudrobin"
local spawn = ngx.thread.spawn
local wait = ngx.thread.wait


local host = 'addr1,addr2,addr3,addr4'

local function fun1()
    local bln = rb:new(host)

    for i=1, 10000 do 
        local s = bln:get()
        print('fun1 get ' .. s)
        if i%2  == 0 then
            bln:set_invalid(s, 10)
        end
        sleep(1)
    end
end

local function fun2()
    local bln = rb:new(host)

    for i=1, 10000 do 
        local s = bln:get()
        print('fun2 get ' .. s)
        sleep(1)
    end
end

local function fun3()
    for i=1, 10000 do 
        local bln = rb:new(host)
        local s = bln:get()
        print('fun3 get ' .. s)
        sleep(1)
    end
end
local threads = {
    spawn(fun1),
    spawn(fun2),
    spawn(fun3)
}
for i = 1, #threads do
    wait(threads[i])
end


