part of ns_datepicker;

/// Highly configurable component that adds datepicker functionality to
/// your pages. You can customize the date format and language, restrict the selectable date ranges.
///
/// Base specifications: [jquery-ui](https://api.jqueryui.com/datepicker/)
///
/// [demo](http://luisvt.github.io/ng2_strap/#datepicker)
@Component (selector: "n2s-datepicker",
    templateUrl: 'datepicker.html',
    directives: const [
      DatePickerInner,
      DayPicker,
      MonthPicker,
      YearPicker
    ])
class N2sDatePicker extends DefaultValueAccessor {
  /// Constructs a [N2sDatePicker] component injecting [NgModel], [Renderer], and [ElementRef]
  N2sDatePicker(this.cd, Renderer renderer, ElementRef elementRef)
      : super (renderer, elementRef) {
    cd.valueAccessor = this;
  }

  /// sets datepicker mode, supports: `day`, `month`, `year`
  @Input() String datepickerMode;

  @Input() DateTime initDate;

  /// oldest selectable date
  @Input() DateTime minDate;

  /// latest selectable date
  @Input() DateTime maxDate;

  /// set lower datepicker mode, supports: `day`, `month`, `year`
  @Input() String minMode;

  /// sets upper datepicker mode, supports: `day`, `month`, `year`
  @Input() String maxMode;

  /// if `false` week numbers will be hidden
  @Input() bool showWeeks;

  /// format of day in month
  @Input() String formatDay;

  /// format of month in year
  @Input() String formatMonth;

  /// format of year in year range
  @Input() String formatYear;

  /// format of day in week header
  @Input() String formatDayHeader;

  /// format of title when selecting day
  @Input() String formatDayTitle;

  /// format of title when selecting month
  @Input() String formatMonthTitle;

  /// starting day of the week from 0-6 (0=Sunday, ..., 6=Saturday).
  @Input() num startingDay;

  /// number of years displayed in year selection
  @Input() num yearRange;

  /// if `true` shortcut`s event propagation will be disabled
  @Input() bool shortcutPropagation;

  /// array of custom classes to be applied to targeted dates
  // todo: change type during implementation
  dynamic customClass;

  /// array of disabled dates if `mode` is `day`, or years, etc.
  // todo: change type during implementation
  @Input() dynamic dateDisabled;

  ///
  NgModel cd;

  ///
  DateTime _activeDate;

  ///
  DateTime get activeDate => _activeDate;

  ///
  @Input() set activeDate(DateTime value) {
    _activeDate = value;
    cd.viewToModelUpdate(this.activeDate.toString());
  }

  ///
  onUpdate(event) {
    this.writeValue(event);
  }

  ///
  writeValue(dynamic value) {
    if (value != null) {
      if (value is String) {
        value = DateTime.parse(value);
      }
      activeDate = value;
    }
  }
}