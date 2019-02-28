# The nanoexam server

This is the backend running on the server.

## Running the server

```
cd /path/to/nanoexam/server
aqueduct serve
```

Now call `http://localhost:8888/exam/`.

## Uploading exams

You need an QTI exam for testing. You can upload a zip file exported from ILIAS through the
Administration UI and then clicking "Upload a new exam". Currently only single choice questions
are supported.

## Setting up postgresql for testing

```
> createdb dev_nanoexam
> psql dev_nanoexam

>> CREATE USER dev_nanoexam WITH PASSWORD 'dev_nanoexam';
```

A demo database has been configured in `database.yaml` for the convenience of easy testing.

## Updating migrations

```
aqueduct db generate
aqueduct db upgrade

```

## Installing new packages

`pub upgrade`


