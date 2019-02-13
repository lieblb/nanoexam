import 'dart:async';
import 'dart:html';

import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';

import '../exam_list/exam_list_service.dart';
import '../exam_list/exam_spec.dart';
import '../exam_uploader/exam_uploader_component.dart';

@Component(
	selector: 'exam-admin-page',
	styleUrls: ['exam_admin_page_component.css'],
	templateUrl: 'exam_admin_page_component.html',
	directives: [
		ExamUploaderComponent,
		MaterialFabComponent,
		MaterialIconComponent,
		MaterialSpinnerComponent,
		materialInputDirectives,
		NgFor,
		NgIf,
	],
	providers: [const ClassProvider(ExamListService)],
)
class ExamAdminPageComponent implements OnInit {
	final ExamListService examListService;

	List<ExamSpec> exams = [];

	ExamAdminPageComponent(this.examListService);

	@override
	Future<Null> ngOnInit() async {
		exams = await examListService.getExamList();
	}

	void deleteExam(int examId) async {
		await HttpRequest.request(
			'/api/v1/exams/${examId}',
			method: 'DELETE');
		exams = await examListService.getExamList();
	}

	void examUploaded() async {
		exams = await examListService.getExamList();
	}
}
