import "package:angular2/angular2.dart";
import "date-formatter.dart" show DateFormatter;
import 'package:node_shims/js.dart';
import 'dart:math';
import 'package:intl/intl.dart';

const String FORMAT_DAY = "dd";

const String FORMAT_MONTH = "MMMM";

const String FORMAT_YEAR = "yyyy";

const String FORMAT_DAY_HEADER = "E";

const String FORMAT_DAY_TITLE = "MMMM yyyy";

const String FORMAT_MONTH_TITLE = "MMMM";

const String DATEPICKER_MODE = "day";

const String MIN_MODE = "day";

const String MAX_MODE = "year";

const bool SHOW_WEEKS = true;

const num STARTING_DAY = 0;

const num YEAR_RANGE = 20;

const DateTime MIN_DATE = null;

const DateTime MAX_DATE = null;

const bool SHORTCUT_PROPAGATION = false;

@Component (selector: "n2s-datepicker-inner",
    templateUrl: 'datepicker_inner.html')
class DatePickerInner implements OnInit {
  @Input() String datepickerMode;

  num startingDay;

  @Input() num yearRange;

  Map stepDay = {};

  Map stepMonth = {};

  Map stepYear = {};

  @Input() List<String> modes = ["day", "month", "year"];

  @Input() DateFormatter dateFormatter = new DateFormatter ();

  @Input() String uniqueId;

  @Input() String activeDateId;

  @Input() DateTime minDate;

  @Input() DateTime maxDate;

  @Input() String minMode;

  @Input() String maxMode;

  @Input() bool showWeeks;

  @Input() String formatDay;

  @Input() String formatMonth;

  @Input() String formatYear;

  @Input() String formatDayHeader;

  @Input() String formatDayTitle;

  @Input() String formatMonthTitle;

  @Input() bool shortcutPropagation;

  // todo: change type during implementation
  @Input() dynamic customClass;

  // todo: change type during implementation
  @Input() dynamic dateDisabled;

  Function refreshViewHandlerDay;

  Function compareHandlerDay;

  Function refreshViewHandlerMonth;

  Function compareHandlerMonth;

  Function refreshViewHandlerYear;

  Function compareHandlerYear;

  @Output() EventEmitter update = new EventEmitter ();

  DateTime _initDate;

  DateTime get initDate {
    return _initDate;
  }

  @Input() set initDate(DateTime value) {
    _initDate = value;
  }

  DateTime _activeDate;

  DateTime get activeDate {
    return _activeDate;
  }

  @Input() set activeDate(DateTime value) {
    _activeDate = value;
    refreshView();
  }

  // todo: add formatter value to DateTime object
  ngOnInit() {
    formatDay = or(formatDay, FORMAT_DAY);
    formatMonth = or(formatMonth, FORMAT_MONTH);
    formatYear = or(formatYear, FORMAT_YEAR);
    formatDayHeader = or(formatDayHeader, FORMAT_DAY_HEADER);
    formatDayTitle = or(formatDayTitle, FORMAT_DAY_TITLE);
    formatMonthTitle = or(formatMonthTitle, FORMAT_MONTH_TITLE);
    showWeeks = or(showWeeks, SHOW_WEEKS);
    startingDay = or(startingDay, STARTING_DAY);
    yearRange = or(yearRange, YEAR_RANGE);
    shortcutPropagation = or(shortcutPropagation, SHORTCUT_PROPAGATION);
    datepickerMode = or(datepickerMode, DATEPICKER_MODE);
    minMode = or(minMode, MIN_MODE);
    maxMode = or(maxMode, MAX_MODE);
    // todo: use date for unique value
    uniqueId = "datepicker--${(new Random().nextDouble() * 10000).floor}";
    if (initDate != null) {
      activeDate = initDate;
    } else {
      activeDate = new DateTime.now();
    }
    update.add(activeDate);
    refreshView();
  }

