import "package:angular2/angular2.dart";
import 'dart:async';

@Directive(
    selector: "n2s-btn-checkbox",
    inputs: const ["trueValue", "falseValue"],
    host: const { "(click)" : "onClick()", "[class.active]" : "active"}
)
class ButtonCheckbox extends DefaultValueAccessor {
  ButtonCheckbox(this.ngModel, Renderer renderer, ElementRef elementRef) : super(renderer, elementRef) {
    ngModel.valueAccessor = this;
  }

  NgModel ngModel;

  dynamic trueValue = true;

  dynamic falseValue = false;

  var _value;

  bool get active => trueValue == _value;

  writeValue(value) async {
      _value = value;
      super.writeValue(_value);
  }

  toggle(bool checked) {
    _value = checked ? trueValue : falseValue;
    ngModel.viewToModelUpdate(_value);
  }

  onClick() {
    toggle(!active);
  }
}