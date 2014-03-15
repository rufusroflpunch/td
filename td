#!/usr/bin/ruby

require 'io/console' # Required for reading single chars

begin
  require 'colorize'
rescue LoadError
  # If it can't load the gem, just override the colorize method
  # so that it doesn't do anything. Hacky.... or elegant? You decide!
  class String
    def colorize(dummy)
      self
    end
  end
end

usage = "td 0.1 - The todo.txt helper
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
  File globs, such as *.rb are accepted."


##################################
# VARIABLE DECLARATIONS
##################################

command = ARGV[0]
done = []
PRIORITY_REGEX = /^\(\w\)/
DATE_REGEX = /\d{4}-?\d\d-?\d\d/
PROJECT_REGEX = /\+\S+/
CONTEXT_REGEX = /\@\w+/

#################################
# METHODS
#################################

# This program rewrites the todo list at the end every time,
# so it duplicates the list to avoid gsubbing the ANSI codes
# into the actual list that prints back into the file.
def colorize_str(str)
  s = str.dup
  s.gsub!(CONTEXT_REGEX) { |m| m.colorize(:red) }
  s.gsub!(PROJECT_REGEX) { |m| m.colorize(:yellow) }
  s.gsub!(DATE_REGEX) { |m| m.colorize(:magenta) }
  s.gsub!(PRIORITY_REGEX) { |m| m.colorize(:green) }
  s
end

#################################
# MAIN PROGRAM
################################# 

# Default to home dir first for todo.txt
done_file = "#{Dir.home}/done.txt"
todo_file = "#{Dir.home}/todo.txt"

# Home dir is overridden by environment variable
if ENV['TODOTXT']
  done_file = File.dirname(ENV['TODOTXT']) + '/done.txt'
  todo_file = ENV['TODOTXT']
end

# Lastly, the environment variable is overridden by
# a local file in that folder.
if File.exists?('todo.txt')
  done_file = 'done.txt'
  done = []
  todo_file = 'todo.txt'
end

# Read each line of todo.txt as an array element.
todo = File.open(todo_file, 'a+').readlines

# Process the commands.
case command
when 'a'
  todo << (ARGV[1..-1].join(' ') + "\n")
when 'x'
  # Set certain tasks to complete, adding them to the 'done'
  # variable and deleting them from the 'todo' variable.
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
  contexts = todo.select { |n| n =~ /@#{ARGV[1..-1].join ' ' || ""}/i }
  contexts.each do |s|
    puts colorize_str(s)
  end
when 'd'
  dates = todo.select { |n| n =~ DATE_REGEX }.sort_by { |n| n.match(DATE_REGEX).to_s }
  dates.each do |s|
    puts colorize_str(s)
  end
when '+'
  projects = todo.select { |n| n =~ /\+#{ARGV[1..-1].join ' ' || ""}/i }
  projects.each do |s|
    puts colorize_str(s)
  end
when 'p'
  priorities = todo.select { |n| n =~ /^\([A-Z]\)/ }.sort
  priorities.each do |s|
    puts colorize_str(s)
  end
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

