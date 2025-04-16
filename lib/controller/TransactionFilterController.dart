import '../controller/TransactionController.dart';
import 'package:get/get.dart';

import 'APIController.dart';
import 'TransactionController.dart';

class TransactionFilterController extends APIController<bool> {
  int _total = -1;
  TransactionController parent;

  get searchHintText => 'search'.tr;

  int get total => _total;

  set total(int value) {
    _total = value;
  }

  Map<String, dynamic> initFilters = {
    'page': '0',
    'search': '',
    'category': null,
    'position': null,
    'bookmark': null,

    // 'panel': '',
  };
  late Map<String, dynamic> filters;

  TransactionFilterController({required this.parent}) {
    filters = {...initFilters};
  }

  @override
  onInit() {
    change(GetStatus.success(true));
    super.onInit();
  }

  dynamic getFilterSelected(type, {idx}) {
    if (type == 'type') {
      return [
        filters[type] == 'win',
        filters[type] == 'charge',
        filters[type] == 'withdraw',
      ];
    } else {
      return filters[type];
    }
  }

  dynamic getFilterName(type) {
    switch (type) {
      case 'type':
        return "${filters[type]}".tr;
      case 'bookmark':
        return filters[type] == 1 ? '➕' : '➖';

      default:
        return filters[type].toString();
    }
  }

  dynamic toggleFilter(String type, {idx}) {
    if (idx == null) {
      filters[type] = null;
    } else {
      switch (type) {
        case 'type':
          if (idx == 0) {
            if (filters[type] == 'win') {
              filters[type] = null;
            } else {
              filters[type] = 'win';
            }
          } else if (idx == 1) {
            if (filters[type] == 'charge') {
              filters[type] = null;
            } else {
              filters[type] = 'charge';
            }
          } else if (idx == 2) {
            if (filters[type] == 'withdraw') {
              filters[type] = null;
            } else {
              filters[type] = 'withdraw';
            }
          }
          break;
      }
    }

    update();
    this.parent.getData(param: {'page': 'clear'});
  } //set pre filters for list

  void set(Map<String, String> filter) {
    filters = {...initFilters};
    if (filter == {}) {
    } else {
      for (var key in filter.keys) {
        filters[key] = filter[key];
      }
    }
  }
}
