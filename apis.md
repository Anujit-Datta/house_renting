add to fev:
curl --location --request POST 'http://localhost:8005/api/properties/24/favourite' \
--header 'Accept: application/json' \
--header 'Authorization: Bearer 5|Hl7Ht8IFEww4PFf5sFqqYUA8vBQNoCw4TeIPOCdN914bad75'

{
    "success": true,
    "message": "Property added to favourites",
    "data": {
        "id": 4,
        "property_id": "24"
    }
}

{
    "success": false,
    "message": "Property already in favourites"
}



remove fev:
curl --location --request DELETE 'http://localhost:8005/api/properties/24/favourite' \
--header 'Accept: application/json' \
--header 'Authorization: Bearer 5|Hl7Ht8IFEww4PFf5sFqqYUA8vBQNoCw4TeIPOCdN914bad75'

{
    "success": true,
    "message": "Property removed from favourites"
}


{
    "success": false,
    "message": "Favourite not found"
}

