﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by tomas.
--- DateTime: 2021/6/2 10:34
---

require "src.config"
require "src.cocos.init"

-- extends
require("src.extends.io")
require("src.extends.math")
require("src.extends.string")
require("src.extends.table")

require("src.utils.functions")

-- base
Singleton = require("src.base.Singleton")
BaseNode = require("src.base.BaseNode")
BaseScene = require("src.base.BaseScene")
BaseComponent = require("src.base.BaseComponent")

-- managers
EventManager = require("src.managers.EventManager")

-- utils
Log = require("src.utils.Log")
loge, logi = Log.error, Log.info
UIUtils = require("src.utils.UIUtils")
ShotUtils = require("src.utils.ShotUtils")
GeometryConstants = require 'src.utils.geometry.GeometryConstants'
GeometryUtils = require('src.utils.geometry.GeometryUtils')
DistanceUtils = require('src.utils.geometry.DistanceUtils')
IntersectionUtils = require('src.utils.geometry.IntersectionUtils')

-- components

-- widgets
GraphicsNode = require('src.widgets.GraphicsNode')
RubberBand = require('src.widgets.RubberBand')

cc.disable_global()