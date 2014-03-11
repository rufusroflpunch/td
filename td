#!/usr/bin/ruby

require 'io/console' # Required for reading single chars

usage = "td - The todo.txt helper
For more on the todo.txt format, see:
https://github.com/ginatrapani/todo.txt-cli/wiki/The-Todo.txt-Format

Usage:

td a <task>
  Adds a task to your todo.txt file.
td x <search string/regex>
  Completes a task. It will attempt to search for the task
  and remove it from your todo.txt. It will prompt for each
  removal.
td - <search string/regex>
  Deletes a task (doesn't move to done.txt). It will prompt
  before each removal.
td @ <context>
  Lists tasks, filtered by context.
td d <date>
  Lists tasks, filtered by creation date.
td + <project>
  List tasks, filtered by project.
td p
  Lists all prioritized in order.
td s <file>
  Scans files specified in the command for any lines with
  'TODO:' and adds them to todo.txt, including line number
  and lists the file name as the project, i.e. +source.rb.
  File globs, such as *.rb are accepted.

This script will look for a todo.txt first in your current
directory, then in your home directory if it doesn't find
one. At that point, it will only use the done.txt in that
same directory, or it will create a new one. If you want to
use a separate todo.txt for a specific project, make sure you
create a new one first."

command = ARGV[0]

# done.txt is in the local directory by default
done_file = 'done.txt'
done = []

# Locate todo.txt and read it in.
if File.exists?('todo.txt')
  todo_file = 'todo.txt'
elsif File.exists?("#{Dir.home}/todo.txt")
  done_file = "#{Dir.home}/done.txt"
  todo_file = "#{Dir.home}/todo.txt"
else
  puts 'Todo.txt not found. Creating new one.'
  todo_file = 'todo.txt'
  File.open(todo_file, 'w+').close
end

# Read each line of todo.txt as an array element.
todo = File.open(todo_file).readlines

# Process the commands.
case command
when 'a'
  todo << (ARGV[1..-1].join(' ') + "\n")
when 'x'
  # Set certain tasks to complete, adding them to the 'done'
  # variable and deleting them from the 'todo' variabl.
  list = todo.select { |n| n =~ /#{ARGV[1..-1].join '.*'}/i }
  list.each do |n|
    puts "Complete '#{n.chomp}'? (y/n): "
    yn = STDIN.getch
    if yn.downcase == 'y'
      done << "x #{n}"
      todo.delete_if { |a| a == n }
    end
  end
when '-'
  # Obtain a separate list of matching lines, then remove them
  # from the todo list if they match and the user confirms.
  list = todo.select { |n| n =~ /#{ARGV[1..-1].join '.*'}/i }
  list.each do |n|
    puts "Delete '#{n.chomp}'? (y/n): "
    yn = STDIN.getch
    if yn.downcase == 'y'
      todo.delete_if { |a| a == n }
    end
  end
when '@'
  puts todo.select { |n| n =~ /@#{ARGV[1..-1].join ' '}\s/i }
when 'd'
  date_test = /\d\d\d\d-\d\d-\d\d\s/
  puts todo.select { |n| n =~ date_test }.sort_by { |n| n.match(date_test).to_s }
when '+'
  puts todo.select { |n| n =~ /\+#{ARGV[1..-1].join ' '}\s/i }
when 'p'
  puts todo.select { |n| n =~ /^\([A-Z]\)/ }.sort
when 's'
  files = []
  matcher = /TODO: (.*)$/i
  ARGV[1..-1].each { |f| files += Dir.glob(f) }
  files.each do |f|
    fo = File.open(f).readlines
    fo.each do |l|
      if l =~ matcher
        puts "Found task '#{Regexp.last_match(1)}'"
        todo << "#{Regexp.last_match(1)}. Line #{fo.index(l) + 1}. +#{File.basename f}\n"
      end
    end
  end if files != []
else
  puts usage
end

# Output the new todo list to todo.txt, and make sure
# there are no duplicates.
File.open(todo_file, 'w+').puts todo.uniq

# If there are any completed tasks, output them as well
File.open(done_file, 'a').puts done if done != []
