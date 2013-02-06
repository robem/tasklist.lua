# README

Licence: _public domain_

Lua Version: 5.1 & 5.2

## Description

`tasklist` is a lua script to list and add tasks as easy as possible on commandline.

The idea was captured by Steve Losh and his project `t`.
http://stevelosh.com/projects/t/

## Usage

`tasklist [-t | -f file | -d taskNr]`

`tasklist my new task`

  * add a new task

`tasklist -f TASKFILE`

  * name the taskfile to read from, by default it is `.tasklist`

`tasklist -d TASK_NR`

  * delete/finish a task

`tasklist -t`

  * list tasks if the file was last visited 6 hours ago

`tasklist`

  * list all tasks

### How I use it

I created an alias in my `.bashrc` for this script to `t`.

Every time I started bash the `.bashrc` calls `t -t`. 
That means every 6 hours or basically every time I boot up and loged in I see my everyday todo's such as 'read PIL chapter X'.

I also created an alias `todo` that invokes `t -f TODO`.
Currently, I try to use a TODO file in all my projects constanly.

