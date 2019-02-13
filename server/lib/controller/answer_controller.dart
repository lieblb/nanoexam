import 'dart:async';
import 'dart:convert';

import 'package:aqueduct/aqueduct.dart';

import '../model/Answer.dart';
import '../model/Pass.dart';

class Responses {
	Responses(
		this.questionId, this.version, this.responses, this.timestamp);

	final String questionId;
	final int version;
	final Map<String, String> responses;
	final DateTime timestamp;
}

Map<String, String> toStringMap(Map m) {
	return m.map<String, String>((k, v) {
		return MapEntry<String, String>(k.toString(), v.toString());
	});
}

class AnswerController extends ResourceController {
	AnswerController(this.context);

	final ManagedContext context;

	@Operation.post('passId', 'questionId')
	Future<Response> createAnswer(
		@Bind.path('passId') int passId,
		@Bind.path('questionId') String questionId) async {

		final Map<String, dynamic> recordFromClient = await request.body.decode();
		final value = toStringMap(recordFromClient["responses"] as Map);
		final intendedVersion = recordFromClient["version"] as int;
		int actualVersion = -1;

		final Answer answer = await context.transaction((t) async {

			// due to asynchronous caching of client, data may actually
			// arrive _after_ the official finish timestamp of the test.

			/*final passQuery = Query<Pass>(t)
				..where((p) => p.id).equalTo(passId);
			final pass = await passQuery.fetchOne();
			if (pass.finishTime != null) {
				return null;
			}

			if (pass.exam.maxAllowedTimePerPass > 0) {
				final maxTime = pass.exam.maxAllowedTimePerPass + pass.extraTime;
				final elapsedTime = DateTime.now().toUtc().difference(pass.startTime).inSeconds;
				if (elapsedTime > maxTime) {
					return null; // FIXME
				}
			}*/

			final lastVersionQuery = Query<Answer>(t)
				..where((a) => a.pass.id).equalTo(passId)
				..where((a) => a.questionId).equalTo(questionId);

			final lastVersion = await lastVersionQuery.reduce.maximum(
				(a) => a.version);
			if (lastVersion != null) {
				actualVersion = lastVersion + 1;
			} else {
				actualVersion = 1;
			}

			if (actualVersion > 1) {
				const versionsToKeep = 20;
				const timeToKeep = Duration(minutes: 5);

				final deleteAnswersQuery = Query<Answer>(t)
					..where((a) => a.pass.id).equalTo(passId)
					..where((a) => a.questionId).equalTo(questionId)
					..where((a) => a.version).lessThan(actualVersion - versionsToKeep)
				  ..where((a) => a.timestamp).lessThan(DateTime.now().subtract(timeToKeep));
				await deleteAnswersQuery.delete();
			}

			print("saving ${questionId} pass: ${passId} v: ${actualVersion} val: ${value}");

			final timestamp = DateTime.parse(
					recordFromClient['timestamp'] as String);

			final addQuery = Query<Answer>(t)
				..values.pass.id = passId
				..values.questionId = questionId
				..values.version = actualVersion
				..values.timestamp = timestamp
				..values.data = Document(jsonEncode(value));
			return await addQuery.insert();
		});

		if (answer == null) {
			return Response.badRequest();
		}

		print("${answer.id} ${intendedVersion} ${actualVersion}");
		final result = jsonEncode({
			'id': answer.id,
			'intendedVersion': intendedVersion,
			'actualVersion': actualVersion});
		print(result);

		return Response.ok(result);
	}

	static Future<List<Responses>> fetchAnswers(
		ManagedContext context, int passId) async {

		final persistentStore = context.persistentStore;

		const querySQL = '''
			SELECT c.questionid, c.version, c.data, c.timestamp FROM (
				SELECT *, MAX(version) OVER (PARTITION BY questionid)
					AS lastversion FROM _Answer WHERE pass_id=@passId) AS c
				WHERE c.version = c.lastversion
		''';

		final List<List<dynamic>> results = await persistentStore.executeQuery(
			querySQL, {
				"passId": passId
			}, 30);

		return results.map<Responses>((r) {
			return Responses(
					r[0] as String,
					r[1] as int,
					toStringMap(jsonDecode(r[2] as String) as Map),
					r[3] as DateTime
			);
		}).toList();
	}

	@Operation.get('passId')
	Future<Response> getAnswers(
		@Bind.path('passId') int passId) async {

		final responses = await fetchAnswers(context, passId);

		return Response.ok(responses.map((r) {
			return {
				'questionId': r.questionId,
				'version': r.version,
				'responses': jsonEncode(r.responses),
				'timestamp': r.timestamp.toIso8601String()
			};
		}).toList());
	}
}
