import 'dart:async';
import 'dart:developer';
import 'package:bolchain/di/locator.dart';
import 'package:bolchain/main.dart';
import 'package:bolchain/models/transaccion_minada_model.dart';
import 'package:bolchain/models/token.dart';
import 'package:bolchain/models/tokens_model.dart';
import 'package:bolchain/models/transaccion.dart';
import 'package:bolchain/models/transaccion_model.dart';
import 'package:bolchain/services/servicio_cuenta.dart';
import 'package:bolchain/services/servicio_api.dart';
import 'package:bolchain/utils/utils.dart';
import 'package:bolchain/utils/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:web3dart/crypto.dart';

typedef ContractAddress = String;
typedef tokenInfoPageArgs = ({String? logo, String name, String symbol});

class HomePageUiHelper extends ChangeNotifier {
  HomePageUiHelper() {
    _init();
  }
  @override
  void dispose() {
    log("dispose");
   if (_closeTxnStream != null) {
      _closeTxnStream!();
    }
    // _closeEthUsdtPriceStream();
    getIt.resetLazySingleton<HomePageUiHelper>();
    super.dispose();
  }

  String? _address;
  String? get address => _address;

  double _balance = 0;
  String get balance => _balance.toStringAsFixed(4);
  double _usdtBalance = 0;
  String get usdtBalance => _usdtBalance.toStringAsFixed(4);

  Map<ContractAddress, Token> _tokens = {};
  Map<ContractAddress, Token> get tokens => _tokens;
  String _tokensMessage = "No Tokens!";
  String get tokensMessage => _tokensMessage;

  late Stream<MinedTransaction?> _txnStream;
  Function? _closeTxnStream;
  // late Stream<String?> _ethUsdtPriceStream;
  // late Function _closeEthUsdtPriceStream;

  Network _network = Network.ethereumMainnet;
  bool _changingNetwork = false;
  bool get changingNetwork => _changingNetwork;
  Network get network => _network;

  bool _loadingTokens = false;
  bool get loadingTokens => _loadingTokens;

  Future<void> _updateBalance() async {
    if (_address != null) {
      ApiService.getBalance(_address!, network).then((value) {
        if (value != null) {
          _balance = hexPriceToDouble(strip0x(value.result));
          if (_balance == 0) {
            _usdtBalance = 0;
          }
          _setUsdBalance();

          notifyListeners();
        }
      });
    }
  }

  changeNetwork() {
    _changingNetwork = true;
    _network = Network.values[(_network.index + 1) % Network.values.length];
    notifyListeners();
    if (_closeTxnStream != null) {
      _closeTxnStream!();
    }
    _startTxnStream();
    Future.wait([
      _updateBalance(),
      _getTokens(),
    ]).then((value) => _changingNetwork = false);
  }

  _init() async {
    AccountService.retrieveCurrentAccount().then((value) {
      _address = value;
      notifyListeners();
      Future.wait([
        _updateBalance(),
        _startTxnStream(),
        _getTokens(),
      ]);
    });
  }

  Future<void> _setUsdBalance() async {
    ApiService.getEthPrice().then(
      (value) => value.fold(
        (l) {
          _usdtBalance = double.parse(l.ethusd) * _balance;
          notifyListeners();
        },
        (r) {
          if (rootScaffoldMessengerKey.currentState != null) {
            rootScaffoldMessengerKey.currentState!.showSnackBar(SnackBar(
                content: Text("${r.message} ETH price could not be fetched!")));
          }
        },
      ),
    );
  }

  Future<void> _startTxnStream() async {
    if (_address != null) {
      var (txnStream, closeTxn) =
          ApiService.getTransactionStream(_address!, _network);

      _txnStream = txnStream;
      _closeTxnStream = closeTxn;
      _txnStream.listen((event) {
        if (event != null) {
          _updateBalance();
          _updateTokens();
          double price = hexPriceToDouble(strip0x(event.value));

          HapticFeedback.heavyImpact();

          rootScaffoldMessengerKey.currentState?.showSnackBar(
            SnackBar(
              content: TransactionNotificationSnackbarContent(
                  from: event.from,
                  to: event.to,
                  address: _address!,
                  network: network,
                  value: price),
              backgroundColor: Colors.transparent,
              behavior: SnackBarBehavior.floating,
              elevation: 0,
              duration: Duration(seconds: 5),
              dismissDirection: DismissDirection.vertical,
            ),
          );
        }
      });
    }
  }

  // void _startEthUsdtPriceStream() {
  //   var (priceStream, closeStream) = ApiService.getEthUsdtPriceStream();

  //   _ethUsdtPriceStream = priceStream;
  //   _closeEthUsdtPriceStream = closeStream;

  //   _ethUsdtPriceStream.listen((event) {
  //     if (event != null && _balance != 0) {
  //       _usdtBalance = double.parse(event) * _balance;
  //       notifyListeners();
  //     }
  //   });
  // }

  Future<void> _getTokens() async {
    if (_address != null) {
      _loadingTokens = true;
      notifyListeners();

      var tokenModelList = await ApiService.getErc20Tokens(_address!, network);
      log("tokens.toString()");
      Map<String, Token> tokens = {};
      tokenModelList.fold((l) {
        l
            .where((element) =>
                (network == Network.sepoliaTestnet || !element.possibleSpam))
            .forEach((element) {
          tokens[element.tokenAddress] = Token(
              amount: calculateTokenAmount(element.balance, element.decimals),
              logo: element.logo,
              name: element.name,
              symbol: element.symbol,
              usdtBalance: null);
        });
        _tokens = tokens;
      }, (r) {
        return;
      });
      _loadingTokens = false;
      notifyListeners();
    }
  }

  Future<void> _updateTokens() async {
    if (_address != null) {
      if (changingNetwork) {
        _tokens = {};
      }
      _getTokens();
    }
  }
}
