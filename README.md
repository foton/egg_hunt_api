# Egg Hunt API v1 - Geocaching with easter eggs!

If You are not sure about correct calls, maybe test files in `/test/integration/api/v1/` will help.

##Resources
This RESTful JSONized API have 3 resources
- _Users_, which are managed only by **admins** and can create many _locations_
- _Locations_ (area in real world, where _eggs_ are hidden) (name, GPS boundaries by top\_left and bottom\_right conner, optional: description, city)
- _Eggs_ (location, size, time of placing[created_at], size, optional: description, image)

Locations can overlap. 


##Authentication and Authorization
API uses HTTP Basic Token authorization. Token will be assigned to You by admin.
Token can be send in request header 
  
    headers['HTTP_AUTHORIZATION'] = "Token token=ds5468cyrfga51ysada"

or used as username HTTP Basic Authentication

    https://ds5468cyrfga51ysada:doesnotmatter@api.example.com/eggs

There are 3 roles: **guest**, **user**. **admin**. 
* If You do not send any of these, You are not authenticated. So You are **quest**, and You can only read all _Eggs_ and _Locations_.
* If You are authenticated as **user**, You have same rights as **guest** and You can add _Eggs_ and _Locations_ and manipulate them (only the ones You own).
* If You are authenticated as **admin**, You can manipulate with all _Eggs_ and _Locations_ and also manipulate _Users_.


##Users
Only **admins** can see and manipulate _Users_.

Index of users: 
    
    curl -k https://localhost:3001/api/v1/users.json -H 'Authorization: Token token="R3plac3MeImm3d1a7elly"'



    200
    [
      {
        "id":1,
        "email":"foton@centrum.cz",
        "token":"R3plac3MeImm3d1a7elly",
        "admin":true,
        "created_at":"2016-03-31T22:43:33.893+02:00",
        "updated_at":"2016-03-31T22:43:33.893+02:00"
      },
      {
        "id":2,
        "email":"bunny@centrum.cz",
        "token":"fGFCVDFrkbR3dx775pqPHMX3",
        "admin":true,
        "created_at":"2016-03-31T22:43:33.909+02:00",
        "updated_at":"2016-03-31T22:43:33.909+02:00"
      }
    ]

View of user: 

    curl -k https://localhost:3001/api/v1/users/1.json -H 'Authorization: Token token="R3plac3MeImm3d1a7elly"'



    200
    {
      "id":1,
      "email":"foton@centrum.cz",
      "token":"R3plac3MeImm3d1a7elly",
      "admin":true,
      "created_at":"2016-03-31T22:43:33.893+02:00",
      "updated_at":"2016-03-31T22:43:33.893+02:00"
    }

Creating user (HTTP method POST): 

    curl -k https://localhost:3001/api/v1/users.json -H 'Authorization: Token token="R3plac3MeImm3d1a7elly"' -X POST -H "Content-Type: application/json" -d '{"user": {"email":"xyz@email.cz","admin": true}}'



    201
    {
      "id":3,
      "email":"xyz@email.cz",
      "token":"vFDwodq8w7Ev2m777TMHrHJF",
      "admin":true,
      "created_at":"2016-03-31T23:43:33.893+02:00",
      "updated_at":"2016-03-31T23:43:33.893+02:00"
    }


Updating user (HTTP method PUT or PATCH): 

    curl -k https://localhost:3001/api/v1/users/3.json -H 'Authorization: Token token="R3plac3MeImm3d1a7elly"' -X PATCH -H "Content-Type: application/json" -d '{"user": {"token":"myLittlePonnyToken123", "admin": false}}'



    200
    {
      "id":3,
      "email":"xyz@email.cz",
      "token":"myLittlePonnyToken123",
      "admin":false,
      "created_at":"2016-03-31T23:43:33.893+02:00",
      "updated_at":"2016-03-31T23:45:33.893+02:00"
    }


Deleting user (HTTP method DELETE): 

    curl -k https://localhost:3001/api/v1/users/3.json -H 'Authorization: Token token="R3plac3MeImm3d1a7elly"' -X DELETE 



    200
    {
      "id": null,
      "email":"xyz@email.cz",
      "token":"myLittlePonnyToken123",
      "admin":false,
      "created_at":"2016-03-31T23:43:33.893+02:00",
      "updated_at":"2016-03-31T23:45:33.893+02:00"
    }


