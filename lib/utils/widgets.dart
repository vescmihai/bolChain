import 'dart:developer';

import 'package:bolchain/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class TransactionNotificationSnackbarContent extends StatelessWidget {
  const TransactionNotificationSnackbarContent({
    super.key,
    required this.to,
    required this.address,
    required this.network,
    required this.value,
    required this.from,
  });
  final String from;
  final String to;
  final String address;
  final Network network;
  final double value;
  @override
  Widget build(BuildContext context) {
    log(from + " " + to);
    return ListTile(
      contentPadding: EdgeInsets.all(8),
      tileColor: Colors.lightGreen.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      leading: Icon(
        from == address
            ? FontAwesomeIcons.circleChevronUp
            : FontAwesomeIcons.circleChevronDown,
        color: Colors.green,
      ),
      title: Text(
        from == address ? "Envio exitoso" : "Transferencia recibida",
        style: TextStyle(
            fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green),
      ),
      subtitle: Text.rich(TextSpan(children: [
        TextSpan(text: from == address ? "Destino:$to" : "Origen:$from"),
      ])),
      trailing: Text(value.toStringAsFixed(8)),
    );
  }
}

class IconLabelBtn extends StatelessWidget {
  const IconLabelBtn({
    super.key,
    required this.onPressed,
    required this.color,
    required this.icon,
    required this.text,
    this.padding,
  });
  final Function() onPressed;
  final Color color;
  final Widget icon;
  final Widget text;
  final EdgeInsetsGeometry? padding;
  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      style: ButtonStyle(
        padding:padding==null?null:MaterialStateProperty.all(padding),
        backgroundColor: MaterialStateProperty.all(color),
        elevation: MaterialStateProperty.all(0),
        shape: MaterialStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
      ),
      onPressed: onPressed,
      icon: icon,
      label: text,
    );
  }
}
