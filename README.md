td - The todo.txt helper
========================

About
-----

**td** was created to help manage my todo.txt files. You know what I mean, everyone has one. A list of things in your code or document you need to do, or to fix. A few years ago, Gina Trapani invented a [format](http://todotxt.com/) for todo.txt that has become a standard for many. This script was created to assist with that. This was written and tested with Ruby 2.1, but it should work with most recent versions of Ruby.

Usage
-----

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
      File globs, such as *.rb, are accepted.

This script will look for a todo.txt first in your current directory, then in your home directory if it does not find one. At that point, it will only use the done.txt in that same directory, or it will create a new one. If you want to use a separate todo.txt for a specific project, make sure you create a new one first, if you already have one in your home folder.
