import "package:angular2/angular2.dart";
import "datepicker-inner.dart";
import 'package:intl/intl.dart';

@Component (selector: "n2s-daypicker",
    templateUrl: 'day_picker.html')
class DayPicker implements OnInit {
  ///
  DayPicker(this.datePicker);

  DatePickerInner datePicker;

  ///
  List labels = [];

  ///
  String monthTitle;

  ///
  String yearTitle;

  ///
  List rows = [];

  ///
  List<num> weekNumbers = [];

  ///
  String maxMode = 'year';

  ///
  getDates(DateTime startDate, num n) {
    List<DateTime> dates = new List(n);
    var current = startDate;
    var i = 0;
    var date;
    while (i < n) {
      date = current;
      dates[i++] = date;
      current = current.add(const Duration(days: 1));
    }
    return dates;
  }

  ///
  num getISO8601WeekNumber(DateTime checkDate) {
    // ISO week date weeks start on monday
    // so correct the day number
    var dayNr = (checkDate.weekday + 6) % 7;

    // ISO 8601 states that week 1 is the week
    // with the first thursday of that year.
    // Set the target date to the thursday in the target week
    var thisMonday = checkDate.subtract(new Duration(days:(dayNr)));
    var thisThursday = thisMonday.add(new Duration(days:3));

    // Set the target to the first thursday of the year
    // First set the target to january first
    var firstThursday = new DateTime(checkDate.year, DateTime.JANUARY, 1);

    if(firstThursday.weekday != (DateTime.THURSDAY)) {
      firstThursday = new DateTime(checkDate.year, DateTime.JANUARY, 1 + ((4 - firstThursday.weekday) + 7) % 7);
    }

    // The weeknumber is the number of weeks between the
    // first thursday of the year and the thursday in the target week
    return (thisThursday.difference(firstThursday).inDays / 7).ceil();
  }

  ///
  ngOnInit() {
    datePicker.stepDay = { "months" : 1};
    datePicker.setRefreshViewHandler(() {
      var year = datePicker.activeDate.year;
      var month = datePicker.activeDate.month;
      var firstDayOfMonth = new DateTime (year, month, 1 - new DateTime (year, month, 1, 12).weekday, 12);
      var difference = datePicker.startingDay - firstDayOfMonth.day;
      var numDisplayedFromPreviousMonth = (difference > 0)
          ? 7 - difference
          : -difference;
      var firstDate = firstDayOfMonth;
      if (numDisplayedFromPreviousMonth > 0) {
        //todo luisvt: not sure what to do with next line
//        firstDate.setDate(-numDisplayedFromPreviousMonth + 1);
      }
      // 42 is the number of days on a six-week calendar
      List<DateTime> _days = getDates(firstDate, 42);
      List days = [];
      for (var i = 0; i < 42; i++) {
        var _dateObject = datePicker.createDateObject(_days[i], datePicker.formatDay);
        _dateObject['secondary'] = _days[i].month != month;
        _dateObject['uid'] = datePicker.uniqueId + "-" + i.toString();
        days.add(_dateObject);
      }
      labels = [];
      for (var j = 0; j < 7; j ++) {
        labels.add({
          'abbr': datePicker.dateFilter(days[j]['date'], datePicker.formatDayHeader),
          'full': datePicker.dateFilter(days[j]['date'], "EEEE")
        });
      }
      monthTitle = new DateFormat(datePicker.formatMonthTitle).format(datePicker.activeDate);
      yearTitle = new DateFormat(datePicker.formatYear).format(datePicker.activeDate);
      rows = datePicker.split(days, 7);
      if (datePicker.showWeeks) {
        weekNumbers = [];
        var thursdayIndex = (4 + 7 - datePicker.startingDay) % 7,
            numWeeks = rows.length;
        for (var curWeek = 0; curWeek < numWeeks; curWeek ++) {
          weekNumbers.add(getISO8601WeekNumber(rows[curWeek][thursdayIndex]['date']));
        }
      }
    }, "day");
    datePicker.setCompareHandler((date1, date2) {
      var d1 = new DateTime (
          date1.year, date1.month, date1.day);
      var d2 = new DateTime (
          date2.year, date2.month, date2.day);
      return d1.millisecondsSinceEpoch - d2.millisecondsSinceEpoch;
    }, "day");
    datePicker.refreshView();
  }
}