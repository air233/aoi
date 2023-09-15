local AreaAOI = require "AreaAOI"


local AOI = BaseClass()

function AOI:__init(config)
    self.aoiService = AreaAOI.New(config)

    print("create aoiServer:",self.aoiService)
end

--areaRange: 格子范围
function AOI:GetObjsByPos(pos,areaRange)
    return self.aoiService:GetObjsByPos(pos,areaRange)
end

--range: 距离范围
function AOI:GetObjsByPosRange(pos,range)
    return self.aoiService:GetObjsByPosForRange(pos,range)
end

function AOI:GetObjsByRangeConfig(pos,rangconfig)
    return self.aoiService:GetObjsByRangeConfig(pos,rangconfig)
end

function AOI:GetObjsByType(pos,range,type)
    return self.aoiService:GetObjsByPosAndType(pos,range,type)
end

function AOI:GetWatcher()
    self.aoiService:GetWatcher()
end

function AOI:AddObject(obj,pos)
    self.aoiService:AddObject(obj,pos)
end

function AOI:RemoveObject(obj,pos)
    self.aoiService:RemoveObject(obj,pos)
end

function AOI:UpdateObject(obj,oldPos,newPos)
    self.aoiService:UpdateObject(obj,oldPos,newPos)
end

function AOI:AddWatcher(watch,pos,range)
    self.aoiService:AddWatcher(watch,pos,range)
end

function AOI:RemoveWatcher(watch,pos,range)
    self.aoiService:RemoveWatcher(watch,pos,range)
end

function AOI:UpdateWatcher(watch,oldPos,newPos,oldRange,newRange)
    self.aoiService:UpdateWatcher(watch,oldPos,newPos,oldRange,newRange)
end

return AOI
