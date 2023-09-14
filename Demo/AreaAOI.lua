local Area = require "Area"

--区域AOI管理

--pos 格子坐标
--range 格子范围
--max 当前格子大小
function getPosLimit(pos,range,max)
    local startPos = {x = 0 , y = 0}
    local endPos = {x = 0,y = 0}

    if pos.x - range < 0 then
        startPos.x = 0
        endPos.x = 2* range
    elseif pos.x + range > max.x then
        startPos.x = pos.x - 2 * range
        endPos.x = max.x
    else
        startPos.x = pos.x - range
        endPos.x = pos.x + range
    end

    if pos.y - range < 0 then
        startPos.y = 0
        endPos.y = 2* range
    elseif pos.y + range > max.y then
        startPos.y = pos.y - 2 * range
        endPos.y = max.y
    else
        startPos.y = pos.y - range
        endPos.y = pos.y + range
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


function getChangeArea(oldPos,newPos,oldRange,newRange,areas,max)
    --计算新旧区间
    local oldLimitPos = getPosLimit(oldPos,oldRange,max)
    local newLimitPos = getPosLimit(newPos,newRange,max)
    
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

    print("AreaAOI init")

    self.max = {
        x = math.ceil(self.width/self.area_width) - 1,
        y = math.ceil(self.height/self.area_height) - 1
    }

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
--rang 观察格子范围
function AreaAOI:AddWatcher(watcher,pos,range)
    if self:CheckPos(pos) == false then
        return
    end
    --根据pos和rang计算得到观察者的范围
    local areaPos = self:GetAreaPos(pos)
    local limitPos = getPosLimit(areaPos,range,self.max)

    --添加到每个格子的观察者中
    for i = limitPos.startPos.x,limitPos.endPos.x do
        for j = limitPos.startPos.y,limitPos.endPos.y do
            self.areas[i][j]:AddWatcher(watcher)
        end
    end
end

function AreaAOI:RemoveWatcher(watcher,pos,range)
    if self:CheckPos(pos) == false then
        return
    end
    --根据pos和rang计算得到观察者的范围
    local areaPos = self:GetAreaPos(pos)
    local limitPos = getPosLimit(areaPos,range,self.max)

    --删除每个格子的观察者
    for i = limitPos.startPos.x,limitPos.endPos.x do
        for j = limitPos.startPos.y,limitPos.endPos.y do
            self.areas[i][j]:RemoveWatcher(watcher)
        end
    end
end

function AreaAOI:UpdateWatcher(watcher,oldPos,oldRange,newPos,newRange)
    if self:CheckPos(oldPos) == false or self:CheckPos(newPos) == false then
        return
    end

    if oldPos.x == newPos.x and oldPos.y == newPos.y and oldRange == newRange then
        return
    end
    
    local changeAreas = getChangeArea(oldPos,newPos,oldRange,newRange,self.areas,self.max)

    for _ , area in pairs(changeAreas.add) do
        area:AddWatcher(watcher)
    end

    for _, area in pairs(changeAreas.remove) do
        area:RemoveWatcher(watcher)
    end

    --TODO:unchangeAreas通知
end

function AreaAOI:GetObjsByPos(pos,range)
    if self:CheckPos(pos) == false then
        return {}
    end

    local areaPos = self:GetAreaPos(pos)
    local limitPos = getPosLimit(areaPos,range,self.max)

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

function AreaAOI:GetObjsByPosAndType(pos,range,type)
    if self:CheckPos(pos) == false then
        return {}
    end

    local areaPos = self:GetAreaPos(pos)
    local limitPos = getPosLimit(areaPos,range,self.max)

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

return AreaAOI