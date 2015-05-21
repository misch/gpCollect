json.array!(@runners) do |runner|
  json.extract! runner, :id, :first_name, :last_name, :birth_date
  json.url runner_url(runner, format: :json)
end
