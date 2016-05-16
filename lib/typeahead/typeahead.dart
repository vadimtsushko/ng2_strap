import "package:angular2/angular2.dart";
import "../position.dart";
import 'dart:html';
import 'dart:async';
import 'package:node_shims/js.dart';
import 'package:ng2_strap/dropdown/index.dart';
import 'package:ng2_strap/index.dart';

///// Options to create a [N2sTypeAhead]
//class N2sTypeAheadOptions {
//
//  /// constructs a [N2sTypeAheadOptions]
//  N2sTypeAheadOptions({this.placement, this.animation});
//
//  /// position of the dropdown menu
//  String placement;
//
//  /// if `true` dropdown will be animated on show and hide
//  bool animation;
//}
//
///// Creates a type-ahead-dropdown container
//@Component (selector: "n2s-type-ahead-dropdown",
//    templateUrl: 'typeahead_container.html',
//    styles: const ['''
//n2s-type-ahead-dropdown {
//  position: static;
//}
//'''],
//    encapsulation: ViewEncapsulation.None)
//class N2sTypeAheadContainer {
//
//  /// Constructs a [N2sTypeAheadContainer] injecting its DOM [elementRef], and the [typeAheadOptions]
//  N2sTypeAheadContainer(this.elementRef, N2sTypeAheadOptions typeAheadOptions)
//      : placement = typeAheadOptions.placement,
//        animation = typeAheadOptions.animation;
//
//  /// DOM element reference
//  ElementRef elementRef;
//
//  /// provides the parent [N2sTypeAhead]
//  N2sTypeAhead parent;
//
//  /// provides the value of the user entered value in the text-box
//  String query;
//
//  /// if `true` the dropdown will be showed
//  var _active;
//
//  /// top style position in pixels
//  String top;
//
//  /// left style position in pixels
//  String left;
//
//  /// display style of the element, it could be: 'block' or 'none'
//  String display;
//
//  /// position of the dropdown menu
//  String placement;
//
//  /// if `true` dropdown will be animated on show and hide
//  bool animation;
//
//  /// provides the list of items that matches the [query]
//  List _matches = [];
//
//  /// gets the list of items that matches the [query]
//  List<String> get matches {
//    return _matches;
//  }
//
//  /// sets the list of items that matches the [query]
//  void set matches(List<String> value) {
//    _matches = value;
//    if (_matches.length > 0) {
//      _active = _matches[0];
//    }
//  }
//
//  /// positions this element at the specified [placement] value of the [hostElement]
//  position(ElementRef hostElement) {
//    display = "block";
//    top = "0px";
//    left = "0px";
//    var p = positionElements(
//        hostElement.nativeElement, elementRef.nativeElement.children[0],
//        placement, false);
//    top = p.topPx;
//    left = p.leftPx;
//  }
//
//  /// makes the active/highlited item the matched item
//  selectActiveMatch() {
//    selectMatch(_active);
//  }
//
//  /// makes the next item active/highlighted
//  prevActiveMatch() {
//    var index = matches.indexOf(_active);
//    _active = matches[index - 1 < 0 ? matches.length - 1 : index - 1];
//  }
//
//  /// makes the next item active/highlighted
//  nextActiveMatch() {
//    var index = matches.indexOf(_active);
//    _active = matches[index + 1 > matches.length - 1 ? 0 : index + 1];
//  }
//
//  /// makes the [value] active/highlighted
//  selectActive(value) {
//    _active = value;
//  }
//
//  /// checks if the value is equals to the active item, this is used to highlight the matched item
//  bool isActive(value) {
//    return _active == value;
//  }
//
//  /// selects the matched item
//  selectMatch(value, [Event e = null]) {
//    if (e != null) {
//      e.stopPropagation();
//      e.preventDefault();
//    }
//    parent.changeModel(_itemString(value, parent.optionField));
//    parent.selectedItemChange.add(value);
//    return false;
//  }
//
//  /// captures the whole query string and replace it with the string that will be used to match
//  /// the results, for example if the capture is "a" the result will be \a
//  RegExp escapeRegexp(String queryToEscape) =>
//      new RegExp(queryToEscape.replaceAll(new RegExp(r'([.?*+^$[\]\\(){}|-])'), r"\$1"), caseSensitive: false);
//
//  /// highlights the matching part of the matched item. For example if user types "a" and the matched
//  /// word is "Alaska" the result will be `<strong>A</strong>l<strong>a</strong>sk<strong>a</strong>`
//  String highlight(item, String query) {
//    String itemStr = _itemString(item, parent.optionField);
//    // Replaces the capture string with a the same string inside of a "strong" tag
//    return query != null && !query.isEmpty
//        ? itemStr.replaceAllMapped(escapeRegexp(query), (m) => "<strong>${m[0]}</strong>")
//        : itemStr;
//  }
//}
///// Returns the item as string
//_itemString(item, String optionField) =>
//    item is String ? item : item[optionField];

// todo: options loading by http not yet implemented
/// Creates a type-ahead component
///
/// [demo](http://luisvt.github.io/ng2_strap/#typeahed)
@Component(
    selector: "n2s-type-ahead",
    templateUrl: 'typeahead.html',
    directives: const [N2S_DROPDOWN_DIRECTIVES, N2sButtonCheckbox])
class N2sTypeAhead extends DefaultValueAccessor implements OnInit {

