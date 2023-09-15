local Area = require "Area"

--区域AOI管理

--pos 格子坐标
--areaRange 格子范围
--max 当前格子大小
function getPosLimit(pos,areaRange,max)
    local startPos = {x = 0 , y = 0}
    local endPos = {x = 0,y = 0}

    if pos.x - areaRange < 0 then
        startPos.x = 0
        endPos.x = 2* areaRange
    elseif pos.x + areaRange > max.x then
        endPos.x = max.x
        startPos.x = max.x - 2 * areaRange
    else
        startPos.x = pos.x - areaRange
        endPos.x = pos.x + areaRange
    end

    if pos.y - areaRange < 0 then
        startPos.y = 0
        endPos.y = 2* areaRange
    elseif pos.y + areaRange > max.y then
        endPos.y = max.y
        startPos.y = max.y - 2 * areaRange
    else
        startPos.y = pos.y - areaRange
        endPos.y = pos.y + areaRange
    end

    if startPos.x < 0 then
        startPos.x = 0
    end
    if endPos.x < 0 then
        endPos.x = 0
    end

    if startPos.y < 0 then
        startPos.y = 0
    end

    if endPos.y < 0 then
        endPos.y = 0
    end

    return {startPos = startPos, endPos = endPos}
end

function getPosLimit2(pos,areaRangeX,areaRangeY,max)
    local startPos = {x = 0 , y = 0}
    local endPos = {x = 0,y = 0}
    if pos.x - areaRangeX < 0 then
        startPos.x = 0
        endPos.x = 2* areaRangeX
    elseif pos.x + areaRangeX > max.x then
        endPos.x = max.x
        startPos.x = max.x - 2 * areaRangeX
    else
        startPos.x = pos.x - areaRangeX
        endPos.x = pos.x + areaRangeX
    end

    if pos.y - areaRangeY < 0 then
        startPos.y = 0
        endPos.y = 2* areaRangeY
    elseif pos.y + areaRangeY > max.y then
        endPos.y = max.y
        startPos.y = max.y - 2 * areaRangeY
    else
        startPos.y = pos.y - areaRangeY
        endPos.y = pos.y + areaRangeY
    end

    if startPos.x < 0 then
        startPos.x = 0
    end
    if endPos.x < 0 then
        endPos.x = 0
    end

    if startPos.y < 0 then
        startPos.y = 0
    end

    if endPos.y < 0 then
        endPos.y = 0
    end

    return {startPos = startPos, endPos = endPos}
end

--pos 实际坐标
--areaRange 范围
--max 当前区域大小
function getPosLimitForRange(pos,rang,max)
    local startPos = {x = 0 , y = 0}
    local endPos = {x = 0,y = 0}

    if pos.x - rang < 0 then
        startPos.x = 0
        endPos.x = 2* rang
    elseif pos.x + rang > max.width then
        endPos.x = max.width
        startPos.x = max.width - 2 * rang
    else
        startPos.x = pos.x - rang
        endPos.x = pos.x + rang
    end

    if pos.y - rang < 0 then
        startPos.y = 0
        endPos.y = 2* rang
    elseif pos.y + rang > max.height then
        endPos.y = max.height
        startPos.y = max.height - 2 * rang
    else
        startPos.y = pos.y - rang
        endPos.y = pos.y + rang
    end

    if startPos.x < 0 then
        startPos.x = 0
    end
    if endPos.x < 0 then
        endPos.x = 0
    end

    if startPos.y < 0 then
        startPos.y = 0
    end

    if endPos.y < 0 then
        endPos.y = 0
    end

    return {startPos = startPos, endPos = endPos}
end

