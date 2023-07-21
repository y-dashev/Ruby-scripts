Creating some ruby scripts


Usage:
rubycode --app_name 'app_name' --db_url 'db_url' -u 'yavor' -p 'password'                                           

In case you are using the 'fish' terminal you need to add the function with the path to the script
Like so:

```
function rubycode
  $your absolute path to - ruby_script.rb $argv
end
```

Then you can use the script to get the heroku db  and hook it with the local one :) 
STILL NEEDS TO BE TESTED!

example usage: 

```
rubycode --app_name "[DB_URL]" --db_name '[LOCAL_DB_NAME]'  -u '[LOCAL USERNAME][OPTIONAL]'
```
