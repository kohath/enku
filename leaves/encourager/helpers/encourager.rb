module EncouragerHelper
  # Turn a string into a standard weight, returned in pounds.
  def parse_weight(weight)
    num_given = weight.is_a?(Numeric) ? [weight] : weight.scan(/\d*(?:\.\d+)?/)
    num_given.delete ""
    
    case determine_units(weight)
    when Gainer::STONE then (num_given[0].to_f*14 + num_given[1].to_f)
    when Gainer::KILOGRAMS then (num_given[0].to_f*2.2)
    else num_given[0].to_f
    end.round(2)
  end
  
  # Given a string, guess the units it was given in
  def determine_units(weight)
    weight = weight.to_s
    case
    when weight["st"] then Gainer::STONE
    when weight["kg"] then Gainer::KILOGRAMS
    else Gainer::POUNDS
    end
  end
  
  # Return a string expressing a pounds weight in the requested units
  def converted_weight(weight, units = determine_units(weight))
    weight = weight ? parse_weight(weight) : 0
    case 
    when units == Gainer::STONE && weight >= 14 then "#{(weight/14).floor}st%s" % (" #{(weight%14).round(1)}lb" if weight%14 >= 0.05)
    when units == Gainer::KILOGRAMS then "#{(weight/2.2).round(1)}kg"
    else "#{weight.round(1)}lb"
    end
  end
end