function getPosLimitForRange2(pos,rangX,rangY,max)
    local startPos = {x = 0 , y = 0}
    local endPos = {x = 0,y = 0}

    if pos.x - rangX < 0 then
        startPos.x = 0
        endPos.x = 2 * rangX
    elseif pos.x + rangX > max.width then
        endPos.x = max.width
        startPos.x = max.width - 2 * rangX
    else
        startPos.x = pos.x - rangX
        endPos.x = pos.x + rangX
    end

    if pos.y - rangY < 0 then
        startPos.y = 0
        endPos.y = 2* rangY
    elseif pos.y + rangY > max.height then
        endPos.y = max.height
        startPos.y = max.height - 2 * rangY
    else
        startPos.y = pos.y - rangY
        endPos.y = pos.y + rangY
    end

    if startPos.x < 0 then
        startPos.x = 0
    end
    if endPos.x < 0 then
        endPos.x = 0
    end

    if startPos.y < 0 then
        startPos.y = 0
    end

    if endPos.y < 0 then
        endPos.y = 0
    end

    return {startPos = startPos, endPos = endPos}
end

function isInRect(pos,limitPos)
    return (
        pos.x >= limitPos.startPos.x and pos.x <= limitPos.endPos.x and
        pos.y >= limitPos.startPos.y and pos.y <= limitPos.endPos.y)
end

function isInCricle(pos, origin, radius)
    local distanceSquared = (pos.x - origin.x)^2 + (pos.y - origin.y)^2
    return distanceSquared <= radius^2
end


function getChangeArea(oldPos,newPos,oldAreaRange,newAreaRange,areas,max)
    --计算新旧区间
    local oldLimitPos = getPosLimit(oldPos,oldAreaRange,max)
    local newLimitPos = getPosLimit(newPos,newAreaRange,max)
    
    local addAreas = {}
    local removeAreas = {}
    local unchangeAreas = {}

    for i = oldLimitPos.startPos.x,oldLimitPos.endPos.x do
        for j = oldLimitPos.startPos.y,oldLimitPos.endPos.y do
            if isInRect({x = i,y = j},newLimitPos) then
                --在老区域且在新区域范围内
                table.insert(unchangeAreas,areas[i][j])
            else
                --在老区域但不在新区域范围内
                table.insert(removeAreas,areas[i][j])
            end
        end
    end

    for i = newLimitPos.startPos.x,newLimitPos.endPos.x do
        for j = newLimitPos.startPos.y,newLimitPos.endPos.y do
            if isInRect({x = i,y = j},oldLimitPos) == false then
                --在新区域但不在老区域范围内
                table.insert(addAreas,areas[i][j])
            end
        end
    end
    
    return {add = addAreas,remove = removeAreas,unchange = unchangeAreas}
end

local AreaAOI = BaseClass()

function AreaAOI:__init(config)
    --地图宽高
    self.width = config.width
    self.height = config.height
    --格子宽高
    self.area_width = config.areaWidth
    self.area_height = config.areaHeight
    self.range_limit = config.limit or 5
    --格子
    self.areas = {}

    self:Init()
end

function AreaAOI:Init()
    self.max = {
        x = math.ceil(self.width/self.area_width) - 1,
        y = math.ceil(self.height/self.area_height) - 1,
        width = self.width,
        height = self.height,
    }
    print("AreaAOI:Init, max:",self.max)

    --初始化区域
    for i = 0, math.floor(self.width/self.area_width), 1 do
        self.areas[i] = {}
        for j = 0, math.floor(self.height/self.area_height), 1 do
            --构建格子列表
            self.areas[i][j] = Area.New(i,j)
            --self.areas[i][j]:PrintXY()
        end
    end
end

function AreaAOI:CheckPos(pos)
    if pos == nil then
        return false
    end

    if pos.x < 0 or pos.y < 0 or pos.x > self.width or pos.y > self.height then
        return false
    end

    return true
end

function AreaAOI:GetAreaPos(pos)
    --往上取整
    return { x = math.floor(pos.x / self.area_width),
             y = math.floor(pos.y/self.area_height)} 
end

function AreaAOI:AddObject(obj,pos)
    if self:CheckPos(pos) then
        local areaPos = self:GetAreaPos(pos)
        --print("pos:"..pos.x..":",pos.y)
        --print("areaPos:"..areaPos.x..":",areaPos.y)
        --print("areaPos:",self.areas[areaPos.x],self.areas[areaPos.x][areaPos.y])
        --添加到Area中
        self.areas[areaPos.x][areaPos.y]:AddObject(obj)

        --通知观察者有物体进入
        self.areas[areaPos.x][areaPos.y]:NotifyObjEnter(obj)
    end
