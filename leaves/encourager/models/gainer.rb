class Gainer
  include DataMapper::Resource
  
  property :id, Serial
  property :name, String
  property :weight, Float
  property :units, Integer
  
  WEIGHT_UNITS = [POUNDS, KILOGRAMS, STONE]
  POUNDS = 0
  KILOGRAMS = 1
  STONE = 2
end