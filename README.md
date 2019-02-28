## What is this?

An incomplete proof-of-concept trying to apply state-of-the-art web engineering for
building a robust, offline first test player for e-assessments.

Main objectives were:

* matching client and server written from scratch in Dart 2
* client can run offline and will save asynchronously to the server
* server draws test data from type checked QTI exported from ILIAS

## Technologies Used

Dart 2 is Google's modern <a href="https://www.dartlang.org/guides/language/sound-dart">type safe language</a>
for the Web for building high-quality, mission-critical apps.

The nanoexam server is built on top of <a href="https://aqueduct.io/">aqueduct</a>,
a multi-threaded, high performance server framework with builtin ORM.

The nanoexam client uses <a href="https://webdev.dartlang.org/angular">AngularDart</a>, the
framework behind "some of Google's most sophisticated and mission-critical applications"
(see https://pub.dartlang.org/packages/angular_components).

## Example

![screenshot](/docs/example.png)