  /// Construct a N2sTypeAhead [N2sTypeAhead] component injecting [ngModel], [renderer], [elementRef]
  N2sTypeAhead(this.ngModel, Renderer renderer, ElementRef elementRef)
      : super(renderer, elementRef) {
    ngModel.valueAccessor = this;
  }

  /// binds to string user's input
  NgModel ngModel;

  /// fires 'busy' state of this component was changed, fired on `async` mode only, returns
  /// `boolean`
  @Output() EventEmitter loading = new EventEmitter();

  /// fires `true` in case of matches are not detected when any user key event occurs
  @Output() EventEmitter noResults = new EventEmitter();

  /// fired when option was selected, return object with data of this option
  @Output() EventEmitter selectedItemChange = new EventEmitter();

  /// minimal no of characters that needs to be entered before typeahead kicks-in. Must be greater
  /// than or equal to 1.
  @Input() num minLength = 1;

  /// minimal wait time after last character typed before typeahead kicks-in
  @Input() num waitMs = 0;

  /// maximum length of options items list
  @Input() num optionsLimit = 20;

  /// (*not implemented*) (`?boolean=true`) - if `false` restrict model values to the ones selected from the popup only will be provided
  // todo: not yet implemented
  @Input() bool editable;

  /// (*not implemented*) (`?boolean=true`) - if `false` the first match automatically will not be focused as you type
  // todo: not yet implemented
  @Input() bool focusFirst;

  /// (*not implemented*) (`?any`) - format the ngModel result after selection
  // todo: not yet implemented
  @Input() dynamic inputFormatter;

  /// (*not implemented*) (`?boolean=false`) - if `true` automatically select an item when there is one option that exactly matches the user input
  // todo: not yet implemented
  @Input() bool selectOnExact;

  /// (*not implemented*) (`?boolean=false`) - if `true` select the currently highlighted match on blur
  // todo: not yet implemented
  @Input() bool selectOnBlur;

  /// (*not implemented*) (`?boolean=true`) - if `false` don't focus the input element the typeahead directive is associated with on selection
  // todo: not yet implemented
  @Input() bool focusOnSelect;

  /// (`?string`) - name of field in array of states that contain options as objects, we use array
  /// item as option in case of this field is missing
  @Input() String optionField;

  /// (`?boolean`) - should be used only in case of `typeahead` attribute is array. If `true` -
  /// loading of options will be sync, otherwise - async. `true` make sense if options array is large.
  bool async = false;

  ///
  Function debouncer;

  /// provides the source of the dropdown list, it could be any [Iterable] list or an [Function],
  /// if a function is passed, it means the list of elements is going to be loaded asynchronously.
  @Input() dynamic source;

  /// list of elements that match the typed input
  List matches = [];

  /// if `true` active option will be selected automatically
  @Input() bool autocomplete;

  /// if `true` the dropdown-menu will be open, and the date-picker visible
  bool isOpen;

  ///
  void processMatches() {
    if (ngModel.model.length >= minLength) {
      // if source is function we should retrieve the results asynchronously
      if (source is Function) {
        source(ngModel.model).then((Iterable matchesAux) {
          matches = matchesAux.take(optionsLimit).toList();
        });
      } else if (source is Iterable) {
        var query = new RegExp(ngModel.model);
        matches = source.where((item) => /*
          */item is Map && item[optionField] != null && query.hasMatch(item[optionField]) ||
            item is String && query.hasMatch(item)
        ).take(optionsLimit).toList();
      }
    }
  }

  ///
  ngOnInit() {
    // async should be false in case of array
    async = source is Function;

    if (async == true) {

    }
  }
//
//  /// fired when user do a keyboard event
//  onTypeaheadChange(KeyboardEvent e) {
//    if (container != null) {
//      switch (e.keyCode) {
//        case KeyCode.ESC:
//          hide();
//          return;
//        case KeyCode.UP:
//          container.prevActiveMatch();
//          return;
//        case KeyCode.DOWN:
//          container.nextActiveMatch();
//          return;
//        case KeyCode.ENTER:
//          container.selectActiveMatch();
//          return;
//        case KeyCode.TAB:
//          if (autocomplete == true) {
//            container.selectActiveMatch();
//          } else {
//            hide();
//          }
//          return;
//      }
//    }
//    loading.add(true);
//    if (async == true) {
//      debouncer();
//    } else {
//      processMatches();
//    }
//  }

  /// fired when model changes
  changeModel(String value) {
    ngModel.viewToModelUpdate(value);
//    hide();
  }

//  /// show the matches
//  show(List<String> matches) {
//    var options = new N2sTypeAheadOptions (placement: placement, animation: false);
//    var binding = Injector.resolve([bind(N2sTypeAheadOptions).toValue(options)]);
//    popup = loader.loadNextToLocation(
//        N2sTypeAheadContainer, element, binding).then((ComponentRef componentRef) {
//      componentRef.instance.position(element);
//      container = componentRef.instance;
//      container.parent = this;
//      container.query = ngModel.model;
//      container.matches = matches;
//      element.nativeElement.focus();
//      return componentRef;
//    });
//  }
}

/// This component is used to pass an html template to the dropdown-menu-item
@Directive(selector: 'template[n2s-renderer]')
class N2sRenderer {

  /// constructs a [N2sRenderer] passing the [templateRef]
  N2sRenderer(this.templateRef);

  /// current DOM element reference.
  TemplateRef templateRef;

}
