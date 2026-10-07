import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

class TextLink {
  const TextLink(this.text, this.onTap);

  final String text;
  final VoidCallback? onTap;
}

/// Rich text built from a localized template such as
/// `"Don't have an account? {link}"`, where each placeholder token is replaced
/// by a tappable [TextLink]. Keeping the link inside the template lets each
/// language put it wherever its grammar needs.
class LinkedText extends StatefulWidget {
  const LinkedText({
    super.key,
    required this.template,
    required this.links,
    required this.style,
    required this.linkStyle,
    this.textAlign = TextAlign.start,
  });

  final String template;

  /// Placeholder token (e.g. `{link}`) → link.
  final Map<String, TextLink> links;
  final TextStyle style;
  final TextStyle linkStyle;
  final TextAlign textAlign;

  @override
  State<LinkedText> createState() => _LinkedTextState();
}

class _LinkedTextState extends State<LinkedText> {
  final _recognizers = <String, TapGestureRecognizer>{};

  @override
  void initState() {
    super.initState();
    _createRecognizers();
  }

  @override
  void didUpdateWidget(LinkedText oldWidget) {
    super.didUpdateWidget(oldWidget);
    _disposeRecognizers();
    _createRecognizers();
  }

  @override
  void dispose() {
    _disposeRecognizers();
    super.dispose();
  }

  void _createRecognizers() {
    for (final MapEntry(:key, value: link) in widget.links.entries) {
      if (link.onTap case final onTap?) {
        _recognizers[key] = TapGestureRecognizer()..onTap = onTap;
      }
    }
  }

  void _disposeRecognizers() {
    for (final recognizer in _recognizers.values) {
      recognizer.dispose();
    }
    _recognizers.clear();
  }

  @override
  Widget build(BuildContext context) {
    final template = widget.template;
    final pattern = RegExp(widget.links.keys.map(RegExp.escape).join('|'));
    final spans = <InlineSpan>[];
    var start = 0;

    for (final match in pattern.allMatches(template)) {
      if (match.start > start) {
        spans.add(TextSpan(text: template.substring(start, match.start)));
      }
      final token = match.group(0)!;
      spans.add(
        TextSpan(
          text: widget.links[token]!.text,
          style: widget.linkStyle,
          recognizer: _recognizers[token],
        ),
      );
      start = match.end;
    }
    if (start < template.length) {
      spans.add(TextSpan(text: template.substring(start)));
    }

    return Text.rich(
      TextSpan(style: widget.style, children: spans),
      textAlign: widget.textAlign,
    );
  }
}
