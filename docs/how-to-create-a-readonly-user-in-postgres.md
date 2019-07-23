# How to give a user read-only access to a Postgres database

Create the user at the command line:
```
su - postgres
createuser --interactive --pwprompt
```

Log into database as an admin and give them read access to a database:
```
GRANT CONNECT ON DATABASE db_name to username;
GRANT USAGE ON SCHEMA public to username;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO username;
```

Test their remote login:
```
psql postgres://user:pass@host:port/db
```
