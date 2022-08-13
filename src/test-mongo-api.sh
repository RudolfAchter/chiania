curl --location --request POST 'https://data.mongodb-api.com/app/data-tmopi/endpoint/data/v1/action/findOne' \
--header 'Content-Type: application/json' \
--header 'Access-Control-Request-Headers: *' \
--header 'api-key: lm7SjbvAFFyM0is6iSqeW5FXlYr1dkaRVfEBLzhQlJjbQn1L8kaq2IAZcJZ69KF8' \
--data-raw '{
    "collection":"items",
    "database":"chiania",
    "dataSource":"chia-stuff",
    "filter":{"ItemType": "Sword"}
}' --verbose