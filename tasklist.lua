TASKLIST='.tasklist'
TMP='.tasklist.tmp'

PATTERN_TASK_NR   ='^(%d+) :: '
PATTERN_TASK_DESC ='^%d+ :: (.*)'
PATTERN_TIME      ='^(%d+)$'

COLOR1=string.char(27)..'[30;44m' -- blue
COLOR2=string.char(27)..'[30;46m' -- cyan
CLEAR=string.char(27)..'[0m'

TaskList = {}
TaskList.__index = TaskList
TaskList.filename = 'unkown file'
TaskList.lastSeen = 'date in here'

function new()
  local tl = {}
  setmetatable(tl,TaskList)
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
      self.lastSeen=tonumber(l)

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
  local tl = {}
  
	local opt = {}
	for k,v in ipairs(arg) do
		if (v == '-f') then
			opt.f = arg[k+1]
			file = true
			delete = false
		elseif (v == '-d') then
			opt.d = tonumber(arg[k+1])
			delete = true
			file = false
		elseif (v == '-t') then
			opt.t = true
		elseif (not file and not delete) then
			opt.text = opt.text or {}
			table.insert(opt.text, v)
			delete = false
			file = false
		else
			delete = false
			file = false
		end
	end

  tl=new()
  tl.filename = opt.f or TASKLIST
  tl:load()

  -- DEL TASK from table
  if opt.d then
    table.remove(tl,opt.d)    
    
  -- ADD TASK to table
  elseif opt.text then
    local sTaskDesc = table.concat(opt.text,' ')
    tl:writeTask(sTaskDesc)

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
  -- write tasks and time to file
  tl:writeTime()
end

if not package.loaded['tasklist'] then
  main()
end
