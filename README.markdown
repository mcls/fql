# Fql

Easily execute FQL queries with this gem.

*Exampe: a single query without access_token*

```ruby
  Fql.execute('SELECT first_name, last_name FROM user WHERE uid = 4')
```

*Exampe: a multi query with an access_token*

```ruby
  options = { :access_token => "fb_access_token" }
  Fql.execute({
    "query1" => "SELECT uid, rsvp_status FROM event_member WHERE eid = 12345678",
    "query2" => "SELECT name FROM profile WHERE id IN (SELECT uid FROM #query1)"
  }, options)
```

---

This project rocks and uses MIT-LICENSE.