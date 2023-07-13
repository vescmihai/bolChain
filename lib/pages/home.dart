import 'dart:developer';

import 'package:bolchain/di/locator.dart';
import 'package:bolchain/main.dart';
import 'package:bolchain/models/token.dart';
import 'package:bolchain/pages/token_info.dart';
import 'package:bolchain/pages/historial_transferencias.dart';
import 'package:bolchain/pages/transferencia.dart';
import 'package:bolchain/services/servicio_cuenta.dart';
import 'package:bolchain/services/servicio_api.dart';
import 'package:bolchain/ui_helper/home_ui_helper.dart';
import 'package:bolchain/utils/utils.dart';
import 'package:bolchain/utils/widgets.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import 'cuentas.dart';

class HomePage extends StatelessWidget {
  static const route = "/homePage";
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // var provider = Provider.of<HomePageUiHelper>(context);
    return Scaffold(
        body: SafeArea(
      child: Column(
        children: [
          Container(
            height: MediaQuery.sizeOf(context).height * (3.5 / 4),
            child: const Column(
              children: [
                TopBar(),
                Expanded(child: WalletInfo()),
              ],
            ),
          ),

        ],
      ),
    ));
  }
}



class WalletInfo extends StatelessWidget {
  const WalletInfo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String? address =
        context.select<HomePageUiHelper, String?>((value) => value.address);
    String balance =
        context.select<HomePageUiHelper, String>((value) => value.balance);
    String usdtBalance =
        context.select<HomePageUiHelper, String>((value) => value.usdtBalance);
    String symbol = symbols[context.read<HomePageUiHelper>().network];
    double usdToBs = 6.96; // Tasa de cambio USD a bolivianos
    double balanceBs = double.parse(usdtBalance) * usdToBs; // Conversión a bolivianos

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          TextButton.icon(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: address ?? ""));

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Llave pública copiada con éxito',
                  ),
                ),
              );
            },
            icon: const Icon(
              Icons.copy,
              size: 15,
            ),
            label: SizedBox(
              width: 100,
              child: Text(
                address ?? "",
                style: const TextStyle(overflow: TextOverflow.ellipsis),
              ),
            ),
          ),
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              text: "${balanceBs.toStringAsFixed(2)} Bs",
              style: const TextStyle(
                fontSize: 45,
                fontWeight: FontWeight.w500,
                color: Color.fromARGB(255, 66, 165, 245),
              ),
              children: [
                TextSpan(
                  text: "\n\n\$$usdtBalance USD",
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.normal,
                    color: Colors.greenAccent.shade700,
                  ),
                ),
                TextSpan(
                  text: "\n$balance $symbol",
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.normal,
                    color: Colors.grey.shade800,
                  ),
                ),
              ],
            ),
          ),
          SizedBox( // Ajuste de tamaño del botón
            height: 68,
            width: 350,
            child: IconLabelBtn(
              text: Text(
                "Transferir",
                style: TextStyle(color: Colors.blue.shade800, fontSize: 20),
              ),
              onPressed: () {
                Navigator.pushNamed(context, TransactionPage.route);
              },
              color: Colors.blue.shade200,
              icon: Icon(
                Icons.send_rounded,
                color: Colors.blue.shade800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}



class TopBar extends StatelessWidget {
  const TopBar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Padding(
          padding: EdgeInsets.all(2.0),
          child: Icon(
            Icons.wallet_rounded,
            color: Colors.blue,
            size: 30,
          ),
        ),
        const Padding(
          padding: EdgeInsets.all(2.0),
          child: Text(
            "BolChain",
            style: TextStyle(
                color: Colors.blue, fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        const Spacer(),
        const NetworksButton(),
        IconButton(
            onPressed: () {
              Navigator.pushNamed(
                context,
                TransactionHistoryPage.route,
              );
            },
            icon: Icon(FontAwesomeIcons.fileInvoice,
                color: Colors.blue.shade800)),
        Padding(
          padding: const EdgeInsets.only(right: 8, left: 2),
          child: PopupMenuButton<String>(
            elevation: 2,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            position: PopupMenuPosition.under,
            child: Icon(
              Icons.settings_rounded,
              color: Colors.grey.shade900,
            ),
            onSelected: (String value) {
              switch (value) {
                case "Copiarllaveprivada":
                  AccountService.retrievePrivateKey(
                          context.read<HomePageUiHelper>().address!)
                      .then((value) {
                    Clipboard.setData(ClipboardData(text: value ?? ""));

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Llave privada copiada con éxito',
                        ),
                      ),
                    );
                  });

                case "Cuentas":
                  // AccountService.deletePrivateKey();
                  Navigator.popAndPushNamed(context, OnboardingPage.route);
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                ("Copiar llave privada", Icons.security_rounded),
                ("Cuentas", Icons.account_circle_rounded)
              ]
                  .map(((String, IconData) v) => PopupMenuItem<String>(
                        value: v.$1.replaceAll(' ', ''),
                        child: Row(
                          children: [
                            Container(
                              margin: const EdgeInsets.all(8.0),
                              child: Icon(v.$2),
                            ),
                            Text(
                              v.$1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ))
                  .toList();
            },
          ),
        ),
      ],
    );
  }
}

class NetworksButton extends StatelessWidget {
  const NetworksButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    Color iconColor;
    String text;
    Network network = context.select<HomePageUiHelper, Network>(
      (value) => value.network,
    );
    switch (network) {
      case Network.ethereumMainnet:
        iconColor = Colors.teal;
        text = "ethereum";
      case Network.sepoliaTestnet:
        iconColor = Colors.purple;
        text = "Sepolia";
    }
    return MaterialButton(
      onPressed: () {
        context.read<HomePageUiHelper>().changingNetwork
            ? ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Network change in progress!',
                  ),
                  margin: EdgeInsets.only(bottom: 30),
                ),
              )
            : context.read<HomePageUiHelper>().changeNetwork();
      },
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.all(2.0),
            child: Icon(
              Icons.circle,
              color: iconColor,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(2.0),
            child: Text(
              text,
              style: TextStyle(color: Colors.grey.shade900, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
