--记录所有的类模板以及其对应的方法，同时可以利用在继承关系下快速索引父级属性以及方法。
local _class = {}

-- 构建一个类，返回一个类对象，参数为基类（可不填）
function BaseClass(super)
   -- 生成一个类类型
   local class_type = {}
   -- 在创建对象的时候自动调用
   class_type.__init = false --构造函数
   class_type.__delete = false  --析构函数
   -- 子类记录父类
   class_type.super = super
   -- New成员方法（匿名方法，闭包），只要用于通过类模板实例化一个类对象（实例）
   class_type.New = function(...)
      -- 生成一个类对象 _class_type标记class类型
      local obj = {_class_type = class_type}

      -- 在初始化之前注册基类方法
      setmetatable(obj, { __index = _class[class_type] })

      -- 用于递归调用，如果有基类，且基类有构造函数，那么先调用基类的构造函数；否则直接调用当前类的构造函数
      do
         local create
         create = function(c, ...)
            if c.super then
               create(c.super, ...)
            end
            if c.__init then
               c.__init(obj, ...)
            end
         end
         create(class_type, ...)
      end

      -- 注册一个delete方法
      obj.Delete = function(self)
         local now_super = self._class_type
         while now_super ~= nil do
            if now_super.__delete then
               now_super.__delete(self)
            end
            now_super = now_super.super
         end
      end

      return obj
   end
   -- 这个table保存所有类模板的成员，实现过程中主要保存的是类的成员方法
   local vtbl = {}
   _class[class_type] = vtbl
   -- class_type 新增成员的时候，存到vtbl中
   setmetatable(class_type, {__newindex = function(t,k,v) vtbl[k] = v end,__index = vtbl, --For call parent method
   })
  

   if super then
      -- 如果当前类继承了父类，那么在访问成员时，如果当前类中不具有该成员，则优先从_class中保存的父级中读取；
      -- 然后再将父类的成员赋值给当前类模板的vtbl容器。
      -- 简单地说，就似乎如果一个类实例有需要访问的成员则直接调用，否则从该类的上一级查找。
      setmetatable(vtbl, {__index = function(t,k) return _class[super][k] end})
   end

   return class_type
end