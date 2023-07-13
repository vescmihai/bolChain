import 'dart:developer';

import 'package:bolchain/di/locator.dart';
import 'package:bolchain/excepciones/excepciones_historial_transferencias.dart';
import 'package:bolchain/models/transaccion.dart';
import 'package:bolchain/services/servicio_historial_transferencias.dart';
import 'package:bolchain/ui_helper/home_ui_helper.dart';
import 'package:bolchain/utils/utils.dart';
import 'package:flutter/material.dart';

class TransactionHistoryPageUiHelper extends ChangeNotifier {
  TransactionHistoryPageUiHelper() {
    _isLoading = true;
    if (getIt<HomePageUiHelper>().address != null) {
      loadNext().then((value) {
        _isLoading = false;
        notifyListeners();
      });
    }

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent &&
          !_pageLoading) {
        log("loadMore");
        if (!_end) {
          loadNext().then((value) => notifyListeners());
        }
      }
    });
  }
  final TransactionHistoryService _transactionHistoryService =
      TransactionHistoryService();
  List<Transaction> _allTransactions = [];
  List<Transaction> get allTransactions => _allTransactions;

  TransactionHistoryException? _exception;
  TransactionHistoryException? get exception => _exception;

  bool _isLoading = false;
  bool get isLoading => _isLoading;
  bool _pageLoading = false;
  // bool get pageLoading => _pageLoading;
  bool _end = false;

  final ScrollController _scrollController = ScrollController();
  ScrollController get scrollController => _scrollController;

  Future<void> loadNext() async {
    log("loadNext");
    _pageLoading = true;

    var transactions = await _transactionHistoryService.getAllTransactions(
      getIt<HomePageUiHelper>().address!,
      getIt<HomePageUiHelper>().network,
    );
    transactions.fold((l) {
      _allTransactions += l;
      log(l.length.toString());
    }, (r) {
      log(r.message);
      if (r.eType != TransactionHistoryEType.somethingElse) {
        _end = true;
      }
      _exception = r;
    });
    _pageLoading = false;
  }
}