Creating/Updating user with invalid data return errors: 

    curl -k https://localhost:3001/api/v1/users.json -H 'Authorization: Token token="R3plac3MeImm3d1a7elly"' -X POST -H "Content-Type: application/json" -d '{"user": {"email":"xyz_email.cz","admin": true}}'



    422
    {
      "errors": 
      { 
        "email": ["is invalid"]
      }
    }

When user is deleted, `user_id` of his _locations_ will be set tu `null`. His/her _eggs_ will be deleted.

Atributtes of `user` available to modification:
* `email` (valid e-mail address)
* `token` (at least 20 chars)
* `admin` (`true` or `false`)
If `user.token` is set to `""` or `null` or `"regenerate"`, new token will be created. Other values are directly used as token.

##Locations (and Coordinates)
Location is rectangular area defined by top-left (TL) and bottom-right (BR) coordinate.
Coordinates are in GPS format decimal degrees + N-S , W-E hemispheres.
For example: 
* "0.00001N, 0.00001E" is just "step" from crossing Equator and 0 Meridian
* "0.00001N, 179.5900001E" is near "day-border-line" in Pacific (from Asia side)
* "0.00001N, 179.5900001W" is near "day-border-line" in Pacific (from America side)
* "51.4769433N, 0.0005519W" is Greenwich observatory

Index of locations: 

    curl -k https://localhost:3001/api/v1/locations.json


  
    200
    [
      {
        "id":1,
        "name":"Hide and seek park",
        "city":"London",
        "description":null,
        "user_id":2,
        "top_left_coordinate_str": "51.5118883N, 0.1905369W",
        "bottom_right_coordinate_id": ""51.5028867N, 0.1512694W",
        "created_at":"2016-03-31T22:43:33.956+02:00",
        "updated_at":"2016-03-31T22:43:33.956+02:00"
      },
      {
        "id":2,
        "name":"Olomouc",
        "city":"Olomouc",
        "description":"Metropolis of Haná",
        "user_id":2,
        "top_left_coordinate_id":"49.6124894N, 17.2159669E",
        "bottom_right_coordinate_id":"49.5604067N, 17.3100375E",
        "created_at":"2016-03-31T22:43:33.967+02:00",
        "updated_at":"2016-03-31T22:43:33.967+02:00"
      }
    ]

View of location: 

    curl -k https://localhost:3001/api/v1/locations/1.json`

Creating location (HTTP method POST): 

    curl -k https://localhost:3001/api/v1/locations.json -H 'Authorization: Token token="fGFCVDFrkbR3dx775pqPHMX3"' -X POST -H "Content-Type: application/json" -d '{"location": {"name":"Holomóc", "city": "Olomouc", "top_left_coordinate_str": "49.6124894N, 17.2159669E" ,"bottom_right_coordinate_str": "49.5604067N, 17.3100375E"}}'



      201
      {
        "id":1,
        "name":"Holomóc",
        "city":"Olomouc",
        "description":null,
        "user_id":2,
        "top_left_coordinate_str":"49.6124894N, 17.2159669E",
        "bottom_right_coordinate_str":"49.5604067N, 17.3100375E",
        "created_at":"2016-03-31T23:43:33.893+02:00",
        "updated_at":"2016-03-31T23:43:33.893+02:00"
      }

Updating, Deleting accordingly to _users_ .
**User cannot delete/update location, which have eggs of other users. This return 424 :failed_dependency.**
Admins are allowed to do it.

When location is deleted, all _eggs_ in it will be deleted.

Atributtes of `location` available to modification:
* `name` (3-250 chars)
* `city` (optional)
* `description` (optional)
* `top_left_coordinate_str` (string representing coordinate of top left corner of area rectangle)
* `bottom_right_coordinate_str` (string representing coordinate of bottom right corner of area rectangle)

`.._coordinate_str` attributes are converted to Coordinate object. This object is not yet published back.
`user_id` is automagically added according to current user who created the location.


