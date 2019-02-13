import 'dart:async';

import 'package:aqueduct/aqueduct.dart';

import '../model/User.dart';

class LoginController extends ResourceController {
	LoginController(this.context);

	final ManagedContext context;

	@Operation.get('login')
	Future<Response> getUserByLogin(@Bind.path('login') String login) async {
		final userQuery = Query<User>(context)
			..where((u) => u.login).equalTo(login);
		final users = await userQuery.fetch();
		if (users.length == 1) {
			return Response.ok(users[0]);
		} else {
			return Response.notFound();
		}
	}
}
