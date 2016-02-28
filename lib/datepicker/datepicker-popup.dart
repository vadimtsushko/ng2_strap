part of ns_datepicker;

class PopupOptions {
  String placement;

  bool animation;

  bool isOpen;

  PopupOptions({this.placement, this.animation, this.isOpen});
}

@Component (selector: "popup-container",
    template: 'popup_container.html',
    directives: const [N2sDatePicker],
    encapsulation: ViewEncapsulation.None)
class N2sPopupContainer {
  ///
  N2sPopupContainer(this .element, PopupOptions options) {
    placement = options.placement;
//    isOpen =options.isOpen;
//    animation = options.animation;
    classMap = {"in" : false, placement : true};
  }

  ElementRef element;

  /// format of displayed dates
  N2sDatePickerPopup popupComp;

  ///
  Map classMap;

  ///
  String top;

  ///
  String left;

  ///
  String display;

  ///
  String placement;

  ///
  String datepickerPopup = "YYYY-MM-dd";

  ///'current day' button title
  String currentText = "Today";

  /// 'clear' button title
  String clearText = "Clear";

  /// 'close' buttin title
  String closeText = "Done";

  /// if `true` calendar will be closed on date selection
  bool closeOnDateSelection = true;

  /// if `false` button bar, underneath the datepicker, will not be shown
  bool showButtonBar = true;

  ///
  bool onOpenFocus = true;

  ///
  @Output() EventEmitter update1 = new EventEmitter ();

  ///
  onUpdate(event) {
    print("update $event");
    if (event) {
      if (event is! DateTime) {
        event = DateTime.parse(event);
      }
      this.popupComp.activeDate = event;
    }
  }

  ///
  position(ElementRef hostEl) {
    this.display = "block";
    this.top = "0px";
    this.left = "0px";
    var p = positionElements(
        hostEl.nativeElement, this.element.nativeElement.children [ 0 ],
        this.placement, false);
    this.top = p.topPx;
  }

  ///
  bool isDisabled(DateTime date) {
    return false;
  }
}

///
@Directive (selector: "n2s-datepicker-popup",
    host: const { "(cupdate)" : "onUpdate1(\$event)"})
class N2sDatePickerPopup {
  ///
  N2sDatePickerPopup(@Self () this .cd, this .element, this .renderer,
      this .loader) {
    this.activeDate = cd.model;
  }

  ///
  NgModel cd;

  ///
  ElementRef element;

  ///
  Renderer renderer;

  ///
  DynamicComponentLoader loader;

  ///
  DateTime _activeDate;

  ///
  String placement = "bottom";

  ///
  Future<ComponentRef> popup;

  ///
  DateTime get activeDate {
    return this._activeDate;
  }

  ///
  set activeDate(DateTime value) {
    this._activeDate = value;
  }

  /// if `true` datepicker is currently shown
  bool _isOpen = false;

  /// if `true` datepicker is currently shown
  bool get isOpen {
    return this._isOpen;
  }

  /// if `true` datepicker is currently shown
  @Input() set isOpen(bool value) {
    var fn = () {
      this._isOpen = value;
    };
    if (identical(value, true)) {
      this.show(fn);
    }
    if (identical(value, false)) {
      this.hide(fn);
    }
  }

  ///
  show(Function cb) {
    var options = new PopupOptions (placement: this.placement);
    var binding = Injector.resolve([bind(PopupOptions).toValue(options)]);
    this.popup =
        this.loader.loadNextToLocation(N2sPopupContainer, this.element, binding)
            .then((ComponentRef componentRef) {
          componentRef.instance.position(this.element);
          componentRef.instance.popupComp = this;
          /*componentRef.instance.update1.observer({
         next: (newVal) => {
         setProperty(this.renderer, this.elementRef, 'value', newVal);
         }
         });*/
          cb();
          return componentRef;
        });
  }

  ///
  hide(Function cb) {
    if (this.popup != null) {
      this.popup.then((ComponentRef componentRef) {
        componentRef.dispose();
        cb();
        return componentRef;
      });
    } else {
      cb();
    }
  }
}