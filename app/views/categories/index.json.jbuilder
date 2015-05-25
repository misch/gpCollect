json.array!(@categories) do |category|
  json.extract! category, :id, :sex, :age
  json.url category_url(category, format: :json)
end
