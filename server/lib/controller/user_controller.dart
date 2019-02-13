import 'dart:async';

import 'package:aqueduct/aqueduct.dart';

import '../model/User.dart';

class UserController extends ResourceController {
	UserController(this.context);

	final ManagedContext context;

	@Operation.post()
	Future<Response> createUser() async {
		final Map<String, dynamic> body = await request.body.decode();

		final query = Query<User>(context)
			..values.login = body["login"] as String
			..values.fullName = body["login"] as String;

		final user = await query.insert();
		return Response.ok(user.id);
	}

	@Operation.get()
	Future<Response> getAllUsers() async {
		final userQuery = Query<User>(context);
		final users = await userQuery.fetch();
		return Response.ok(users);
	}

	@Operation.get('id')
	Future<Response> getUser(@Bind.path('id') int id) async {
		final userQuery = Query<User>(context)
			..where((u) => u.id).equalTo(id);
		final users = await userQuery.fetch();
		if (users.length == 1) {
			return Response.ok(users[0]);
		} else {
			return Response.notFound();
		}
	}
}
