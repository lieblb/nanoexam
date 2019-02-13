import 'dart:async';
import 'dart:math';

import 'package:aqueduct/aqueduct.dart';

import '../model/Exam.dart';
import '../model/Pass.dart';
import '../model/User.dart';

class PassController extends ResourceController {
	PassController(this.context);

	final ManagedContext context;

	@Operation.post('userId', 'examId')
	Future<Response> createPass(
			@Bind.path('userId') int userId,
			@Bind.path('examId') int examId) async {

		final passQuery = Query<Pass>(context)
			..where((p) => p.user.id).equalTo(userId)
			..where((p) => p.exam.id).equalTo(examId);
		final passes = await passQuery.fetch();

		int newPassIndex = 1;
		if (passes.isNotEmpty) {
			newPassIndex = passes.map((p) => p.passIndex).reduce(max) + 1;
		}

		final examQuery = Query<Exam>(context)
			..where((h) => h.id).equalTo(examId);
		final exam = await examQuery.fetchOne();

		if (exam.maxAllowedPassCount > 0 &&
				newPassIndex > exam.maxAllowedPassCount) {
			return Response.forbidden();
		}

		final userQuery = Query<User>(context)
			..where((u) => u.id).equalTo(userId);
		final user = await userQuery.fetchOne();

		final query = Query<Pass>(context)
			..values.user = user
			..values.exam = exam
			..values.passIndex = newPassIndex
			..values.startTime = DateTime.now().toUtc()
			..values.extraTime = 0
			..values.finishTime = null;

		final newPass = await query.insert();
		return Response.ok(newPass);
	}

	@Operation.get('userId')
	Future<Response> getAllPasses(@Bind.path('userId') int userId) async {
		final passQuery = Query<Pass>(context)
			..where((p) => p.user.id).equalTo(userId);
		final passes = await passQuery.fetch();
		return Response.ok(passes);
	}

	@Operation.get('userId', 'examId')
	Future<Response> getAllPassesForExam(
			@Bind.path('userId') int userId,
			@Bind.path('examId') int examId) async {

		final passQuery = Query<Pass>(context)
			..where((p) => p.user.id).equalTo(userId)
			..where((p) => p.exam.id).equalTo(examId);
		final passes = await passQuery.fetch();
		return Response.ok(passes);
	}
}
