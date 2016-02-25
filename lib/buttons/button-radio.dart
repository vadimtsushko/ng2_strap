import "package:angular2/angular2.dart";
import 'dart:async';

@Directive(selector: "n2s-btn-radio",
    inputs: const [ "option", "uncheckable"],
    host: const { "(click)" : "onClick()", "[class.active]" : "active"})
class ButtonRadio extends DefaultValueAccessor {
  ButtonRadio(this.ngModel, Renderer renderer, ElementRef elementRef)
      : super (renderer, elementRef) {
    ngModel.valueAccessor = this;
  }

  NgModel ngModel;

  String option;

  bool uncheckable = true;

  bool get active => option == _value;

  var _value;

  @override
  writeValue(value) async {
      _value = value;
      super.writeValue(value);
  }

  onClick() {
    if (uncheckable != false && option == _value) {
      _value = null;
      return;
    }
    _value = option;

    ngModel.viewToModelUpdate(_value);
  }
}