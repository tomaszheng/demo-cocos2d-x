﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by tomas.
--- DateTime: 2021/11/25 14:24
---
local BaseShader = class("BaseShader", BaseComponent)

BaseShader.VERT = "res/shaders/mvp.vsh"
BaseShader.FRAG = "res/shaders/mvp.fsh"

local RESOLUTION_NAME = "u_resolution"

function BaseShader:ctor(node, data)
    BaseShader.super.ctor(self, node, data)
    self:initData(data)
    self:initGLState()
    self:initDefaultUniform()
end

function BaseShader:initData(data)
    data = data or {}
    self.defines = data.defines or {}
    self.vert = data.vert or self.VERT
    self.frag = data.frag or self.FRAG
    self.glState = nil

    -- 图片的大小
    self.resolution = self.node:getTexture():getContentSizeInPixels()
end

function BaseShader:initGLState()
    local vert = cc.FileUtils:getInstance():getStringFromFile(self.vert)
    local frag = cc.FileUtils:getInstance():getStringFromFile(self.frag)
    local program = ccb.Device:getInstance():newProgram(vert, frag)
    self.glState = ccb.ProgramState:new(program)
    program:release()
    self:setGLState()
end

function BaseShader:initDefaultUniform()
    --- TODO override
    self:setResolution(self.resolution)
end

function BaseShader:setVec2(name, v2)
    self:setUniform(name, cc.bytearray.from_vec2(v2))
end

function BaseShader:setVec3(name, v3)
    self:setUniform(name, cc.bytearray.from_vec3(v3))
end

function BaseShader:setVec4(name, v4)
    self:setUniform(name, cc.bytearray.from_vec4(v4))
end

function BaseShader:setFloat(name, f)
    self:setUniform(name, cc.bytearray.from_float(f))
end

function BaseShader:setInt(name, n)
    self:setUniform(name, cc.bytearray.from_int(n))
end

function BaseShader:setUniform(name, v)
    self.glState:setUniform(name, v)
end

function BaseShader:setTexture(name, texId, tex)
    local texLoc = self.glState:getUniformLocation(name)
    if not iskindof(tex, "ccb.TextureBackend") then
        tex = tex:getBackendTexture()
    end
    self.glState:setTexture(texLoc, texId, tex)
end

function BaseShader:setColor3f(name, color)
    local c4f = cc.convertColor(color, "4f")
    self:setVec3(name, cc.vec3(c4f.r, c4f.g, c4f.b))
end

function BaseShader:setColor4f(name, color)
    local c4f = cc.convertColor(color, "4f")
    self:setVec4(name, cc.vec4(c4f.r, c4f.g, c4f.b, c4f.a))
end

function BaseShader:setResolution(resolution)
    self.resolution = resolution
    self:setVec2(RESOLUTION_NAME, cc.p(resolution.width, resolution.height))
end

function BaseShader:setGLState()
    self.node:setProgramState(self.glState)
end

return BaseShader