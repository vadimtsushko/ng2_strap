import "package:angular2/angular2.dart";
import 'package:ng2_strap/modal/modal.dart';

@Component(selector: "modal-demo",
    templateUrl: "modal_demo.html",
    directives: const [N2sModal])
class ModalDemo {

  N2sModalAction modalAction;

  onModalClose(N2sModalAction _modalAction) {
    modalAction = _modalAction;
  }
}
