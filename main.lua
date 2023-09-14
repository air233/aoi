local current_path = package.path
--设置package path
local new_path = "E:\\toy\\cclua\\lua\\?.lua;E:\\toy\\cclua\\lua\\Demo\\?.lua;" .. current_path
package.path = new_path

local AOI = require("AOI")

config = {
    width = 10000,
    height = 20000,
    --格子宽高
    areaWidth = 100,
    areaHeight = 100,
}

local aoiService = AOI.New(config)

obj={id = 1,type = "player"}

aoiService:AddObject(obj,{x=10000,y=20000})

local count = 1000

users = {}
local id = 0
local types = {'player','npc'}
for i = 1, count,1 do
    users[i] = {
        id = i,
        pos = {
            x = math.floor(math.random() * config.width),
            y = math.floor(math.random() * config.height)
        },
        type = types[i%2+1]
    }
end

for _ , obj in pairs(users) do
    aoiService:AddObject(obj,obj.pos)
    aoiService:AddWatcher(obj,obj.pos,10)
end

local id = math.floor(math.random() * count)
local randomObj = users[id]

local result = aoiService:GetObjsByPos(randomObj.pos,5)
print("random pos:"..randomObj.pos.x..","..randomObj.pos.y)
for _,v in ipairs(result) do
    print(v.type, v.id,v.pos.x,v.pos.y)
end


--local result = getPosLimit({x=3,y=1},2,{x=5,y=5})
--print(result.startPos.x,result.startPos.y,result.endPos.x,result.endPos.y)