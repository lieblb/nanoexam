import 'dart:async';
import 'dart:convert';
import 'package:http/browser_client.dart';

import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';

@Component(
	selector: 'exam-clock',
	styleUrls: ['exam_clock_component.css'],
	templateUrl: 'exam_clock_component.html',
	directives: [
		NgIf,
	],
	providers: const <dynamic>[materialProviders],
)
class ExamClockComponent implements OnInit {
	@Input()
	DateTime startTime = null;

	@Input()
	Duration maxDuration = null;

	int remainingTime = 0;

	String get remainingTimeAsString {
		int h = remainingTime ~/ 3600;
		int m = (remainingTime - h * 3600) ~/ 60;
		int s = remainingTime - h * 3600 - m * 60;

		String ht = h.toString().padLeft(2, '0');
		String mt = m.toString().padLeft(2, '0');
		String st = s.toString().padLeft(2, '0');

		return "${ht}:${mt}:${st}";
	}

	void updateRemainingTime(Timer t) {
		if (startTime != null && maxDuration != null) {
			final elapsed = DateTime.now().difference(startTime);
			remainingTime = maxDuration.inSeconds - elapsed.inSeconds;
			if (remainingTime <= 0) {
				remainingTime = 0;
			}
		}
	}

	@override
	Future<Null> ngOnInit() async {
		Timer.periodic(Duration(seconds: 1), updateRemainingTime);
	}
}
