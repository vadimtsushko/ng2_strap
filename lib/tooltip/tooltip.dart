import 'package:angular2/angular2.dart';
import 'package:ng2_strap/position.dart';
import 'dart:async';
import 'dart:html';

class TooltipOptions {
  String placement;

  String popupClass;

  bool animation;

  bool isOpen;

  var content;

  TooltipOptions({
    this.placement,
    this.popupClass,
    this.animation,
    this.isOpen,
    this.content
  });
}

@Component (selector: 'n2s-tooltip-container',
    templateUrl: 'tooltip_container.html',
    encapsulation: ViewEncapsulation.None)
class TooltipContainer {
  ElementRef element;

  Map<String, dynamic> classMap;

  dynamic positionMap;

  String top;

  String left;

  String display;

  String content;

  String placement = 'top';

  bool appendToBody = false;

  bool isOpen;

  String popupClass;

  bool animation;

  TooltipContainer(this.element, TooltipOptions options) {
    classMap = { 'in' : false};
    placement = options.placement;
    popupClass = options.popupClass;
    animation = options.animation;
    isOpen = options.isOpen;
    content = options.content;
    classMap[placement] = true;
  }

  position(ElementRef hostEl) {
    display = 'block';
    top = '0px';
    left = '0px';
    var p = positionElements(
        hostEl.nativeElement,
        element.nativeElement.children[0],
        placement,
        appendToBody);
    top = p.top.toString() + 'px';
    left = p.left.toString() + 'px';
    classMap['in'] = true;
  }
}

@Directive(selector: '[n2sTooltip]')
class Tooltip {
  Tooltip(this.element, this.loader);

  ElementRef element;

  DynamicComponentLoader loader;

  bool visible = false;

  @Input('n2sTooltip') String content;

  @Input('n2sTooltipPlacement') String placement = 'top';

  // todo:
  @Input('n2sTooltipAppendToBody') bool appendToBody;

  @Input('n2sTooltipIsOpen') bool isOpen;

  bool _enable = true;

  @Input('n2sTooltipEnable') set enable(bool enable) {
    _enable = enable ?? true;
    if(!_enable) {
      hide();
    }
  }

  @Input('n2sTooltipTrigger') String trigger;

  @Input('n2sTooltipClass') String popupClass;

  Future<ComponentRef> tooltip;

  // todo: filter triggers
  @HostListener('mouseenter', const ['\$event'])
  @HostListener('focusin', const ['\$event'])
  show([Event event]) {
    if(event is MouseEvent && trigger == 'focus'
      ||event is FocusEvent && trigger == 'mouse') {
      return;
    }
    if (visible || !_enable) {
      return;
    }
    visible = true;
    var options = new TooltipOptions(content: content, placement: placement, popupClass: popupClass);
    var binding = Injector.resolve([bind(TooltipOptions).toValue(options)]);
    tooltip = loader.loadNextToLocation(TooltipContainer, element, binding)
        .then((ComponentRef componentRef) {
      return new Future.delayed(const Duration(milliseconds: 1), () {
        (componentRef.instance as TooltipContainer).position(element);
        return componentRef;
      });
    });
  }

  @HostListener('mouseleave', const ['\$event'])
  @HostListener('focusout', const ['\$event'])
  hide([Event event]) {
    if(event is MouseEvent && trigger == 'focus'
        ||event is FocusEvent && trigger == 'mouse') {
      return;
    }
    if (!visible) {
      return;
    }
    visible = false;
    tooltip.then((ComponentRef componentRef) {
      componentRef.dispose();
      return componentRef;
    });
  }
}

const TOOLTIP_DIRECTIVES = const [Tooltip, TooltipContainer];