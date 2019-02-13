import 'package:server/server.dart';

import "Pass.dart";

class User extends ManagedObject<_User> implements _User {}

class _User {
	@primaryKey
	int id;

	@Column(indexed: true, unique: true)
	String login;

	String fullName;

	ManagedSet<Pass> passes;
}
