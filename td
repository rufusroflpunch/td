#!/usr/bin/ruby

usage = "td - The todo.txt helper
For more on the todo.txt format, see:
https://github.com/ginatrapani/todo.txt-cli/wiki/The-Todo.txt-Format

Usage:

td a <task>
  Adds a task to your todo.txt file.
td x <task>
  Completes a task. It will attempt to search for the task
  and remove it from your todo.txt. If it finds more than
  one, it will prompt for one or more to move to done.txt.
td - <task>
  Deletes a task (doesn't move to done.txt). If it finds
  more than one, will prompt.
td @ <context>
  Lists tasks, filtered by context.
td d <date>
  Lists tasks, filtered by creation date.
td + <project>
  List tasks, filtered by project.
td p
  Lists all prioritized in order.
td s <ext>
  Scans all directories recursively, looking for any files
  of the specified extension. Each file it finds, will be 
  scanned, looking for any TODO: lines. It will add 
  those lines to your todo.txt, along with line number and 
  use the filename as the project, e.g. +source.rb.

This script will look for a todo.txt first in your current
directory, then in your home directory if it doesn't find
one. At that point, it will only use the done.txt in that
same directory, or it will create a new one. If you want to
use a separate todo.txt for a specific project, make sure you
create a new one first."

command = ARGV[0]

# Locate todo.txt and read it in.
if File.exists?("todo.txt")
  todo_file = "todo.txt"
elsif File.exists?("#{Dir.home}/todo.txt")
  todo_file = "#{Dir.home}/todo.txt"
else
  puts "Todo.txt not found. Creating new one."
  todo_file = "todo.txt"
  File.open(todo_file, "w+").close
end

todo = File.open(todo_file).readlines

case command
when "a"
  todo << ARGV[1..-1].join(' ')
when "x"
when "-"
when "@"
  puts todo.select { |n| n =~ /@#{ARGV[1..-1].join ' '}\s/i }
when "d"
  date_test = /\d\d\d\d-\d\d-\d\d\s/
  puts todo.select { |n| n =~ date_test }.sort_by { |n| n.match(date_test).to_s }
when "+"
  puts todo.select { |n| n =~ /\+#{ARGV[1..-1].join ' '}\s/i }
when "p"
  puts todo.select { |n| n =~ /^\([A-Z]\)/ }.sort
when "s"
else
  puts usage
end

File.open(todo_file, "w+").puts todo