  setCompareHandler(Function handler, String type) {
    if (type == "day") {
      compareHandlerDay = handler;
    }
    if (type == "month") {
      compareHandlerMonth = handler;
    }
    if (type == "year") {
      compareHandlerYear = handler;
    }
  }

  num compare(DateTime date1, DateTime date2) {
    if (datepickerMode == "day" && truthy(compareHandlerDay)) {
      return compareHandlerDay(date1, date2);
    }
    if (datepickerMode == "month" && truthy(compareHandlerMonth)) {
      return compareHandlerMonth(date1, date2);
    }
    if (datepickerMode == "year" && truthy(compareHandlerMonth)) {
      return compareHandlerYear(date1, date2);
    }
    return null;
  }

  setRefreshViewHandler(Function handler, String type) {
    if (type == "day") {
      refreshViewHandlerDay = handler;
    }
    if (type == "month") {
      refreshViewHandlerMonth = handler;
    }
    if (type == "year") {
      refreshViewHandlerYear = handler;
    }
  }

  refreshView() {
    if (datepickerMode == "day" && truthy(refreshViewHandlerDay)) {
      refreshViewHandlerDay();
    }
    if (datepickerMode == "month" && truthy(refreshViewHandlerMonth)) {
      refreshViewHandlerMonth();
    }
    if (datepickerMode == "year" && truthy(refreshViewHandlerYear)) {
      refreshViewHandlerYear();
    }
  }

  String dateFilter(DateTime date, String format) {
    return new DateFormat(format).format(date);
  }

  bool isActive(dynamic dateObject) {
    if (identical(compare(dateObject['date'], activeDate), 0)) {
      activeDateId = dateObject['uid'];
      return true;
    }
    return false;
  }

  Map createDateObject(DateTime date, String format) {
    var dateObject = {

      'date': date,
      'label': dateFilter(date, format),
      'selected': identical(compare(date, activeDate), 0),
      'disabled': isDisabled(date),
      'current': identical(compare(date, new DateTime.now()), 0)
    };
    // todo: do it

    // dateObject['customClass'] = customClass({date: date, mode: datepickerMode}) || {};
    return dateObject;
  }

  /// returns `true`
  bool isDisabled(DateTime date) {
    // todo: implement dateDisabled attribute
    return ((truthy(minDate) && compare(date, minDate) < 0) ||
        (truthy(maxDate) && compare(date, maxDate) > 0));
  }

  /// splits the [arr] into a list of array of size [size]
  List split(List arr, num size) {
    var arrays = [];
    for (var i = 0; arr.length > i * size; i++) {
      arrays.add(arr.getRange(i * size, i * size + size).toList());
    }
    return arrays;
  }

  /// fired when user clicks one of the date buttons
  select(DateTime date) {
    if (datepickerMode == minMode) {
      if (falsey(activeDate)) {
        activeDate = new DateTime(0);
      }
      activeDate = new DateTime(date.year, date.month, date.day);
    } else {
      activeDate = date;
      datepickerMode =
      modes [ modes.indexOf(datepickerMode) - 1 ];
    }
    update.add(activeDate);
    refreshView();
  }

  move(num direction) {
    var expectedStep = datepickerMode == "day" ? stepDay
        : datepickerMode == "month" ? stepMonth
        : datepickerMode == "year" ? stepYear
        : null;

    if (expectedStep != null) {
      var year = activeDate.year +
          direction * (expectedStep['years'] ?? 0);
      var month = activeDate.month +
          direction * (expectedStep['months'] ?? 0);
      activeDate = new DateTime(year, month, 1);
      update.add(activeDate);
      refreshView();
    }
  }

  toggleMode([num direction]) {
    direction ??= 1;
    if ((datepickerMode == maxMode && direction == 1) ||
        (datepickerMode == minMode && direction == -1)) {
      return;
    }
    datepickerMode = modes[modes.indexOf(datepickerMode) + direction];
    refreshView();
  }
}