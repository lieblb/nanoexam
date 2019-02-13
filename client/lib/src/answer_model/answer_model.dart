import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'dart:html'; // alert

import 'package:http/http.dart' as http;
import 'package:http/browser_client.dart';

import 'answer.dart';
import 'response_path.dart';

class AnswerModel {
	final client = BrowserClient();

	int passId = null;
	final Map<String, Answer> answers = {};

	final Set<String> pending = Set();
	final Set<String> queued = Set();

	StreamController syncController;

	void initialize(int passId) async {
		final answersResponse =
			await client.get("/api/v1/passes/${passId}/answers");
		if (answersResponse.statusCode != 200) {
			throw HttpException("GET answers returned ${answersResponse.statusCode}");
		}

		this.passId = passId;
		for (final answerRecord in jsonDecode(answersResponse.body)) {
			final answer = Answer(answerRecord);
			answers[answer.questionId] = answer;
		}
	}

	// FIXME. show ui warning if pending delay gets too long.

	void _sendAnswer(String questionId) {
		assert(passId != null);
		assert(!pending.contains(questionId));

		Future<http.Response> post;
		{
			final answer = answers[questionId];

			final headers = {
				'Content-type': 'application/json',
				'Accept': 'application/json',
			};

			post = client.post(
					"/api/v1/passes/${passId}/answers/${questionId}",
					body: jsonEncode({
						'responses': answer.responses,
						'version': answer.version,
						'timestamp': answer.timestamp.toIso8601String(),
						'token': '1234'  // FIXME secret token for writing answers
					}),
					headers: headers);

			pending.add(questionId);
		}

		var onError = () async {
			// window.alert("there was an error saving your answer.");

			// keep questionId in pending, wait a moment, then
			// try saving this answer again.

			await Future.delayed(const Duration(seconds: 1));

			pending.remove(questionId);
			_sendAnswer(questionId);
		};

		post
			.then((http.Response r) {
				if (r.statusCode == 200) {
					pending.remove(questionId);

					if (queued.contains(questionId)) {
						// process answer again, it has changed in the meantime.
						queued.remove(questionId);
						_sendAnswer(questionId);
					} else {
						// answer is cleanly saved now.
						if (pending.isEmpty && queued.isEmpty) {
							// all answers are cleanly saved now.
							syncController.close();
						}
					}
				} else {
					onError();
				}
			})
		.catchError((error) {
			onError();
		});
	}

	bool containsKey(ResponsePath p) {
		final Map responses = answers[p.questionId]?.responses ?? {};
		return responses.containsKey(p.responseId);
	}

	String operator [](ResponsePath p) {
		final Map responses = answers[p.questionId]?.responses ?? {};
		return responses[p.responseId] ?? '';
	}

	void operator []=(ResponsePath p, String value) {
		final Answer oldAnswer = answers[p.questionId];
		Answer newAnswer;
		if (oldAnswer != null) {
			newAnswer = oldAnswer.newVersion(p.responseId, value);
		} else {
			newAnswer = Answer.initialVersion(p.questionId, p.responseId, value);
		}
		answers[p.questionId] = newAnswer;

		if (pending.contains(p.questionId)) {
			queued.add(p.questionId);
		} else {
			_sendAnswer(p.questionId);
		}
	}

	void synchronize() async {
		syncController = StreamController<int>();

		await syncController.stream.first;


		while (queued.length > 0 || pending.length > 0) {

		}
		// FIXME
	}
}
