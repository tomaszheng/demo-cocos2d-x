﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by tomas.
--- DateTime: 2021/11/24 11:31
---
local EventManager = class("EventManager", Singleton)

function EventManager:ctor()
    cc.load("event").new():bind(self)
end

return EventManager:getInstance()