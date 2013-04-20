# Controller for the Encourager leaf.

class Controller < Autumn::Leaf
  
  # Typing "!help" displays some basic information about this leaf.
  
  def help_command(stem, sender, reply_to, msg)
    commands = self.class.instance_methods.select { |m| m =~ /^\w+_command$/ }
    commands.map! { |m| m.to_s.match(/^(\w+)_command$/)[1] }
    
    case msg
    when nil
      stem.message "Hi! I'm here to help you put on weight. Here are some commands to help you out. These are short explanations and you can get more info by typing \"#{pf}help <command>\" (e.g. #{pf}help weigh)", sender[:nick]
      stem.message(pf << "register - for individualized as opposed to generic encouragement.", sender[:nick]) if commands.include? "register"
      stem.message(pf << "weigh <weight> - lets me know how much you weigh today.", sender[:nick]) if commands.include? "weigh"
      stem.message(pf << "goal <weight> [by <date>] - to set a weight goal with optional deadline.", sender[:nick]) if commands.include? "goal"
      stem.message(pf << "ate <numberofcalories> - lets me know how much you just ate in calories.", sender[:nick]) if commands.include? "ate"
      stem.message(pf << "encourage <name> - and I'll nudge <name> to get a snack.", sender[:nick]) if commands.include? "encourage"
      stem.message(pf << "unregister - to clear all your historical data.", sender[:nick]) if commands.include? "unregister"
      stem.message(pf << "suggest <calories> <snack> - to give me ideas.", sender[:nick]) if commands.include? "suggest"
      stem.message(pf << "race <name> <number> - to challenge someone to a race to gain a given amount of weight. ", sender[:nick]) if commands.include? "race"
    else
      stem.message("I don't know anything about a command '%s'." % msg, sender[:nick])
    end
    nil
  end
  
  private 
  # Conveniently get the command PreFix, or prepend it to a string
  def pf(str = "")
    "%s%s" % [@options[:command_prefix], str]
  end
end
