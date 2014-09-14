# A script to 'bootstrap' all of the other plugins, wrapping Apollo's verbose
# Java-style API in a Ruby-style API.
#
# Written by Graham.

# ********************************** WARNING **********************************
# * If you do not really understand what this is for, do not edit it without  *
# * creating a backup! Many plugins rely on the behaviour of this script, and *
# * will break if you mess it up.                                             *
# *                                                                           *
# * This is actually part of the core server and in an ideal world shouldn't  *
# * be changed.                                                               *
# *****************************************************************************

require 'java'
java_import 'net.shiver.aibot.event.EventHandler'
java_import 'net.shiver.aibot.task.Task'
java_import 'net.shiver.aibot.task.TaskManager'
java_import 'java.util.concurrent.TimeUnit'

# Extends the (Ruby) String class with a method to convert a lower case,
# underscore delimited string to camel-case.
class String
  def camelize
    gsub(/(?:^|_)(.)/) { $1.upcase }
  end
end

# An EventHandler which executes a Proc object with three arguments: the
# context, and the event.
class ProcEventHandler < EventHandler
  def initialize(block)
    super() # required (with brackets!), see http://jira.codehaus.org/browse/JRUBY-679
    @block = block
  end

  def handle(ctx, event)
    @block.call ctx, event
  end
end

# A Task which executes a Proc object with one argument (itself).
class ProcScheduledTask < Task
  def initialize(block)
    super()
    @block = block
  end

  def run
    @block.call self
  end
end

# Schedules a Task. Can be used in two ways: passing an existing
# ScheduledTask object or passing a block along with one or two parameters: the
# delay (in pulses) and, optionally, the immediate flag.
#
# If the immediate flag is not given, it defaults to false.
#
# The Task object is passed to the block so that methods such as
# setDelay and stop can be called. execute MUST NOT be called - if it is, the
# behaviour is undefined (and most likely it'll be bad).
#noinspection RubyArgCount
def schedule(*args, &block)
  if block_given?
    if args.length == 1 or args.length == 2
      delay = args[0]
      time_unit = args.length == 2 ? args[1] : TimeUnit::MILLISECONDS
      TaskManager::get_instance::schedule_periodic_task ProcScheduledTask.new(block), delay, time_unit
    elsif args.length == 0
      delay = args[0]
      time_unit = TimeUnit::MILLISECONDS
      TaskManager::get_instance::schedule_periodic_task ProcScheduledTask.new(block), delay, time_unit
    else
      raise 'invalid combination of arguments'
    end
  elsif args.length == 1
    TaskManager::get_instance::submit args[0]
  else
    raise 'invalid combination of arguments'
  end
end

# Defines some sort of action to take upon an event. The following 'kinds' of
# event are currently valid:
#
#   * :event
#
# An event takes no arguments. The block should have three arguments: the chain
# context, the player and the event object.
def on(kind, *args, &block)
  case kind
    when :event then
      on_event(args, block)
    else
      raise 'unknown event type'
  end
end

# Defines an action to be taken upon an event.
# The event can either be a symbol with the lower case, underscored class name
# or the class itself.
def on_event(args, proc)
  if args.length != 1
    raise 'event must have one argument'
  end

  evt = args[0]
  if evt.is_a? Symbol
    class_name = evt.to_s.camelize.concat 'Event'
    evt = Java::JavaClass.for_name('net.shiver.aibot.event.impl.'.concat class_name)
  end

  $ctx.add_event_handler evt, ProcEventHandler.new(proc)
end