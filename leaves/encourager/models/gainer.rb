class Gainer
  include DataMapper::Resource
  
  property :id, Serial
  property :name, String
  property :weight, Float
  property :units, Integer
  property :goal, Float
  property :goaldate, Date
  
  POUNDS = 0
  KILOGRAMS = 1
  STONE = 2
  WEIGHT_UNITS = [POUNDS, KILOGRAMS, STONE]
end