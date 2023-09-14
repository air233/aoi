require "BaseClass"
--区域块

local Area = BaseClass()

function Area:__init(x,y)
    self.x = x
    self.y = y

    self.watcher_list = {}
    --obj_list[obj.id] = obj    
    self.obj_list = {}
    --obj_list[obj.type][obj.id] = obj  
    self.type_obj_list = {}

    self.size = 0
end

function Area:GetObjs()
    return self.obj_list
end

function Area:GetObjsByType(type)
    return self.type_obj_list[type]
end

function Area:GetWatcher()
    return self.watcher_list
end

function Area:AddObject(obj)
    self.obj_list[obj.id] = obj

    if self.type_obj_list[obj.type] == nil then
        --print(obj.type)
        self.type_obj_list[obj.type] = {}
    end
    self.type_obj_list[obj.type][obj.id] = obj

    self.size = self.size + 1
end

function Area:RemoveObject(obj)
    if self.obj_list[obj.id] then
        -- 从总对象列表中移除对象
        self.obj_list[obj.id] = nil

        -- 检查类型列表是否存在，以及对象是否存在于类型列表中
        if self.type_obj_list[obj.type] and self.type_obj_list[obj.type][obj.id] then
            -- 从类型列表中移除对象
            self.type_obj_list[obj.type][obj.id] = nil

            -- 如果该类型的对象列表为空了，也可以从总类型列表中移除该类型
            if next(self.type_obj_list[obj.type]) == nil then
                self.type_obj_list[obj.type] = nil
            end
        end

        self.size = self.size - 1
    end
end

function Area:AddWatcher(watcher)
    --print("Area:AddWatcher:"..watcher.id)
    self.watcher_list[watcher.id] = watcher
end

function Area:RemoveWatcher(watcher)
    --print("Area:RemoveWatcher:"..watcher.id)
    self.watcher_list[watcher.id] = nil
end

function Area:NotifyObjEnter(obj)
    for _ , w in pairs(self.watcher_list) do
        if type(w.NotifyObjEnter) == "function" then
            --通知有Obj进入
            w:NotifyObjEnter(obj)
        end
    end
end

function Area:NotifyObjLeave(obj)
    for _ , w in pairs(self.watcher_list) do
        if type(w.NotifyObjLeave) == "function" then
            --通知有Obj离开
            w:NotifyObjLeave(obj)
        end
    end
end

function Area:NotifyObjUpdate(obj)
    for _ , w in pairs(self.watcher_list) do
        if type(w.NotifyObjUpdate) == "function" then
            --通知有Obj更新位置
            w:NotifyObjUpdate(obj)
        end
    end
end

function Area:PrintXY()
    print("Area x:"..self.x..", y:"..self.y)    
end

return Area