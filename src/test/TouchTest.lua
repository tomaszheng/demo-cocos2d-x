﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by tomas.
--- DateTime: 2021/12/14 17:04
---
local Clickable = require("src.components.touch.Clickable")
local Touchable = require("src.components.touch.Touchable")
local Brightness = require("src.components.shaders.Brightness")
local TouchTest = class("TouchTest", BaseNode)

function TouchTest:ctor()
    --self:testOutline()
    --self:testBlur()
    self:testTouchable()
    self:testClickable()
end

function TouchTest:testTouchable()
    local pos = cc.p(display.cx - 150, display.cy)
    local avatar = cc.Sprite:create("res/bg_avatar_default.png")
                     :move(pos)
                     :addTo(self)
    avatar:addLuaComponent(Brightness, {
        brightness = 0.8,
    })

    local offsetY = 50
    avatar:addLuaComponent(Touchable, {
        isLongTouchEnabled = true,
        longTouchThreshold = 0.6,
        onBegan = function(event)
            printLog("TestTouchable", "x=%.2f, y=%.2f", event.position.x, event.position.y)
        end,
        onMoved = function(event)
            printLog("TestTouchable", "x=%.2f, y=%.2f", event.position.x, event.position.y)
        end,
        onEnded = function(event)
            avatar:runAction(cc.MoveTo:create(0.2, pos))
            print("-------------------ended")
        end,
        onLongTouch = function(event)
            if event.isHit then
                local p = cc.p(pos.x, pos.y + offsetY)
                avatar:runAction(cc.EaseIn:create(cc.MoveTo:create(0.2, p), 0.7))
                print("------------long touch")
            end
        end
    })
end

function TouchTest:testClickable()
    local pos = cc.p(display.cx + 150, display.cy)
    local avatar = cc.Sprite:create("res/bg_avatar_default.png")
                     :move(pos)
                     :addTo(self)

    local offsetY = 50
    avatar:addLuaComponent(Clickable, {
        type = Clickable.TYPES.LONG_TOUCH,
        isMoveLimit = true,
        moveThreshold = 10,
        onBegan = function(event)
            printLog("TestTouchable - onBegan", "x=%.2f, y=%.2f", event.position.x, event.position.y)
        end,
        onMoved = function(event)
            printLog("TestTouchable - onMoved", "x=%.2f, y=%.2f", event.position.x, event.position.y)
        end,
        onEnded = function(event)
            --avatar:runAction(cc.MoveTo:create(0.2, pos))
            print("-------------------ended")
        end,
        onClick = function(event)
            printLog("TestTouchable - onClick", "x=%.2f, y=%.2f", event.position.x, event.position.y)
        end,
        onLongTouch = function(event)
            local p = cc.p(pos.x, pos.y + offsetY)
            --avatar:runAction(cc.EaseIn:create(cc.MoveTo:create(0.2, p), 0.7))
            print("------------long touch")
        end,
        interaction = function(status, isFromBegan)
            if status == Clickable.STATUS.NORMAL then
                avatar:runAction(cc.EaseIn:create(cc.MoveTo:create(0.2, pos), 0.7))
            else
                local p = cc.p(pos.x, pos.y + offsetY)
                avatar:runAction(cc.EaseIn:create(cc.MoveTo:create(0.2, p), 0.7))
            end
        end
    })
end

return TouchTest