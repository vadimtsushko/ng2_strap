import "package:angular2/angular2.dart";
import 'package:ng2_strap/modal/modal.dart';

@Component(selector: "modal-demo",
    templateUrl: "modal_demo.html",
    directives: const [Modal])
class ModalDemo {

  ModalAction modalAction;

  onModalClose(ModalAction _modalAction) {
    modalAction = _modalAction;
  }
}
