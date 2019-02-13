import 'dart:async';

import 'package:aqueduct/aqueduct.dart';

import '../model/Pass.dart';

class FinishPassController extends ResourceController {
  FinishPassController(this.context);

  final ManagedContext context;

  @Operation.post('passId')
  Future<Response> finishPass(@Bind.path('passId') int passId) async {
    final passQuery = Query<Pass>(context)
      ..values.finishTime = DateTime.now().toUtc()
      ..where((p) => p.id).equalTo(passId)
      ..where((p) => p.finishTime).equalTo(null);

    final updatedPass = await passQuery.updateOne();
    // updatedPass == null => finish had already happened before.

    // finish always returns "ok" so the client knows things arrived.
    return Response.ok(updatedPass);
  }
}
