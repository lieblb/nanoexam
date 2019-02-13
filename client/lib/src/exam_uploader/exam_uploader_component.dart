import 'dart:async';
import 'dart:html';
import 'dart:convert';

import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';

@Component(
	selector: 'exam-uploader',
	styleUrls: const ['exam_uploader_component.css'],
	templateUrl: 'exam_uploader_component.html',
	directives: const [
		MaterialProgressComponent,
		NgIf,
	],
	providers: const [],
)
class ExamUploaderComponent {
	int progress = 0;
	bool isUploadRunning = false;

	final _uploadExamComplete = StreamController<int>();
	@Output()
	Stream<int> get uploadExamComplete => _uploadExamComplete.stream;

	void uploadFiles(InputElement upload) async {
		final files = upload.files;
		if (files.length == 1) {
			final reader = new FileReader()..readAsArrayBuffer(files[0]);
			await reader.onLoadEnd.first;
			List<int> result = reader.result;

			isUploadRunning = true;
			final request = HttpRequest();
			request.open('POST', '/api/v1/exams');
			request.upload.onProgress.listen((ProgressEvent e) {
				progress = (e.loaded * 100).toInt() ~/ e.total;
			});
			request.setRequestHeader(
				'Content-Type', 'application/json; charset=UTF-8');
			request.send(jsonEncode({
				'data': base64.encode(result)
			}));
			await request.onLoad.first;
			isUploadRunning = false;
			_uploadExamComplete.add(1);

			upload.value = ""; // allow subsequent uploads
		}
	}
}
