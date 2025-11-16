import 'package:intl/intl.dart';
extension CustomDate on DateTime {

  String format({String format='dd-mm-yyyy'}) {
    try {
      DateTime d=this;
      if(d.isUtc){
        d=d.toLocal();
      }
      return DateFormat(format).format(d);
    } catch (e) {
      //
    }
   return '';
  }
  
}


