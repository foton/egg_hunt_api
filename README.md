# Egg Hunt API v1 - Geocaching with easter eggs!

##Resources
This RESTful JSONized API have 3 resources
- _Users_, which are manged only by **admins**
- _Locations_ (area in real world) (name, GPS boundaries by top\_left and bottom\_right conner, optional: description, city)
- _Eggs_ (location, size, time of placing, size, optional: decription, image)

Locations can overlap. 

https://help.github.com/categories/writing-on-github/

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

Atributtes of `user` available to modification:
* `email` (valid e-mail address)
* `token` (at least 20 chars)
* `admin` (`true` or `false`)
If `user.token` is set to `""` or `null` or `"regenerate"`, new token will be created. Other values are directly used as token.

##Locations (and Coordinates)

##Eggs



Bellow is help for markdown for me
------------------
*Italic characters* 
_Italic characters_
**bold characters**
__bold characters__
~~strikethrough text~~
* Item 1
* Item 2
* Item 3
  * Item 3a
  * Item 3b
  * Item 3c
  1. Step 1
2. Step 2
3. Step 3
   1. Step 3.1
   2. Step 3.2
   3. Step 3.3

   Use the backtick to refer to a `function()`.
 
There is a literal ``backtick (`)`` here.

Indent every line of the block by at least 4 spaces.

This is a normal paragraph:

    This is a code block.
    With multiple lines.

Alternatively, you can use 3 backtick quote marks before and after the block, like this:

```
This is a code block
```

To add syntax highlighting to a code block, add the name of the language immediately
after the backticks: 

```javascript
var oldUnload = window.onbeforeunload;
window.onbeforeunload = function() {
    saveCoverage();
    if (oldUnload) {
        return oldUnload.apply(this, arguments);
    }
};
```

This is [an example](http://www.example.com/) inline link.

[This link](http://example.com/ "Title") has a title attribute.

Links are also auto-detected in text: http://example.com/

| Day     | Meal    | Price |
| --------|---------|-------|
| Monday  | pasta   | $6    |
| Tuesday | chicken | $8    |
