# Controller for the Encourager leaf.

class Controller < Autumn::Leaf
  
  # Typing "!help" displays some basic information about this leaf.
  
  def help_command(stem, sender, reply_to, msg)
    commands = self.class.instance_methods.select { |m| m =~ /^\w+_command$/ }
    commands.map! { |m| m.to_s.match(/^(\w+)_command$/)[1] }
      
    stem.message "Hi! I'm here to help you put on weight. Here are some commands to help you out. These are short explanations and you can get more info by typing \"#{@options[:command_prefix]}help <command>\" (e.g. #{@options[:command_prefix]}help weigh)", sender[:nick]
    stem.message(@options[:command_prefix] << "register - for individualized as opposed to generic encouragement.", sender[:nick]) if commands.include? "register"
    stem.message(@options[:command_prefix] << "weigh <weight> - lets me know how much you weigh today.", sender[:nick]) if commands.include? "weigh"
    stem.message(@options[:command_prefix] << "goal <weight> [by <date>] - to set a weight goal with optional deadline.", sender[:nick]) if commands.include? "goal"
    stem.message(@options[:command_prefix] << "ate <numberofcalories> - lets me know how much you just ate in calories.", sender[:nick]) if commands.include? "ate"
    stem.message(@options[:command_prefix] << "encourage <name> - and I'll nudge <name> to get a snack.", sender[:nick]) if commands.include? "encourage"
    stem.message(@options[:command_prefix] << "unregister - to clear all your historical data.", sender[:nick]) if commands.include? "unregister"
    stem.message(@options[:command_prefix] << "suggest <calories> <snack> - to give me ideas.", sender[:nick]) if commands.include? "suggest"
    stem.message(@options[:command_prefix] << "race <name> <number> - to challenge someone to a race to gain a given amount of weight. ", sender[:nick]) if commands.include? "race"
    nil
  end
end
