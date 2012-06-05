require 'robem'

TASKLIST='.tasklist'
TMP='.tasklist.tmp'

TaskList = {}
TaskList.__index = TaskList
TaskList.filename = 'unkown file'
TaskList.lastSeen = 'some date in here'

function new()
  local tl = {}
  setmetatable(tl,TaskList)
  tl.filename = sFilename or TASKLIST
  return tl
end

function TaskList:load()

  ----------------------------
  -- Do the parse things here!
  ----------------------------
  
  file = io.open(self.filename,'r')
  if not file then 
    -- create file
    io.open(self.filename,'a'):close()
    return 
  end

  for l in file:lines() do

    if l:match('^%d+/') then
      self.lastSeen=l

    elseif l:match('^%d') then
      local num = tonumber(l:match('^(%d+)'))
      local sDesc = l:match(':: (.*)')
      self[num] = sDesc

    else
      print('ERROR: unknown line')
    end
  end
  file:close()
end

function TaskList:writeTime()
  local string = os.date('%x %X') -- da/t/e ti:m:e
  tmp = io.open(TMP,'w+')
  tmp:write(string..'\n')

  for i=1,#self do
    tmp:write(string.format('%d :: %s\n',i,self[i]))
  end

  tmp:close()

  os.remove(self.filename)
  os.rename(TMP,self.filename)
end

function TaskList:writeTask(sTaskDesc)
  local number = #self+1
  local string = string.format('%d :: %s\n',number,sTaskDesc)

  self[number] = sTaskDesc
end

function TaskList:print()
  file = io.open(self.filename,'r')
  for l in file:lines() do
    if not l:match('^%d+/%d+') then
      print(l)
    end
  end
  file:close()
end

function TaskList:isTime()
  local d = os.date('%x') -- da/t/e
  local t = os.date('%X') -- ti:m:e
  if self.lastSeen:find(os.date('%x')) then
    if not ((tonumber(self.lastSeen:sub(10,11))-6) < 0) then
      if (tonumber(self.lastSeen:sub(10,11))+6) > tonumber(t:sub(1,2)) then
        return false
      end
    end
  end
  return true
end

function main()
  -- evaluate arguments
  local tl = {}
  
  opt = robem.getopt(arg,"f:d:t")

  tl=new(opt['f'])
  tl:load()

  -- DEL TASK
  if opt.d then
    table.remove(tl,opt.d)    
  -- ADD TASK
  elseif opt.text then
    local sTaskDesc = table.concat(opt.text,' ')
      
    tl:writeTask(sTaskDesc)
  elseif opt.t then 
    if tl:isTime() then
      tl:print()
      tl:writeTime()
    end
    return
  else
    tl:print()
  end

  tl:writeTime()
end

if not package.loaded['tasklist'] then
  main()
end
