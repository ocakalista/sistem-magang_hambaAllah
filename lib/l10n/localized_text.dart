import 'package:flutter/material.dart' as material;

import 'app_localizations.dart';

export 'app_localizations.dart' show tr;

/// Drop-in replacement for Flutter's [material.Text] that translates static
/// application copy while leaving API data, names, and other unknown values
/// untouched.
class Text extends material.StatelessWidget {
  const Text(
    this.data, {
    super.key,
    this.style,
    this.strutStyle,
    this.textAlign,
    this.textDirection,
    this.locale,
    this.softWrap,
    this.overflow,
    this.textScaler,
    this.maxLines,
    this.semanticsLabel,
    this.textWidthBasis,
    this.textHeightBehavior,
    this.selectionColor,
  });

  final String data;
  final material.TextStyle? style;
  final material.StrutStyle? strutStyle;
  final material.TextAlign? textAlign;
  final material.TextDirection? textDirection;
  final material.Locale? locale;
  final bool? softWrap;
  final material.TextOverflow? overflow;
  final material.TextScaler? textScaler;
  final int? maxLines;
  final String? semanticsLabel;
  final material.TextWidthBasis? textWidthBasis;
  final material.TextHeightBehavior? textHeightBehavior;
  final material.Color? selectionColor;

  @override
  material.Widget build(material.BuildContext context) {
    return material.Text(
      AppLocalizations.of(context).translate(data),
      style: style,
      strutStyle: strutStyle,
      textAlign: textAlign,
      textDirection: textDirection,
      locale: locale,
      softWrap: softWrap,
      overflow: overflow,
      textScaler: textScaler,
      maxLines: maxLines,
      semanticsLabel:
          semanticsLabel == null
              ? null
              : AppLocalizations.of(context).translate(semanticsLabel!),
      textWidthBasis: textWidthBasis,
      textHeightBehavior: textHeightBehavior,
      selectionColor: selectionColor,
    );
  }
}
