# Fql

Easily execute FQL queries with this gem.

## Download and installation

The latest version of fql can be installed with RubyGems:

```bash
$ gem install fql
```

If you're using Bundler, you can add it to your `Gemfile`:

```ruby
gem 'fql'
```

## Examples

*Exampe: a single query without access_token*

```ruby
  Fql.execute('SELECT first_name, last_name FROM user WHERE uid = 4')
  # => [{"first_name"=>"Mark", "last_name"=>"Zuckerberg"}]
```

*Exampe: a multi query with an access_token*

```ruby
  options = { :access_token => "fb_access_token" }
  Fql.execute({
    "query1" => "SELECT uid, rsvp_status FROM event_member WHERE eid = 209798352393506 LIMIT 3",
    "query2" => "SELECT name FROM user WHERE uid IN (SELECT uid FROM #query1)"
  }, options)
  # => [{"name"=>"query1", "fql_result_set"=>[{"uid"=>712638919, "rsvp_status"=>"attending"}, {"uid"=>711903876, "rsvp_status"=>"attending"}, {"uid"=>711447283, "rsvp_status"=>"attending"}]}, {"name"=>"query2", "fql_result_set"=>[{"name"=>"Srikanth Nagandla"}, {"name"=>"Hinling Yeung"}, {"name"=>"G\u00F6khan Olgun"}]}]
```

---

This project rocks and uses MIT-LICENSE.
