import "package:angular2/angular2.dart";
import "../ng2-bootstrap-config.dart";
import "../position.dart";
import 'dart:html';
import 'dart:async';
import 'package:node_shims/js.dart';

const TEMPLATE = const {
  Ng2BootstrapTheme.BS4 :
  '''
  <div class="dropdown-menu"
      [ng-style]="{top: top, left: left, display: display}"
      style="display: block">
      <a href="#"
         *ngFor="#match of matches"
         (click)="selectMatch(match, \$event)"
         [ngClass]="{active: isActive(match) }"
         (mouseenter)="selectActive(match)"
         class="dropdown-item"
         [inner-html]="hightlight(match, query)"></a>
  </div>
  ''',
  Ng2BootstrapTheme.BS3: '''
  <ul class="dropdown-menu"
      [ng-style]="{top: top, left: left, display: display}"
      style="display: block">
    <li *ngFor="#match of matches"
        [ngClass]="{active: isActive(match) }"
        (mouseenter)="selectActive(match)">
        <a href="#" (click)="selectMatch(match, \$event)" tabindex="-1" [inner-html]="hightlight(match, query)"></a>
    </li>
  </ul>
  '''
};

class TypeaheadOptions {
  String placement;

  bool animation;

  TypeaheadOptions({this.placement, this.animation});
}

@Component (selector: "n2s-typeahead-dropdown",
    templateUrl: 'typeahead_container.html',
    styles: const ['''
n2s-typeahead-dropdown {
  position: static;
}
'''
    ],
    encapsulation: ViewEncapsulation.None)
class TypeaheadContainer {
  ElementRef element;

  Typeahead parent;

  String query;

  List _matches = [];

  var _active;

  String top;

  String left;

  String display;

  String placement;

  bool animation;

  TypeaheadContainer(this.element, TypeaheadOptions typeaheadOptions)
      :
        placement = typeaheadOptions.placement,
        animation = typeaheadOptions.animation;

  List<String> get matches {
    return _matches;
  }

  set matches(List<String> value) {
    _matches = value;
    if (_matches.length > 0) {
      _active = _matches[0];
    }
  }

  position(ElementRef hostEl) {
    display = "block";
    top = "0px";
    left = "0px";
    var p = positionElements(
        hostEl.nativeElement, element.nativeElement.children[0],
        placement, false);
    top = p.topPx;
    left = p.leftPx;
  }

  selectActiveMatch() {
    selectMatch(_active);
  }

  prevActiveMatch() {
    var index = matches.indexOf(_active);
    _active =
    matches[index - 1 < 0 ? matches.length - 1 : index - 1];
  }

  nextActiveMatch() {
    var index = matches.indexOf(_active);
    _active =
    matches[index + 1 > matches.length - 1 ? 0 : index + 1];
  }

  selectActive(value) {
    _active = value;
  }

  bool isActive(value) {
    return _active == value;
  }

  selectMatch(value, [Event e = null]) {
    if (e != null) {
      e.stopPropagation();
      e.preventDefault();
    }
    parent.changeModel(_itemString(value, parent.optionField));
    parent.selectedItemChange.add(value);
    return false;
  }

  /// captures the whole query string and replace it with the string that will be used to match
  /// the results, for example if the capture is "a" the result will be \a
  RegExp escapeRegexp(String queryToEscape) =>
      new RegExp(queryToEscape.replaceAll(new RegExp(r'([.?*+^$[\]\\(){}|-])'), r"\$1"), caseSensitive: false);

  hightlight(item, String query) {
    String itemStr = _itemString(item, parent.optionField);
    // Replaces the capture string with a the same string inside of a "strong" tag
    return query != null && !query.isEmpty
        ? itemStr.replaceAllMapped(escapeRegexp(query), (m) => "<strong>${m[0]}</strong>")
        : itemStr;
  }
}
/// Returns the item as string
_itemString(item, String optionField) =>
    item is String ? item : item[optionField];

// todo: options loading by http not yet implemented
@Component(
    selector: "n2s-typeahead",
    template: '<input type="text"[(ngModel)]="cd.model" (keyup)="onTypeaheadChange(\$event)" class="form-control">')
class Typeahead extends DefaultValueAccessor implements OnInit {

  Typeahead(this.cd, Renderer renderer, ElementRef elementRef, this.loader)
      : element = elementRef,
        renderer = renderer,
        super(renderer, elementRef) {
    cd.valueAccessor = this;
  }

  NgModel cd;

  @Input() var context;

  ElementRef element;

  Renderer renderer;

  DynamicComponentLoader loader;

  TypeaheadContainer container;

  @Output() EventEmitter onLoading = new EventEmitter();

  @Output() EventEmitter onNoResults = new EventEmitter();

  @Output() EventEmitter selectedItemChange = new EventEmitter();

  @Input() num minLength = 1;

  @Input() num waitMs = 0;

  @Input() num optionsLimit = 20;