##Eggs
Index of eggs: 

    curl -k https://localhost:3001/api/v1/eggs.json



    200
    [
      {
        "id":1,
        "size":2,
        "name":"Round thing from angular things",
        "location_id":1,
        "user_id":2,
        "created_at":"2016-03-31T22:43:33.995+02:00",
        "updated_at":"2016-03-31T22:43:33.995+02:00"
      },
      {
        "id":2,
        "size":1,
        "name":"Terminated round thing from angular things",
        "location_id":1,
        "user_id":2,
        "created_at":"2016-03-31T22:43:34.009+02:00",
        "updated_at":"2016-03-31T22:43:34.009+02:00"
      },
      {
        "id":3,
        "size":4,
        "name":"Fabergé: Smaragd and gold",
        "location_id":2,
        "user_id":1,
        "created_at":"2016-03-31T22:43:34.020+02:00",
        "updated_at":"2016-03-31T22:43:34.020+02:00"
      },
      {
        "id":4,
        "size":4,
        "name":"Fabergé: Safir and silver",
        "location_id":2,
        "user_id":1,
        "created_at":"2016-03-31T22:43:34.031+02:00",
        "updated_at":"2016-03-31T22:43:34.031+02:00"
      }
    ]

Creating egg (HTTP method POST): 

      curl -k https://localhost:3001/api/v1/eggs.json -H 'Authorization: Token token="fGFCVDFrkbR3dx775pqPHMX3"' -X POST -H "Content-Type: application/json" -d '{"egg": {"name":"TargaryenEgg", "size": 6, "location_id": 2}}'



      201
      {
        "id":5,
        "name":"TargaryenEgg",
        "size":6,
        "location_id":2,
        "user_id":2,
        "created_at":"2016-03-31T23:43:33.893+02:00",
        "updated_at":"2016-03-31T23:43:33.893+02:00"
      }

Updating, Deleting accordingly to _users_ .
**User cannot delete/update eggs of other users. This return 403 :forbidden.**
Admins are allowed to do it.

Atributtes of `egg` available to modification:
* `name` (3-250 chars)
* `size` (one of 1,2,3,4,5,6 ; see `/app/models/egg.rb` `SIZES` constant for description)
* `location_id` (ID of location to which egg belongs; must exist in app)
`user_id` is automagically added according to current user who created the egg.


##Returned fields
You can choose which fields of resource(s) will be in response by `fields` param in URL (see example in **Indexes of resources**)


## Indexes of resources
All indexes have ability to sort, limit, search/filter objects and limit returned fields.

For example:

    .../eggs.json?sort=-size,+name&name=Kr&created_at>2001-01-01T8:00:00Z&size<5&offset=5&limit=10&fields=id,size,name,location_id

will 

* select only eggs 
  * newer than 1.1.2001 8:00 UTC
  * smaller then 5
  * with name starting on "Kr"
* pick only 5 to 15th record
* return only `id`,`size`,`name`,`location_id` attributes
* sort result by `size` "desc" and `name` "asc"

For all indexes you can limit records which are returned
* `limit=11` => only 11 records is returned
* `offset=5` => selection start at 5th record


###User index filters
**sort** by any attribute ("-attr" means descending order, "+attr" or "attr" means ascending order)

**search** 
* `email=something` => address begins with 'something'
* `admin=true` (  'true' | 1  => `true` ; 'false' | 0 => `false`)

###Location index filters
**sort** by any attribute ("-attr" means descending order, "+attr" or "attr" means ascending order)

**search** 
* `name=something` => name begins with 'something'
* `city=something` => city begins with 'something'
* `description=something` => description begins with 'something'
* `user_id=5` => only locations which belongs to user with id 5
* `area_tl=56.0N,0.3W&area_br=51.5N,9.5E` => only locations which have theirs TL or BR coordinates in this area (so TL corner or BR corner must overlap desired area; I am working on full coverage)


###Eggs index filters
**sort** by any attribute ("-attr" means descending order, "+attr" or "attr" means ascending order)

**search** 
* `name=something` => name begins with 'something'
* `size=1` => egg size is equal to 1
* `size>3` => egg size is greater then 3
* `size<3` => egg size is less then 3
* `created_at=2015-03-03T08:08:08Z` only eggs created at this UTC time
* `created_at>2015-03-03T08:08:08Z` only eggs created after this UTC time
* `created_at<2015-03-03T08:08:08Z` only eggs created before this UTC time
* `updated_at=2015-03-03T08:08:08Z` only eggs updated at this UTC time
* `updated_at>2015-03-03T08:08:08Z` only eggs updated after this UTC time
* `updated_at<2015-03-03T08:08:08Z` only eggs updated before this UTC time
* `user_id=5` => only eggs which belongs to user with id 5
* `location_id=3` => only eggs from locations with id 3
* `area_tl=56.0N,0.3W&area_br=51.5N,9.5E` => only eggs from locations which have theirs TL or BR coordinates in this area (so TL corner or BR corner must overlap desired area; I am working on full coverage)

