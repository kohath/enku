# Controller for the Encourager leaf.

class Controller < Autumn::Leaf
  # Typing "!help" displays some basic information about this leaf.
  
  def help_command(stem, sender, reply_to, msg)
    commands = self.class.instance_methods.select { |m| m =~ /^\w+_command$/ }
    commands.map! { |m| m.to_s.match(/^(\w+)_command$/)[1] }
    
    case msg
    when "sizeup", pf("sizeup")
      stem.message "Use #{pf}sizeup <user> to get someone's weight.", sender[:nick]
    when "weigh", pf("weigh")
      stem.message "Use #{pf}weigh to tell me how much you weigh, e.g. "        \
                   "\"#{pf}weigh 250\" tells me you weigh 250 lbs. I will "     \
                   "assume pounds if you don't say otherwise, but I also "      \
                   "understand \"#{pf}weigh 113 kg\" and \"#{pf}weigh 17 st 12 "\
                   "lb\". Decimals are okay - you can \"#{pf}weigh 249.6\" too.", sender[:nick]
    when nil
      # After we get a few of these, just start listing keywords, ok?
      stem.message "Hi! I'm here to help you put on weight. Here are some "     \
                   "commands to help you out. These are short explanations and "\
                   "you can get more info by typing \"#{pf}help <command>\" "   \
                   "(e.g. #{pf}help weigh)", sender[:nick]
      stem.message(pf << "register - for individualized as opposed to generic encouragement.", sender[:nick]) if commands.include? "register"
      stem.message(pf << "weigh <weight> - lets me know how much you weigh today.", sender[:nick]) if commands.include? "weigh"
      stem.message(pf << "sizeup <name> - Find out someone's weight", sender[:nick]) if commands.include? "sizeup"
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
  
  def weigh_command(stem, sender, reply_to, msg)
    weighed = Gainer.find_or_create({:name => sender[:nick].downcase})
    
    if weighed.update(:weight => parse_weight(msg))
      "Awesome! #{weighed[:name]} weighs #{converted_weight(weighed[:weight], weighed[:units])}."
    else
      "Okay, but I'm having trouble remembering that #{sender[:nick]} (#{weighed[:name]}) weighs #{msg} (#{converted_weight(weighed[:weight], weighed[:units])})."
    end  
  end
  
  # temporary method 
  def list_command(stem, sender, reply_to, msg)
    Gainer.all.collect {|g| "%s - %f" % [g.name, g.weight || 0.0] }.join("; ")
  end
  
  def sizeup_command(stem, sender, reply_to, msg)
    asker = Gainer.first_or_create(:name => sender[:nick].downcase)
      
    inquest = Gainer.find(:name => msg.downcase)
    if inquest
      "Last I heard, #{msg} weighed #{converted_weight(inquest.weight, asker.units)}.  Sounds like someone needs a donut."
    else
      "I don't know how much #{msg} weighs."
    end
  end
  
  private 
  # Conveniently get the command PreFix, or prepend it to a string
  def pf(str = "")
    "%s%s" % [@options[:command_prefix], str]
  end
end