end

function AreaAOI:RemoveObject(obj,pos)
    if self:CheckPos(pos) then
        local areaPos = self:GetAreaPos(pos)

        --从Area中删除
        self.areas[areaPos.x][areaPos.y]:RemoveObject(obj)

        --通知观察者有物体离开
        self.areas[areaPos.x][areaPos.y]:NotifyObjLeave(obj)
    end
end

function AreaAOI:UpdateObject(obj,oldPos,newPos)
    --检测位置是否合法
    if self:CheckPos(oldPos) == false or self:CheckPos(newPos) == false then
        return false
    end

    --检测是否触发满足距离变化
    local diff_x = math.abs(newPos.x - oldPos.x)
    local diff_y = math.abs(newPos.y - oldPos.y)
    if(diff_x < 1 and diff_y < 1) then
        return        
    end

    --检测是否发生位置变化
    local oldPos = self:GetAreaPos(oldPos)
    local newPos = self:GetAreaPos(newPos)
    if(oldPos.x == newPos.x and oldPos.y == newPos.y) then
        --没有发生跨格子操作
        self.areas[newPos.x][newPos.x]:NotifyObjUpdate(obj)
        return
    end

    local oldArea = self.areas[oldPos.x][oldPos.y]
    oldArea:RemoveObject(obj)
    oldArea:NotifyObjLeave(obj)

    local newArea = self.areas[newPos.x][newPos.y]
    newArea:AddObject(obj)
    newArea:NotifyObjEnter(obj)
end

--pos 观察者位置
--areaRange 观察格子范围
function AreaAOI:AddWatcher(watcher,pos,areaRange)
    if self:CheckPos(pos) == false then
        return
    end
    --根据pos和rang计算得到观察者的范围
    local areaPos = self:GetAreaPos(pos)
    local limitPos = getPosLimit(areaPos,areaRange,self.max)

    --添加到每个格子的观察者中
    for i = limitPos.startPos.x,limitPos.endPos.x do
        for j = limitPos.startPos.y,limitPos.endPos.y do
            self.areas[i][j]:AddWatcher(watcher)
        end
    end
end

function AreaAOI:RemoveWatcher(watcher,pos,areaRange)
    if self:CheckPos(pos) == false then
        return
    end
    --根据pos和rang计算得到观察者的范围
    local areaPos = self:GetAreaPos(pos)
    local limitPos = getPosLimit(areaPos,areaRange,self.max)

    --删除每个格子的观察者
    for i = limitPos.startPos.x,limitPos.endPos.x do
        for j = limitPos.startPos.y,limitPos.endPos.y do
            self.areas[i][j]:RemoveWatcher(watcher)
        end
    end
end

function AreaAOI:UpdateWatcher(watcher,oldPos,oldAreaRange,newPos,newAreaRange)
    if self:CheckPos(oldPos) == false or self:CheckPos(newPos) == false then
        return
    end

    if oldPos.x == newPos.x and oldPos.y == newPos.y and oldAreaRange == newAreaRange then
        return
    end
    
    local changeAreas = getChangeArea(oldPos,newPos,oldAreaRange,newAreaRange,self.areas,self.max)

    for _ , area in pairs(changeAreas.add) do
        area:AddWatcher(watcher)
    end

    for _, area in pairs(changeAreas.remove) do
        area:RemoveWatcher(watcher)
    end

    --TODO:unchangeAreas通知
end

function AreaAOI:GetObjsByPos(pos,areaRange)
    if self:CheckPos(pos) == false then
        return {}
    end

    local areaPos = self:GetAreaPos(pos)
    local limitPos = getPosLimit(areaPos,areaRange,self.max)

    local result = {}
    for i = limitPos.startPos.x,limitPos.endPos.x do
        for j = limitPos.startPos.y,limitPos.endPos.y do
            local areaObjs = self.areas[i][j]:GetObjs()
            
            if areaObjs ~= nil then
                for _,obj in pairs(areaObjs) do
                    table.insert(result,obj)
                end
            end
        end
    end

    return result
