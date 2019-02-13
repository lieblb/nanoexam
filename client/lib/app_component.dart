import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:http/browser_client.dart';
import 'package:qti/qti.dart' as qti;

import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';

import 'src/exam_admin_page/exam_admin_page_component.dart';
import 'src/exam_list/exam_list_component.dart';
import 'src/single_choice_question/single_choice_question_component.dart';
import 'src/exam_clock/exam_clock_component.dart';
import 'src/exam_results/exam_results_component.dart';
import 'src/exam_page/exam_page_component.dart';
import 'src/exam_page/page.dart';

import 'src/answer_model/answer_model.dart';
import 'src/answer_model/pass.dart';

enum TestInteractionStage {
	Welcome,
	InTest,
	Finished
}

@Component(
  selector: 'my-app',
  styleUrls: ['app_component.css'],
  templateUrl: 'app_component.html',
  directives: [
		ExamAdminPageComponent,
		ExamClockComponent,
		ExamListComponent,
		ExamPageComponent,
		ExamResultsComponent,

		SingleChoiceQuestionComponent,

		FixedMaterialTabStripComponent,
		MaterialButtonComponent,

		MaterialDialogComponent,
		ModalComponent,

		KeyUpBoundaryDirective,
		EscapeCancelsDirective,
		MaterialYesNoButtonsComponent,

		NgFor,
		NgIf,
	],
	providers: const <dynamic>[materialProviders],
)
class AppComponent implements OnInit {
	TestInteractionStage stage = TestInteractionStage.Welcome;

	qti.Assessment assessment;

	int activeExamId = 0;
	String activeExamName = "";
	int activePassId = 0;

	List<Page> pages = [];
	int currentPageIndex = 0;

	Duration maxAllowedDuration = null;
	DateTime startTime = null;

	final answerModel = AnswerModel();

  bool isInAdminMode = false;
  bool askFinishTest = false;
  bool failedToStartErr = false;

	final client = BrowserClient();

	String debug = "";

	@override
  Future<Null> ngOnInit() async {
  }

	bool get isInWelcomeStage {
  	return stage == TestInteractionStage.Welcome;
	}

	bool get isInTestStage {
		return stage == TestInteractionStage.InTest;
	}

	bool get isInFinishedStage {
		return stage == TestInteractionStage.Finished;
	}

	void nextQuestion() {
  	if (currentPageIndex < pages.length - 1) {
			currentPageIndex += 1;
		}
	}

	void previousQuestion() {
		if (currentPageIndex > 0) {
			currentPageIndex -= 1;
		}
	}

	void finishTest() {
		askFinishTest = true;
	}

	void confirmFinishTest() async {
  	await answerModel.synchronize();

  	// while (true)
		final finishResponse = await client.post(
				"/api/v1/finish/${activePassId}");
		if (finishResponse.statusCode != 200) {
			throw HttpException("finish failed ${finishResponse.statusCode}");
		}

		askFinishTest = false;
		stage = TestInteractionStage.Finished;
	}

	void startExam(int examId) async {
  	try {
			final userId = await _createDefaultUser();
			if (userId == null) {
				failedToStartErr = true;
				return;
			}

			final examResponse = await client.get(
					"/api/v1/exams/${examId}");
			if (examResponse.statusCode != 200) {
				throw HttpException("GET exam failed ${examResponse.statusCode}");
			}

			final pass = await _startOrContinuePass(examId, userId);

			final exam = jsonDecode(examResponse.body);

			try {
				await answerModel.initialize(pass.id);
			} catch (e) {
				print(e);
				throw Exception("could not initialize answer model");
			}

			activeExamId = examId;
			activePassId = pass.id;
			activeExamName = exam["name"] as String;
			startTime = pass.startTime;

			final maxTimeInSeconds = exam['maxAllowedTimePerPass'] as int;
			if (maxTimeInSeconds > 0) {
				maxAllowedDuration = Duration(seconds: maxTimeInSeconds);
			} else {
				maxAllowedDuration = null;
			}

			assessment = qti.parse(exam["qti"]);

			for (var i = 0; i < assessment.items.length; i++) {
				final item = assessment.items[i];

				if (item.questionType == qti.QuestionType.SingleChoice) {
					pages.add(Page([item]));
				}
			}


			pages.shuffle(); // random question order for participant

			currentPageIndex = 0;

			stage = TestInteractionStage.InTest;

		} catch (e) {
  		print(e);
			failedToStartErr = true;
		}
	}

	void onTabChange(TabChangeEvent event) {
		//tabIndex = event.newIndex;
		//isInAdminMode = event.newIndex == 1;
	}

	void toggleAdminMode() {
  	isInAdminMode = !isInAdminMode;
	}

	final tabLabels = const <String>[
		'Participant',
		'Administrator'
	];

  Future<int> _createDefaultUser() async {

		final login = "testuser";

		// first, check that we have a user.
		var response;

		response = await client.get(
				"/api/v1/login/${login}");
		if (response.statusCode == 404) { // not found
			final headers = {
				'Content-type' : 'application/json',
				'Accept': 'application/json',
			};

			response = await client.post(
					"/api/v1/users",
					body: jsonEncode({"login": login, "fullName": "Test User"}),
					headers: headers);
			if (response.statusCode != 200) {
				throw HttpException("GET user returned ${response.statusCode}");
			}
		}

		return jsonDecode(response.body)["id"];
	}

  Future<Pass> _startOrContinuePass(int examId, int userId) async {

		// find the most recent pass for this user and exam and check
		// if it's a continuation of a test pass begun earlier.
		final passesResponse = await client.get(
			"/api/v1/users/${userId}/passes/${examId}");
		if (passesResponse.statusCode != 200) {
			throw HttpException("GET pass returned ${passesResponse.statusCode}");
		}

		final passes = jsonDecode(passesResponse.body) as List;
		if (passes.length > 0) {
			final pass = passes[passes.length - 1];
			final finished = pass['finished'] as bool;
			if (!finished) {
				return Pass(pass);
			}
		}

		final postPassResponse = await client.post(
			"/api/v1/users/${userId}/passes/${examId}");
		if (postPassResponse.statusCode != 200) {
			throw HttpException("POST pass returned ${postPassResponse.statusCode}");
		}
		return Pass(jsonDecode(postPassResponse.body));
	}
}
