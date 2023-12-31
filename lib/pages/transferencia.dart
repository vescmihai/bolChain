import 'package:bolchain/di/locator.dart';
import 'package:bolchain/pages/token_info.dart';
import 'package:bolchain/services/servicio_cuenta.dart';
import 'package:bolchain/ui_helper/home_ui_helper.dart';
import 'package:bolchain/ui_helper/historial_transferencias_ui_helper.dart';
import 'package:bolchain/ui_helper/transferencias_ui_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class TransactionPage extends StatelessWidget {
  static const route = "/transactionPage";
  const TransactionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
          child: Container(
        margin: const EdgeInsets.all(16),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const AddressFormFieldDropDown(),
              Row(
                children: [
                  FaIcon(
                    FontAwesomeIcons.ethereum,
                    size: 35,
                  ),
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.all(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          NumpadTextField(),
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            child: Text(
                              context.select<TransactionPageUiHelper, String>(
                                  (value) => value.usdAmount),
                              style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.grey.shade900,
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            child: Text(
                              ((double.tryParse(context.select<TransactionPageUiHelper, String>(
                                        (value) => value.usdAmount)) ?? 0) * 6.96).toString(),
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.grey.shade900,
                                fontWeight: FontWeight.w500,
                              ),
                            ),

                          )
                        ],
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "ETH",
                        style: TextStyle(
                            fontSize: 30,
                            color: Colors.grey.shade900,
                            fontWeight: FontWeight.w500),
                      ),
                      Text(
                        "USD",
                        style: TextStyle(
                            fontSize: 20,
                            color: Colors.grey.shade900,
                            fontWeight: FontWeight.w500),
                      ),
                      Text(
                        "BS",
                        style: TextStyle(
                            fontSize: 20,
                            color: Colors.grey.shade900,
                            fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ],
              ),
              const GasMetrics(),
              NumberPad(
                  onNumberTap: context
                      .read<TransactionPageUiHelper>()
                      .onNumpadKeyPressed),
              const Actions()
            ]),
      )),
    );
  }
}

class Actions extends StatelessWidget {
  const Actions({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            margin: EdgeInsets.only(right: 2),
            child: OutlinedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ButtonStyle(
                  padding:
                      MaterialStateProperty.all(EdgeInsets.all(8)),
                  backgroundColor:
                      MaterialStateProperty.all(Colors.red.shade100),
                  elevation: MaterialStateProperty.all(0),
                  shape: MaterialStateProperty.all(
                      RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25)))),
              child: Text(
                "Cancelar",
                style: TextStyle(
                    color: Colors.red,
                    fontSize: 25,
                    fontWeight: FontWeight.normal),
              ),
            ),
          ),
        ),
        Expanded(
          child: Container(
            margin: EdgeInsets.only(left: 2),
            child: MaterialButton(
              padding: EdgeInsets.all(8),
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25)),
              color: Colors.blue,
              onPressed: () {
                if (context
                    .read<TransactionPageUiHelper>()
                    .executeTransaction()) {
                  Navigator.pop(context);
                }
              },
              child: Text(
                "Confirmar",
                style: TextStyle(
                    color: Colors.blue.shade100,
                    fontSize: 25,
                    fontWeight: FontWeight.normal),
              ),
            ),
          ),
        )
      ],
    );
  }
}

class GasMetrics extends StatelessWidget {
  const GasMetrics({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            margin: EdgeInsets.only(right: 6),
            child: MetricBox(
                metricName: "Gas estimado",
                value:
                    context.select<TransactionPageUiHelper, String>(
                        (value) => value.estimatedGas)),
          ),
        ),
        Expanded(
          child: Container(
            margin: EdgeInsets.only(
              left: 6,
            ),
            child: MetricBox(
                metricName: "Precio de Gas",
                value:
                    context.select<TransactionPageUiHelper, String>(
                        (value) => value.gasPrice)),
          ),
        ),
      ],
    );
  }
}

class NumpadTextField extends StatelessWidget {
  const NumpadTextField({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      readOnly: true,
      decoration: const InputDecoration(
        isCollapsed: true,
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
        ),
      ),
      controller: TextEditingController(
          text: context.select<TransactionPageUiHelper, String>(
              (value) => value.amount)),
      style: TextStyle(
          fontSize: 40,
          color: Colors.grey.shade900,
          fontWeight: FontWeight.w500),
    );
  }
}

class AddressFormFieldDropDown extends StatelessWidget {
  const AddressFormFieldDropDown({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller:
          context.read<TransactionPageUiHelper>().addressFieldValueController,
      decoration: InputDecoration(
        suffixIcon: PopupMenuButton<String>(
          elevation: 2,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          position: PopupMenuPosition.under,
          child: Icon(Icons.arrow_drop_down_rounded),
          onSelected: (String value) {
            context.read<TransactionPageUiHelper>().setAddressFieldValue(value);
          },
          itemBuilder: (BuildContext context) {
            return context
                .read<TransactionPageUiHelper>()
                .savedAddresses
                .map((String value) {
              return PopupMenuItem<String>(
                value: value,
                child: Text(
                  value,
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }).toList();
          },
        ),
        filled: true,
        fillColor: Colors.grey[200],
        hintText: 'Llave pública',
        hintStyle: TextStyle(color: Colors.grey),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(20.0)),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class NumberPad extends StatelessWidget {
  final Function(String) onNumberTap;

  const NumberPad({super.key, required this.onNumberTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: GridView.count(
        physics: ClampingScrollPhysics(),
        shrinkWrap: true,
        crossAxisCount: 3,
        childAspectRatio: 2.2,
        padding: EdgeInsets.all(10),
        children: List.generate(9, (index) {
              return TextButton(
                child: Text((index + 1).toString(),
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.normal,
                        color: Colors.grey.shade800)),
                onPressed: () => onNumberTap((index + 1).toString()),
              );
            }) +
            [
              TextButton(
                child: Text(".",
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.normal,
                        color: Colors.grey.shade800)),
                onPressed: () => onNumberTap("."),
              ),
              TextButton(
                child: Text("0",
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.normal,
                        color: Colors.grey.shade800)),
                onPressed: () => onNumberTap("0"),
              ),
              TextButton(
                child: Icon(
                  Icons.backspace_outlined,
                  color: Colors.grey.shade800,
                ),
                onPressed: () {
                  context
                      .read<TransactionPageUiHelper>()
                      .onBackspaceKeyPressed();
                },
                onLongPress: () {
                  context.read<TransactionPageUiHelper>().clearAmount();
                },
              ),
            ],
      ),
    );
  }
}
