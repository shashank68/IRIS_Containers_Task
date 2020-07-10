json.extract! request, :id, :description, :category, :created_at, :updated_at
json.url request_url(request, format: :json)
