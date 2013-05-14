module EncouragerHelper
  # Turn a string into a standard weight, returned in pounds.
  def parse_weight(weight)
    num_given = weight.scan /\d*(?:\.\d+)?/
    case determine_units(weight)
    when Gainer::STONE then (num_given[0].to_f*14 + num_given[1].to_f)
    when Gainer::KILOGRAMS then (num_given[0].to_f*2.2)
    else num_given[0].to_f
    end.round(2).to_s
  end
  
  # Given a string, guess the units it was given in
  def determine_units(weight)
    case
    when weight["st"] then Gainer::STONE
    when weight["kg"] then Gainer::KILOGRAMS
    else Gainer::POUNDS
    end
  end
  
  # Return a string expressing a pounds weight in the requested units
  def converted_weight(weight, units = Gainer::POUNDS)
    weight = weight.to_f
    case units
    when Gainer::STONE then "#{(weight/14).floor}st%s" % (" #{(weight%14).round(1)}lb" if weight%14 >= 0.05)
    when Gainer::KILOGRAMS then "#{(weight/2.2).round(1)}kg"
    else "#{weight.round(1)}lb"
    end
  end
end