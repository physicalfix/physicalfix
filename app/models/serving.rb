class Serving
  include MongoMapper::EmbeddedDocument
  key :description, String
  key :protein, Float
  key :calories, Float
  key :carbohydrates, Float
  key :fat, Float
  key :saturated_fat, Float
  key :cholesterol, Float
  key :sodium, Float
  key :sugar, Float
end