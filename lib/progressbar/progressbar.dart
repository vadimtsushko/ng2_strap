import 'package:angular2/angular2.dart';
import 'dart:html';

@Directive(selector: 'n2s-progress',
    host: const {'[attr.max]' : 'max'}
)
class Progress implements OnInit {
  Progress();

  @Input() bool animate = true;

  List bars = [];

  num _max = 100;

  num get max => _max;

  @Input() set max(num v) {
    _max = v;
    bars.forEach((Bar bar) {
      bar._recalculatePercentage();
    });
  }

  ngOnInit() {
    animate ??= true;
    max = max ??= 100;
  }

  addBar(Bar bar) {
    if (!animate) {
      bar.transition = 'none';
    }
    bars.add(bar);
  }

  removeBar(Bar bar) {
    bars.remove(bar);
  }
}

@Directive(selector: 'n2s-bar',
    host: const {
      'style':'min-width: 0;',
      'role':'progressbar',
      '[style.width]':'(percent < 100 ? percent : 100).toString() + "%"',
      '[style.transition]': 'transition',
      'aria-valuemin':'0',
      '[attr.aria-valuenow]':'value',
      '[attr.aria-valuetext]':'percent.toStringAsFixed(0) + "%"',
      '[attr.aria-valuemax]':'max'
    })
class Bar implements OnInit, OnDestroy {
  Bar(@Host() this.progress, this.elementRef);

  ElementRef elementRef;

  Progress progress;

  num percent = 0;

  String transition;

  num max;

  num _value;

  num get value => _value;

  @Input() set value(num v) {
    if (v == null || v == 0) {
      return;
    }
    _value = v;
    _recalculatePercentage();
  }

  @Input() set type(String type) {
    (elementRef.nativeElement as Element).classes.add(type);
  }

  ngOnInit() {
    progress.addBar(this);
  }

  ngOnDestroy() {
    progress.removeBar(this);
  }

  _recalculatePercentage() {
    percent = 100 * value / progress.max;
    var totalPercentage = progress.bars.fold(0, (total, bar) {
      return total + bar.percent;
    });
    if (totalPercentage > 100) {
      percent -= totalPercentage - 100;
    }
  }
}

@Component (selector: 'n2s-progressbar',
    templateUrl: 'progressbar.html',
    directives: const [Progress, Bar])
class Progressbar {

  @Input() bool animate;

  @Input() num max;

  @Input() var type;

  @Input() num value;
}

const List PROGRESSBAR_DIRECTIVES = const [Progress, Bar, Progressbar];