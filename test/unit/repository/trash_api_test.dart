/*
TrashApiのテスト
 */
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:http/testing.dart';
import 'package:mockito/annotations.dart';
import 'package:throwtrash/models/trash_api_register_response.dart';
import 'package:throwtrash/models/trash_data.dart';
import 'package:throwtrash/models/trash_schedule.dart';
import 'package:throwtrash/models/trash_sync_result.dart';
import 'package:throwtrash/models/trash_update_result.dart';
import 'package:throwtrash/repository/trash_api.dart';
import 'package:throwtrash/usecase/trash_api_interface.dart';
import 'package:http/http.dart' as http;

@GenerateMocks([http.Client])
void main() {
  group("registerUserAndTrashData",()
  {
    test("registerUserAndTrashDataで正常に登録できること", () async {
      // http.Clientをモック化する
      http.Client mockClient = MockClient((request) async {
        return Response('{"id": "test_user_id", "timestamp": 12345678}', 200);
      });

      TrashApiInterface trashApi = TrashApi("https://example.com", mockClient);
      // 登録用のTrashData配列を作成する
      List<TrashData> trashData = [];
      trashData.add(TrashData(id: "1",
          type: "burn",
          trashVal: "test_trash_id",
          schedules: [
            TrashSchedule("weekday", "0")
          ],
          excludes: []));
      trashData.add(TrashData(id: "2",
          type: "unburn",
          trashVal: "test_trash_id",
          schedules: [
            TrashSchedule("month", 3)
          ],
          excludes: []));
      trashData.add(TrashData(id: "3",
          type: "bottole",
          trashVal: "test_trash_id",
          schedules: [
            TrashSchedule("biweek", "3-2")
          ],
          excludes: []));
      trashData.add(TrashData(id: "4",
          type: "other",
          trashVal: "test_trash_id",
          schedules: [
            TrashSchedule("evweek", {"interval": 2, "weekday": "0"})
          ],
          excludes: []));

      RegisterResponse? result = await trashApi.registerUserAndTrashData(
          trashData);
      expect(result, isNotNull);
      expect(result!.id, "test_user_id");
      expect(result.timestamp, 12345678);
    });
    test("registerUserAndTrashDataで200以外のレスポンスの場合はnullが返ること", () async {
      // http.Clientをモック化する
      http.Client mockClient = MockClient((request) async {
        return Response('{"error": "error"}', 500);
      });

      TrashApiInterface trashApi = TrashApi("https://example.com", mockClient);
      RegisterResponse? result = await trashApi.registerUserAndTrashData([]);
      expect(result, isNull);
    });
    test("registerUserAndTrashDataでレスポンスボディにidが存在しない場合はnullが返ること", () async {
      // http.Clientをモック化する
      http.Client mockClient = MockClient((request) async {
        return Response('{"timestamp": 12345678}', 200);
      });

      TrashApiInterface trashApi = TrashApi("https://example.com", mockClient);
      RegisterResponse? result = await trashApi.registerUserAndTrashData([]);
      expect(result, isNull);
    });
    test("registerUserAndTrashDataでレスポンスボディにtimestampが存在しない場合はnullが返ること", () async {
      // http.Clientをモック化する
      http.Client mockClient = MockClient((request) async {
        return Response('{"id": "test_user_id"}', 200);
      });

      TrashApiInterface trashApi = TrashApi("https://example.com", mockClient);
      RegisterResponse? result = await trashApi.registerUserAndTrashData([]);
      expect(result, isNull);
    });
  });
  group("updateTrashData",()
  {
    test("updateTrashDataで正常に更新できること", () async {
      // http.Clientをモック化する
      http.Client mockClient = MockClient((request) async {
        return Response('{"timestamp": 12345678}', 200);
      });

      TrashApiInterface trashApi = TrashApi("https://example.com", mockClient);
      // 登録用のTrashData配列を作成する
      List<TrashData> trashData = [];
      trashData.add(TrashData(id: "1",
          type: "burn",
          trashVal: "test_trash_id",
          schedules: [
            TrashSchedule("weekday", "0")
          ],
          excludes: []));
      trashData.add(TrashData(id: "2",
          type: "unburn",
          trashVal: "test_trash_id",
          schedules: [
            TrashSchedule("month", 3)
          ],
          excludes: []));
      trashData.add(TrashData(id: "3",
          type: "bottole",
          trashVal: "test_trash_id",
          schedules: [
            TrashSchedule("biweek", "3-2")
          ],
          excludes: []));
      trashData.add(TrashData(id: "4",
          type: "other",
          trashVal: "test_trash_id",
          schedules: [
            TrashSchedule("evweek", {"interval": 2, "weekday": "0"})
          ],
          excludes: []));

      TrashUpdateResult result = await trashApi.updateTrashData(
          "test_user_id", trashData, 12345678);
      expect(result, isNotNull);
      expect(result.timestamp, 12345678);
      expect(result.updateResult, UpdateResult.SUCCESS);
    });
    test("updateTrashDataでレスポンスのステータスコードが200でレスポンスボディにtimestampが無い場合,TrashUpdateResultのタイムスタンプが-1,UpdateResultがERRORであること", () async {
      // http.Clientをモック化する
      http.Client mockClient = MockClient((request) async {
        return Response('{"error": "error"}', 200);
      });

      TrashApiInterface trashApi = TrashApi("https://example.com", mockClient);
      TrashUpdateResult result = await trashApi.updateTrashData(
          "test_user_id", [], 12345678);
      expect(result, isNotNull);
      expect(result.timestamp, -1);
      expect(result.updateResult, UpdateResult.ERROR);
    });

    test("updateTrashDataでレスポンスのステータスコードが400の場合TrashUpdateResultのタイムスタンプが-1,UpdateResultがNO_MATCHであること", () async {
      // http.Clientをモック化する
      http.Client mockClient = MockClient((request) async {
        return Response('{"error": "error"}', 400);
      });

      TrashApiInterface trashApi = TrashApi("https://example.com", mockClient);
      TrashUpdateResult result = await trashApi.updateTrashData(
          "test_user_id", [], 12345678);
      expect(result, isNotNull);
      expect(result.timestamp, -1);
      expect(result.updateResult, UpdateResult.NO_MATCH);
    });
    test("updateTrashDataでレスポンスのステータスコードが200,400以外の場合TrashUpdateResultのタイムスタンプが-1,UpdateResultがERRORであること", () async {
      // http.Clientをモック化する
      http.Client mockClient = MockClient((request) async {
        return Response('{"error": "error"}', 500);
      });

      TrashApiInterface trashApi = TrashApi("https://example.com", mockClient);
      TrashUpdateResult result = await trashApi.updateTrashData(
          "test_user_id", [], 12345678);
      expect(result, isNotNull);
      expect(result.timestamp, -1);
      expect(result.updateResult, UpdateResult.ERROR);
    });
  });
  group("syncTrashData",()
  {
    test("syncTrashDataで正常に同期できること", () async {
      // http.Clientをモック化する
      http.Client mockClient = MockClient((request) async {
        return Response('{"id": "test_user_id", '
            '"description": "['
            '{\\"id\\":\\"1\\",\\"type\\":\\"burn\\",\\"trash_val\\":\\"\\",\\"schedules\\":[{\\"type\\":\\"weekday\\",\\"value\\":\\"0\\"}],\\"excludes\\":[]},'
            '{\\"id\\":\\"2\\",\\"type\\":\\"unburn\\",\\"schedules\\":[{\\"type\\":\\"month\\",\\"value\\":3}],\\"excludes\\":[]},'
            '{\\"id\\":\\"3\\",\\"type\\":\\"bottole\\",\\"schedules\\":[{\\"type\\":\\"biweek\\",\\"value\\":\\"3-2\\"}],\\"excludes\\":[]},'
            '{\\"id\\":\\"4\\",\\"type\\":\\"other\\",\\"trash_val\\":\\"test_trash_id\\",\\"schedules\\":[{\\"type\\":\\"evweek\\",\\"value\\":{\\"interval\\":2,\\"weekday\\":\\"0\\"}}],\\"excludes\\":[]}'
            ']", "timestamp": 12345678, "platform": "ios"}', 200);
      });

      TrashApiInterface trashApi = TrashApi("https://example.com", mockClient);
      TrashSyncResult result = await trashApi.syncTrashData("test_user_id");
      expect(result, isNotNull);
      expect(result.timestamp, 12345678);
      expect(result.syncResult, SyncResult.SUCCESS);
      expect(result.allTrashDataList.length, 4);
      expect(result.allTrashDataList[0].id, "1");
      expect(result.allTrashDataList[0].type, "burn");
      expect(result.allTrashDataList[0].trashVal, "");
      expect(result.allTrashDataList[0].schedules.length, 1);
      expect(result.allTrashDataList[0].schedules[0].type, "weekday");
      expect(result.allTrashDataList[0].schedules[0].value, "0");
      expect(result.allTrashDataList[0].excludes.length, 0);
      expect(result.allTrashDataList[1].id, "2");
      expect(result.allTrashDataList[1].type, "unburn");
      expect(result.allTrashDataList[1].trashVal, "");
      expect(result.allTrashDataList[1].schedules.length, 1);
      expect(result.allTrashDataList[1].schedules[0].type, "month");
      expect(result.allTrashDataList[1].schedules[0].value, 3);
      expect(result.allTrashDataList[1].excludes.length, 0);
      expect(result.allTrashDataList[2].id, "3");
      expect(result.allTrashDataList[2].type, "bottole");
      expect(result.allTrashDataList[2].trashVal, "");
      expect(result.allTrashDataList[2].schedules.length, 1);
      expect(result.allTrashDataList[2].schedules[0].type, "biweek");
      expect(result.allTrashDataList[2].schedules[0].value, "3-2");
      expect(result.allTrashDataList[2].excludes.length, 0);
      expect(result.allTrashDataList[3].id, "4");
      expect(result.allTrashDataList[3].type, "other");
      expect(result.allTrashDataList[3].trashVal, "test_trash_id");
      expect(result.allTrashDataList[3].schedules.length, 1);
      expect(result.allTrashDataList[3].schedules[0].type, "evweek");
      expect(result.allTrashDataList[3].schedules[0].value["interval"], 2);
      expect(result.allTrashDataList[3].schedules[0].value["weekday"], "0");
      expect(result.allTrashDataList[3].excludes.length, 0);
    });
    test(
        "syncTrashDataでレスポンスのステータスコードが200以外の場合、TrashSyncResultのallTrashDataListが空、タイムスタンプが-1、SyncResultがERRORであること", () async {
      // http.Clientをモック化する
      http.Client mockClient = MockClient((request) async {
        return Response('{"error": "error"}', 400);
      });
      TrashApiInterface trashApi = TrashApi("https://example.com", mockClient);
      TrashSyncResult result = await trashApi.syncTrashData("test_user_id");
      expect(result, isNotNull);
      expect(result.timestamp, -1);
      expect(result.syncResult, SyncResult.ERROR);
      expect(result.allTrashDataList.length, 0);
    });
    test(
      "Apiレスポンスが200でTrashApiSyncDataResponseのデコードに失敗した場合、TrashSyncResultのallTrashDataListが空、タイムスタンプが-1、SyncResultがERRORであること",() async {
      // http.Clientをモック化する
      http.Client mockClient = MockClient((request) async {
        return Response('{'
            '"description": "['
            '{\\"id\\":\\"1\\",\\"type\\":\\"burn\\",\\"trash_val\\":\\"\\",\\"schedules\\":[{\\"type\\":\\"weekday\\",\\"value\\":\\"0\\"}],\\"excludes\\":[]},'
            '{\\"id\\":\\"2\\",\\"type\\":\\"unburn\\",\\"schedules\\":[{\\"type\\":\\"month\\",\\"value\\":3}],\\"excludes\\":[]},'
            '{\\"id\\":\\"3\\",\\"type\\":\\"bottole\\",\\"schedules\\":[{\\"type\\":\\"biweek\\",\\"value\\":\\"3-2\\"}],\\"excludes\\":[]},'
            '{\\"id\\":\\"4\\",\\"type\\":\\"other\\",\\"trash_val\\":\\"test_trash_id\\",\\"schedules\\":[{\\"type\\":\\"evweek\\",\\"value\\":{\\"interval\\":2,\\"weekday\\":\\"0\\"}}],\\"excludes\\":[]}'
            ']", "timestamp": 12345678, "platform": "ios"}', 200);
      });
      TrashApiInterface trashApi = TrashApi("https://example.com", mockClient);
      TrashSyncResult result = await trashApi.syncTrashData("test_user_id");
      expect(result, isNotNull);
      expect(result.timestamp, -1);
      expect(result.syncResult, SyncResult.ERROR);
      expect(result.allTrashDataList.length, 0);
    });
  });
}