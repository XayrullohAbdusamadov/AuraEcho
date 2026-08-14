// ignore: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:js' as js;

/// Web implementation of JS interop
void callJsMethod(String method, List<dynamic> args) {
  try {
    final audio = js.context['AuraFlutterAudio'];
    if (audio != null) {
      js.JsObject.fromBrowserObject(audio).callMethod(method, args);
    }
  } catch (_) {}
}
