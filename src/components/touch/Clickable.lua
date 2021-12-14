﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by tomas.
--- DateTime: 2021/12/14 10:30
--- Content: 点击组件
---
local Touchable = require("src.components.touch.Touchable")
local Clickable = class("Clickable", BaseComponent)

Clickable.STYLES = {
    NONE    = 'none',
    COLOR   = 'color',
    SCALE   = 'scale',
    IMAGE   = 'image'
}

Clickable.TYPES = {
    CLICK = 'click',
    DOUBLE = 'double-click',
    LONG_TOUCH = 'long-touch'
}

Clickable.STATUS = {
    NORMAL = 'normal',
    PRESS = 'press'
}

Clickable.ON_BEGAN = "on-began"
Clickable.ON_MOVED = "on-moved"
Clickable.ON_ENDED = "on-ended"
Clickable.ON_CANCELED = "on-canceled"
Clickable.ON_CLICK = "on-click"
Clickable.ON_DESTROY = "on-destroy"

function Clickable:ctor(node, data)
    cc.load("event").new():bind(self)
    Clickable.super.ctor(self, node, data)
    self:initData(data)
    self:initListener()
end

function Clickable:initData(data)
    data = data or {}
    -- 响应类型
    self.type = data.type or Clickable.TYPES.CLICK
    -- 按下效果
    self.style = data.style or Clickable.STYLES.NONE
    -- 按下缩放系数
    self.scale = data.scale or 1.1
    -- 按下换颜色
    self.color = type(data.color) == "number" and hexColor(data.color) or data.color or hexColor(0xeeeeee)
    -- 按下换图片
    self.images = data.images or {}
    -- 按下有位移，是否可以响应
    self.isMoveLimit = data.isMoveLimit or false
    self.moveThreshold = data.moveThreshold or 5
    -- 两次按下是否有时间间隔
    self.isIntervalLimit = data.isIntervalLimit or false
    self.intervalThreshold = data.intervalThreshold or 0.5
    -- 触发长按的时间阈值
    self.longTouchThreshold = data.longTouchThreshold or 0.5
    -- 响应限制方法
    self.onLimitFunc = data.onLimit
    -- touch的各个阶段
    self.onBeganFunc, self.onMovedFunc = data.onBegan, data.onMoved
    self.onEndedFunc, self.onCanceledFunc = data.onEnded, data.onCanceled
    self.onClickFunc, self.onLongTouchFunc = data.onClick, data.onLongTouch

    self.touchable = self.node:getLuaComponent(Touchable)
    if not self.touchable then
        self.touchable = self.node:addLuaComponent(Touchable, {
            shape = data.shape,
            isLongTouchEnabled = self.type == Clickable.TYPES.LONG_TOUCH,
            longTouchThreshold = data.longTouchThreshold,
        })
    end

    self.prevClickTime = 0
    self.touchBeganPosition = cc.p(0, 0)
    self.touchCurrPosition = cc.p(0, 0)
    self.defaultScale = self.node:getScale()
    self.defaultColor = self.node:getColor()
    self.action = nil
    self.longTouchTimer = nil
end

function Clickable:initListener()
    self.touchable:addEventListener(Touchable.ON_BEGAN, handler(self, self.onTouchBegan))
    self.touchable:addEventListener(Touchable.ON_MOVED, handler(self, self.onTouchMoved))
    self.touchable:addEventListener(Touchable.ON_ENDED, handler(self, self.onTouchEnded))
    self.touchable:addEventListener(Touchable.ON_CANCELED, handler(self, self.onTouchCanceled))
    self.touchable:addEventListener(Touchable.ON_LONG_TOUCH, handler(self, self.onLongTouch))
    self.touchable:addEventListener(Touchable.ON_DESTROY, handler(self, self.onTouchDestroy))
end

function Clickable:onTouchBegan(event)
    self:resetToDefault()

    if self.style == Clickable.STYLES.COLOR then
        self.node:setColor(self.color)
    elseif self.style == Clickable.STYLES.SCALE then
        self.action = self.node:runAction(cc.EaseSineOut:create(cc.ScaleTo:create(0.15, self.defaultScale * self.scale)))
    elseif self.style == Clickable.STYLES.IMAGE then
        self:updateTexture(Clickable.STATUS.PRESS)
    end

    local position = event.position
    self.touchBeganPosition = position
    self.touchCurrPosition = position

    self:dispatchEvent({name = Clickable.ON_BEGAN, sender = self, position = position})
    doCallback(self.onBeganFunc, {sender = self, position = position})
