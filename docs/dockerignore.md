# .dockerignore

`.dockerignore` is a special file which can be used to speed up and secure your container builds by ignoring large and sensitive files.

Let's say I have a project structure like:

```
.git
Dockerfile
data
\_ really_big_production_dataset.dat
\_ test_data.dat
src
main.py
```

And a `Dockerfile` like:

```
FROM python
COPY . .


I don't want to add my `.git` directory or the big data to the container so I add it to `.dockerignore`.
