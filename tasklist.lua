require 'robem'

TASKLIST='.tasklist'
TMP='.tasklist.tmp'

PATTERN_TASK_NR   ='^(%d+) :: '
PATTERN_TASK_DESC ='^%d+ :: (.*)'
PATTERN_TIME      ='^(%d+)$'

COLOR1=string.char(27)..'[;41m' -- red
COLOR2=string.char(27)..'[;45m' -- pink
CLEAR=string.char(27)..'[0m'

TaskList = {}
TaskList.__index = TaskList
TaskList.filename = 'unkown file'
TaskList.lastSeen = 'date in here'

function new(sFilename)
  local tl = {}
  setmetatable(tl,TaskList)
  tl.filename = sFilename or TASKLIST
  return tl
end

function TaskList:load()
  file = io.open(self.filename,'r')
  if not file then 
    -- create file
    io.open(self.filename,'a'):close()
    return 
  end

  for l in file:lines() do

    if l:match(PATTERN_TIME) then
      self.lastSeen=l

    elseif l:match(PATTERN_TASK_NR) then
      local num = tonumber(l:match(PATTERN_TASK_NR))
      local sDesc = l:match(PATTERN_TASK_DESC)
      self[num] = sDesc

    else
      print('ERROR '..arg[0]..': unknown line')
    end
  end
  file:close()
end

function TaskList:writeTime()
  local time = os.time()
  tmp = io.open(TMP,'w+')
  tmp:write(time..'\n')

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
  color = true
  for l in file:lines() do
    if not l:match(PATTERN_TIME) then
      if color then
        print(COLOR1..l..CLEAR)
      else
        print(COLOR2..l..CLEAR)
      end
      color = not color
    end
  end
  file:close()
end

function TaskList:timeToPrint()
  -- 6 hours
  if os.difftime(os.time(),self.lastSeen) > 21600 then
    return true
  end
  return false
end

function main()
  -- evaluate arguments
  local tl = {}
  
  opt = robem.getopt(arg,"f:d:t")

  tl=new(opt.f)
  tl:load()

  -- DEL TASK from table
  if opt.d then
    table.remove(tl,opt.d)    
    tl:print()
    
  -- ADD TASK to table
  elseif opt.text then
    local sTaskDesc = table.concat(opt.text,' ')
    tl:writeTask(sTaskDesc)
    tl:print()

  -- PRINT if timestamp while ago
  elseif opt.t then 
    if tl:timeToPrint() then
      tl:print()
      tl:writeTime()
    end
    return

  -- just PRINT if no args are given
  else
    tl:print()
  end

  -- ALWAYS at the end
  -- writes tasks and time to file
  tl:writeTime()
end

if not package.loaded['tasklist'] then
  main()
end
