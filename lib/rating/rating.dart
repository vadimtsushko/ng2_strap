import "package:angular2/angular2.dart";
import 'dart:html';
import 'package:node_shims/js.dart';

// TODO: templateUrl
@Component (selector: "n2s-rating",
    host: const { "(keydown)" : "onKeydown(\$event)"},
    templateUrl: 'rating.html')
class Rating extends DefaultValueAccessor implements OnInit {
  Rating(this.cd, Renderer renderer, ElementRef elementRef)
      : super (renderer, elementRef) {
    cd.valueAccessor = this;
  }

  NgModel cd;

  @Input() num max;

  @Input() List range;

  num value;

  num preValue;

  @Input() List<String> titles;

  @Input() String stateOn;

  @Input() String stateOff;

  @Input() bool readonly;

  @Input() List ratingStates;

  @Output() EventEmitter onHover = new EventEmitter ();

  @Output() EventEmitter onLeave = new EventEmitter ();

  ngOnInit() {
    max ??= 5;
    readonly = readonly == true;
    stateOn ??= "glyphicon-star";
    stateOff ??= "glyphicon-star-empty";
    titles = titles != null && titles.length > 0  ? titles : ["one", "two", "three", "four", "five"];
    ratingStates ??= [];
    range = _buildTemplateObjects();
  }

  // model -> view
  writeValue(num _value) {
    _value ??= 0;
    if (_value != 0) {
      value = _value.round();
      preValue = _value;
      return;
    }
    preValue = _value;
    value = _value;

  }

  _buildTemplateObjects() {
    var count = or(ratingStates.length, max) ;
    var result = [];
    for (var i = 0; i < count; i++) {
      result.add({
        "index" : i,
        "stateOn" : stateOn,
        "stateOff" : stateOff,
        "title" : titles.length > i ? titles[i] : i + 1,
      }..addAll(ratingStates.length > i ? ratingStates[i] : {}));
    }
    return result;
  }

  rate(num value) {
    if (!readonly && value >= 0 && value <= range.length) {
      writeValue(value);
      cd.viewToModelUpdate(value);
    }
  }

  enter(num _value) {
    if (!readonly) {
      value = _value;
      onHover.add(_value);
    }
  }

  reset() {
    value = preValue;
    onLeave.add(value);
  }

  onKeydown(KeyboardEvent event) {
    if (![37, 38, 39, 40].contains(event.which)) {
      return;
    }
    event.preventDefault();
    event.stopPropagation();
    var sign = event.which == 38 || event.which == 39
        ? 1
        : -1;
    rate(value + sign);
  }
}