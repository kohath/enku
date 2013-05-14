class Gainer
  include DataMapper::Resource
  
  property :id, Serial
  property :name, String
  property :weight, Float
  property :units, Integer
  
  POUNDS = 0
  KILOGRAMS = 1
  STONE = 2
end