end

function Clickable:onLongTouch(event)
    local position, isHit = event.position, event.isHit
    if isHit and not self:isClickLimiting() then
        self:dispatchEvent({name = Clickable.ON_LONG_TOUCH, sender = self, position = position})
        doCallback(self.onLongTouchFunc, {sender = self, position = position})
    end
end

function Clickable:onTouchMoved(event)
    local position = event.position
    self.touchCurrPosition = event.position

    self:dispatchEvent({name = Clickable.ON_MOVED, sender = self, position = position})
    doCallback(self.onMovedFunc, {sender = self, position = position})
end

function Clickable:onTouchEnded(event)
    self:resetToDefault(false)

    local position, isHit, isValid = event.position, event.isHit, false
    self.touchCurrPosition = position

    if isHit and not self:isClickLimiting() then
        isValid = true
        self.prevClickTime = os.clock()
        self:dispatchEvent({name = Clickable.ON_CLICK, sender = self, position = position})
        doCallback(self.onClickFunc, {sender = self, position = position})
    end

    self:dispatchEvent({name = Clickable.ON_ENDED, sender = self, position = position, isValid = isValid})
    doCallback(self.onEndedFunc, {sender = self, position = position, isValid = isValid})
end

function Clickable:onTouchCanceled()
    self:resetToDefault(false)

    self:dispatchEvent({ name = Clickable.ON_CANCELED, sender = self})
    doCallback(self.onCanceledFunc, {sender = self})
end

function Clickable:onTouchDestroy()
    self:destroy()
end

function Clickable:isClickLimiting()
    if self.isIntervalLimit then
        if os.clock() - self.prevClickTime < self.intervalThreshold then
            return true
        end
    end
    if self.isMoveLimit then
        local distance = cc.pGetDistance(self.touchBeganPosition, self.touchCurrPosition)
        if distance > self.moveThreshold then
            return true
        end
    end
    if self.onLimitFunc then
        return doCallback(self.onLimitFunc, self.touchCurrPosition)
    end
    return false
end

function Clickable:resetToDefault(isFromBegin)
    self:stopAction()
    if self.style == Clickable.STYLES.COLOR then
        self.node:setColor(self.defaultColor)
    elseif self.style == Clickable.STYLES.SCALE then
        if isFromBegin then
            self.node:setScale(self.defaultScale)
        else
            self.action = self.node:runAction(cc.EaseSineOut:create(cc.ScaleTo:create(0.15, self.defaultScale)))
        end
    elseif self.style == Clickable.STYLES.IMAGE then
        self:updateTexture(Clickable.STATUS.NORMAL)
    end
end

function Clickable:updateTexture(status)
    local path = status == Clickable.STATUS.NORMAL and self.images[1] or self.images[2]
    local resType = UIUtils.getTextureResType(path)
    if iskindof(self.node, "cc.Sprite") then
        if resType == ccui.TextureResType.localType then
            self.node:setTexture(path)
        else
            self.node:setSpriteFrame(path)
        end
    elseif iskindof(self.node, "ccui.ImageView") or iskindof(target, "ccui.Sprite9Scale") then
        self.node:loadTexture(path, resType)
    elseif iskindof(self.node, "ccui.Button") then
        if status == "normal" then
            self.node:loadTextureNormal(path, resType)
        else
            self.node:loadTexturePressed(path, resType)
        end
    end
end

function Clickable:stopAction()
    if isObjectExist(self.action) then
        self.node:stopAction(self.action)
        self.action = nil
    end
end

function Clickable:setLimitFunc(func)
    self.onLimitFunc = func
end

function Clickable:setOnBegan(func)
    if func and type(func) == "function" then
        self.onBeganFunc = func
    end
end

function Clickable:setOnMoved(func)
    if func and type(func) == "function" then
        self.onMovedFunc = func
    end
end

function Clickable:setOnEnded(func)
    if func and type(func) == "function" then
        self.onEndedFunc = func
    end
end

function Clickable:setOnCanceled(func)
    if func and type(func) == "function" then
        self.onCanceledFunc = func
    end
end

function Clickable:onDestroy()
    self:stopAction()
    self:dispatchEvent({name = Clickable.ON_DESTROY})
end

return Clickable