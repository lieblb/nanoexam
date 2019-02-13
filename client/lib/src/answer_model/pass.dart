class Pass {
	int id;
	DateTime startTime;

	Pass(var json) {
		id = json['id'] as int;
		startTime = DateTime.parse(json['startTime']);
	}
}