end

function AreaAOI:GetObjsByPosAndType(pos,areaRange,type)
    if self:CheckPos(pos) == false then
        return {}
    end

    local areaPos = self:GetAreaPos(pos)
    local limitPos = getPosLimit(areaPos,areaRange,self.max)

    local result = {}
    for i = limitPos.startPos.x,limitPos.endPos.x do
        for j = limitPos.startPos.y,limitPos.endPos.y do
            local areaObjs = self.areas[i][j]:GetObjsByType(type)
            
            if areaObjs ~= nil then
                for _,obj in pairs(areaObjs) do
                    table.insert(result,obj)
                end
            end
        end
    end

    return result
end

function AreaAOI:GetObjsByPosForRange(pos,range)
    if self:CheckPos(pos) == false then
        return {}
    end

    --计算格子范围
    local areaRangeX = math.ceil(range/self.area_width)
    local areaRangeY = math.ceil(range/self.area_height)

    --根据pos和rang计算得到观察者的范围
    local areaPos = self:GetAreaPos(pos)
    local limitPos = getPosLimit2(areaPos,areaRangeX,areaRangeY,self.max)

    --计算实际范围
    local limitPosRange = getPosLimitForRange(pos,range,self.max)

    local result = {}
    for i = limitPos.startPos.x,limitPos.endPos.x do
        for j = limitPos.startPos.y,limitPos.endPos.y do
            local areaObjs = self.areas[i][j]:GetObjs()
            
            if areaObjs ~= nil then
                for _,obj in pairs(areaObjs) do
                    if isInRect(obj.pos,limitPosRange) then
                        table.insert(result,obj)
                    end
                end
            end
        end
    end

    return result
end

function AreaAOI:GetObjsByRangeConfig(pos,rangeConfig)
    if self:CheckPos(pos) == false then
        return {}
    end
    --1 正方形
    --2 长方形
    --3 圆形
    local shape = rangeConfig.shape or 1
    local fiftetype = rangeConfig.type or 0

    local rangeX , rangeY
    if shape == 1 or shape == 3 then
        rangeX = rangeConfig.x or self.area_width * 3
        rangeY = rangeConfig.x or self.area_height * 3
    elseif shape == 2 then
        rangeX = rangeConfig.x or self.area_width * 3
        rangeY = rangeConfig.y or self.area_height * 3
    else
        --默认长宽
        rangeX = self.area_width * 3
        rangeY = self.area_height * 3
    end

    --计算格子范围
    local areaRangeX = math.ceil(rangeX/self.area_width)
    local areaRangeY = math.ceil(rangeY/self.area_height)

    --根据pos和rang计算得到观察者的范围
    local areaPos = self:GetAreaPos(pos)
    local limitPos = getPosLimit2(areaPos,areaRangeX,areaRangeY,self.max)

    --计算实际范围
    local limitPosRange = getPosLimitForRange2(pos,rangeX,rangeY,self.max)

    local result = {}
    local areaObjs
    for i = limitPos.startPos.x,limitPos.endPos.x do
        for j = limitPos.startPos.y,limitPos.endPos.y do
            if fiftetype == 0 then
                areaObjs = self.areas[i][j]:GetObjs()
            else
                areaObjs = self.areas[i][j]:GetObjsByType(fiftetype)
            end
            
            if areaObjs ~= nil then
                for _,obj in pairs(areaObjs) do
                    --先做矩形判断
                    if isInRect(obj.pos,limitPosRange) then
                        if(shape == 1 or shape == 2) then
                            table.insert(result,obj)
                        elseif isInCricle(obj.pos,pos,rangeX) then
                            --圆内判断
                            table.insert(result,obj)
                        end
                    end
                end
            end
        end
    end

    return result
end

return AreaAOI