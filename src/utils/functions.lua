﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by tomas.
--- DateTime: 2021/12/1 14:31
---

function try(block)
    local main = block.main
    local catch = block.catch
    local finally = block.finally

    assert(main)

    -- try to call it
    local ok, errors = xpcall(main, __G__TRACKBACK__)
    if not ok then
        -- run the catch function
        if catch then
            catch(errors)
        end
    end

    -- run the finally function
    if finally then
        finally(ok, errors)
    end

    -- ok?
    if ok then
        return errors
    end
end

function doCallback(func, ...)
    if type(func) == "function" then
        return func(...)
    end
end

function delayCall(func, delay, ...)
    local handle, args = nil, {...}
    handle = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function()
        stopCall(handle)
        doCallback(func, unpack(args))
    end, delay, false)
    return handle
end

function stopCall(handle)
    if not handle then return end
    cc.Director:getInstance():getScheduler():unscheduleScriptEntry(handle)
end

function isObjectExist(target)
    if target and type(target) ~= 'userdata' then
        return true
    end
    return not tolua.isnull(target)
end

function ternary(condition, trueValue, falseValue)
    if condition then
        return trueValue
    else
        return falseValue
    end
end

function switch(condition, cases, ...)
    assert(type(cases) == 'table', 'options must be table')
    doCallback(cases[condition], ...)
end

function forceRequire(filename)
    local filenames = {
        string.gsub(filename, "%.", "/"),
        string.gsub(filename, "%/", ".")
    }
    for _, filenameTmp in pairs(filenames) do
        package.preload[filenameTmp] = nil
        package.loaded[filenameTmp] = nil
    end
    return require(filename)
end

function hexColor(n)
    local m, r, g, b = 2 ^ 8
    b, n = n % m, math.floor(n / m)
    g, n = n % m, math.floor(n / m)
    r, n = n % m, math.floor(n / m)
    return cc.c3b(r, g, b)
end
