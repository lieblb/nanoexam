import 'dart:convert';

class Answer {
	final String questionId;
	final Map<String, String> responses;
	final int version;
	final DateTime timestamp;

	Answer(final Map entry) :
		this.questionId = entry["questionId"] as String,
		this.responses = Map.unmodifiable(
			jsonDecode(entry["responses"] as String)),
		this.version = entry["version"] as int,
		this.timestamp = DateTime.parse(entry["timestamp"] as String) {
	}

	Answer.initialVersion(String questionId, String responseId, String value) :
			this.questionId = questionId,
			this.responses = Map.unmodifiable({responseId: value}),
			this.version = 1,
			this.timestamp = DateTime.now().toUtc() {
	}

	Answer._newVersion(String questionId, Map values, int version) :
			this.questionId = questionId,
			this.responses = Map.unmodifiable(values),
			this.version = version,
			this.timestamp = DateTime.now().toUtc() {
	}

	Answer newVersion(String responseId, String value) {
		final newResponses = {};
		for (final k in responses.keys) {
			newResponses[k] = responses[k];
		}
		newResponses[responseId] = value;
		return Answer._newVersion(questionId, newResponses, version + 1);
	}
}
