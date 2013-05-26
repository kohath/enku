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
    when "goal", pf("goal")
      stem.message "Use #{pf}goal to tell me how much you'd like to weigh. "    \
                   "\"#{pf}goal 250\" tells me you want to weigh 250 pounds.  " \
                   "(I also understand decimal weights and other units -- "     \
                   "\"#{pf}goal 249.6\", \"#{pf}goal 113 kg\", and \"{pf}goal " \
                   "17 st 12 lb\" are all okay.) I'll push you every now and "  \
                   "then, especially if you're slipping. If you add a date in " \
                   "m/d form, e.g. \"#{pf}goal 250 by 1/15\", then I'll also "  \
                   "keep track of how you're doing in comparison to your "      \
                   "deadline.  (You can't set a goal lasting longer than a "    \
                   "year; if you have longer-term goals, just set them with me "\
                   "a year at a time.)", sender[:nick]
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
    weighed = Gainer.first_or_create({:name => sender[:nick].downcase})
    
    old_weight = weighed[:weight]
    passed_goal = weighed[:weight] < weighed[:goal] ? parse_weight(msg) > weighed[:goal] : parse_weight(msg) < weighed[:goal]
    
    if weighed.update(:weight => parse_weight(msg), :units => determine_units(msg))
      case
      when (old_weight == 0.0 or old_weight.nil?)
        "You weigh #{converted_weight(weighed[:weight], weighed[:units])} - awesome."
      when old_weight < weighed[:weight]
        "#{converted_weight(weighed[:weight], weighed[:units])}? That's #{converted_weight(weighed[:weight]-old_weight, weighed[:units])} more than last time! Keep going!"
      when old_weight > weighed[:weight]
        "#{converted_weight(weighed[:weight], weighed[:units])}? You're #{converted_weight(old_weight-weighed[:weight], weighed[:units])} less than last weigh-in ... better grab a snack!"
      when old_weight = weighed[:weight]
        "That's the same as last time... Eat something!"
      end << " You've passed your goal!" if passed_goal
    else
      "Okay, but I'm having trouble remembering that #{sender[:nick]} (#{weighed[:name]}) weighs #{msg} (#{converted_weight(weighed[:weight], weighed[:units])})."
    end  
  end
  
  # temporary method 
  def list_command(stem, sender, reply_to, msg)
    Gainer.all.collect {|g| "%s - %f" % [g.name, g.weight || 0.0] }.join("; ")
  end
  
  def convert_command(stem, sender, reply_to, msg)
    given_weight = converted_weight(msg)
    conversions = Gainer::WEIGHT_UNITS.delete_if {|unit| unit == determine_units(given_weight)}
    converted = conversions.collect do |unit|
      converted_weight(given_weight, unit)
    end
    converted = converted.join(", or ")
    "#{given_weight} is about #{converted}"
  end
  
  def sizeup_command(stem, sender, reply_to, msg)
    asker = Gainer.first_or_create(:name => sender[:nick].downcase)
      
    inquest = Gainer.first(:name => msg.downcase)
    if inquest && inquest[:weight] && inquest[:weight] > 0.0
      "Last I heard, #{msg} weighed #{converted_weight(inquest.weight, asker.units)}.  Sounds like someone needs a donut."
    else
      "I don't know how much #{msg} weighs."
    end
  end
  
  def goal_command(stem, sender, reply_to, msg)
    gainer = Gainer.first_or_create(name: sender[:nick].downcase)
    
    if gainer.update(goal: parse_weight(msg))
      diff = if gainer.weight && gainer.weight > 0.0 
        " #{converted_weight(gainer[:goal] - gainer[:weight], gainer[:units])} to go!" 
      end
      "#{converted_weight(gainer[:goal], gainer[:units])}! Sounds great!#{diff}"
    else
      "Okay, but I'm going to have trouble remembering that."
    end
  end
  
  private 
  # Conveniently get the command PreFix, or prepend it to a string
  def pf(str = "")
    "%s%s" % [@options[:command_prefix], str]
  end
end
