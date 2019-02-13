import 'controller/answer_controller.dart';
import 'controller/exam_controller.dart';
import 'controller/export_controller.dart';
import 'controller/login_controller.dart';
import 'controller/pass_controller.dart';
import 'controller/user_controller.dart';
import 'controller/finish_pass_controller.dart';

import 'server.dart';

/// This type initializes an application.
///
/// Override methods in this class to set up routes and initialize services like
/// database connections. See http://aqueduct.io/docs/http/channel/.
class NanoexamChannel extends ApplicationChannel {
  ManagedContext context;

  /// Initialize services in this method.
  ///
  /// Implement this method to initialize services, read values from [options]
  /// and any other initialization required before constructing [entryPoint].
  ///
  /// This method is invoked prior to [entryPoint] being accessed.
  @override
  Future prepare() async {
    logger.onRecord.listen(
      (rec) => print("$rec ${rec.error ?? ""} ${rec.stackTrace ?? ""}"));

    final dataModel = ManagedDataModel.fromCurrentMirrorSystem();
    final persistentStore = PostgreSQLPersistentStore.fromConnectionInfo(
        "dev_nanoexam", "dev_nanoexam", "localhost", 5432, "dev_nanoexam");

    context = ManagedContext(dataModel, persistentStore);
  }

  /// Construct the request channel.
  ///
  /// Return an instance of some [Controller] that will be the initial receiver
  /// of all [Request]s.
  ///
  /// This method is invoked after [prepare].
  @override
  Controller get entryPoint {
    final router = Router();

    router
      .route('/api/v1/exams[/:id]')
      .link(() => ExamController(context));

    router
      .route('/api/v1/passes/:passId/answers[/:questionId[/:answerId]]')
      .link(() => AnswerController(context));

    router
      .route('/api/v1/users/:userId/passes[/:examId]')
      .link(() => PassController(context));

    router
      .route('/api/v1/users[/:id]')
      .link(() => UserController(context));

    router
      .route('/api/v1/login/:login')
      .link(() => LoginController(context));

    router
      .route('/api/v1/export/:passId')
      .link(() => ExportController(context));

    router
        .route('/api/v1/finish/:passId')
        .link(() => FinishPassController(context));

    router.route("/*").link(
	    () => FileController("../client/build/"));

    return router;
  }
}
