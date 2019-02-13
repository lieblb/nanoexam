import 'dart:async';

import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';

import 'exam_list_service.dart';
import 'exam_spec.dart';

@Component(
  selector: 'exam-list',
  styleUrls: ['exam_list_component.css'],
  templateUrl: 'exam_list_component.html',
  directives: [
    MaterialFabComponent,
    MaterialIconComponent,
    materialInputDirectives,
    NgFor,
    NgIf,
  ],
  providers: [const ClassProvider(ExamListService)],
)
class ExamListComponent implements OnInit {
  final ExamListService examListService;

  List<ExamSpec> exams = [];

	final _startExamRequest = StreamController<int>();
	@Output()
	Stream<int> get startExamRequest => _startExamRequest.stream;

  ExamListComponent(this.examListService);

  @override
  Future<Null> ngOnInit() async {
		exams = await examListService.getExamList();
  }

  void startExam(int examId) {
		_startExamRequest.add(examId);
  }
}