  // todo: not yet implemented
  @Input() bool appendToBody;

  // todo: not yet implemented
  @Input() bool editable;

  // todo: not yet implemented
  @Input() bool focusFirst;

  // todo: not yet implemented
  @Input() dynamic inputFormatter;

  // todo: not yet implemented
  @Input() bool selectOnExact;

  // todo: not yet implemented
  @Input() String templateUrl;

  // todo: not yet implemented
  @Input() String popupTemplateUrl;

  // todo: not yet implemented
  @Input() bool selectOnBlur;

  // todo: not yet implemented
  @Input() bool focusOnSelect;

  @Input() String optionField;

  @Input() bool async = false;

  Function debouncer;

  @Input() dynamic source;

  List _matches = [];

  get matches => _matches;

  @Input() bool autocomplete;

  String placement = "bottom-left";

  Future<ComponentRef> popup;

  Function debounce(Function func, num wait) {
    dynamic timeout;
//    List<dynamic> args;
    DateTime timestamp;
    num waitOriginal = wait;
    return () {
      // save details of latest call
//      args = [].slice.call(arguments, 0);
      timestamp = new DateTime.now();
      // trick is about implementing of 'typeaheadWaitMs'

      // in this case we have adaptive 'wait' parameter

      // we should use standard 'wait'('waitOriginal') in case of

      // popup is opened, otherwise - 'typeaheadWaitMs' parameter
      wait = truthy(container) ? waitOriginal : waitMs;
      // this is where the magic happens
      later() {
        // how long ago was the last call
        var last = new DateTime.now()
            .difference(timestamp)
            .inMilliseconds;
        // if the latest call was less than the wait period ago
        // then we reset the timeout to wait for the difference
        if (last < wait) {
          timeout = new Timer(new Duration(milliseconds: wait - last), later);
        } else {
          timeout = null;
          func();
        }
      };
      // we only need to set the timer now if one isn't already running
      if (falsey(timeout)) {
        timeout = new Timer(new Duration(milliseconds: wait), later);
      }
    };
  }

  processMatches() {
    if (cd.model.length >= minLength) {
      mapper(item) =>
          //todo: add check for complex objects
      item is String
          ? item
          : item[optionField];
      if (source is Function) {
        source(cd.model).then((Iterable matches) {
          _matches = matches.take(optionsLimit).toList();
          finalizeAsyncCall();
        });
      } else if (source is Iterable) {
        var query = new RegExp(cd.model);
        _matches = source.where((item) => /*
          */item is Map && item[optionField] != null && query.hasMatch(item[optionField]) ||
            item is String && query.hasMatch(item)
        ).take(optionsLimit).toList();
        finalizeAsyncCall();
      }
    }
  }

  finalizeAsyncCall() {
    onLoading.emit(false);
    var modelLength = cd.model.length;
    onNoResults.emit(modelLength >= minLength && matches.length <= 0);
    if (modelLength <= 0 || _matches.length <= 0) {
      hide();
      return;
    }
    if (container != null && _matches.length > 0) {
      container.query = cd.model;
      container.matches = _matches;
    }
    if (falsey(container) && _matches.length > 0) {
      show(_matches);
    }
  }

  ngOnInit() {
    // async should be false in case of array
    async = source is Function;

    if (async == true) {
      debouncer = debounce(() {
        processMatches();
      }, 100);
    }
  }

  onTypeaheadChange(KeyboardEvent e) {
    if (container != null) {
      switch (e.keyCode) {
        case KeyCode.ESC:
          hide();
          return;
        case KeyCode.UP:
          container.prevActiveMatch();
          return;
        case KeyCode.DOWN:
          container.nextActiveMatch();
          return;
        case KeyCode.ENTER:
          container.selectActiveMatch();
          return;
        case KeyCode.TAB:
          if (autocomplete == true) {
            container.selectActiveMatch();
          } else {
            hide();
          }
          return;
      }
    }
    onLoading.add(true);
    if (async == true) {
      debouncer();
    } else {
      processMatches();
    }
  }

  changeModel(String value) {
    cd.viewToModelUpdate(value);
    hide();
  }

  show(List<String> matches) {
    var options = new TypeaheadOptions (placement: placement, animation: false);
    var binding = Injector.resolve([bind(TypeaheadOptions).toValue(options)]);
    popup = loader.loadNextToLocation(
        TypeaheadContainer, element, binding).then((ComponentRef componentRef) {
      componentRef.instance.position(element);
      container = componentRef.instance;
      container.parent = this;
      container.query = cd.model;
      container.matches = matches;
      element.nativeElement.focus();
      return componentRef;
    });
  }

  hide() {
    if (container != null) {
      popup.then((ComponentRef componentRef) {
        componentRef.dispose();
        container = null;
        return componentRef;
      });
    }
  }
}

@Directive(selector: '[n2s-renderer]')
class N2sRenderer {

  N2sRenderer(this.templateRef) {

  }

  TemplateRef templateRef;

}