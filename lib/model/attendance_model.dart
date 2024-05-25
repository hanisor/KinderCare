import 'package:flutter/material.dart';
import 'package:kindercare/model/child_model.dart';

class AttendanceModel extends ChangeNotifier {
  List<ChildModel> selectedChildren = [];
  DateTime? selectedDateTime;

  // Adds multiple children with a specified date-time
  void addChildWithDateTime(List<ChildModel> children, DateTime dateTime) {
    selectedChildren.addAll(children);
    selectedDateTime = dateTime;
    notifyListeners();
  }

  // Sets the entire list of selected children
  void setSelectedChildren(List<ChildModel> children) {
    selectedChildren = children;
    notifyListeners();
  }

  // Adds a single child to the selected list
  void addChild(ChildModel child) {
    selectedChildren.add(child);
    notifyListeners();
  }

  // Removes a single child from the selected list
  void removeChild(ChildModel child) {
    selectedChildren.remove(child);
    notifyListeners();
  }

  // Clears all selected children
  void clearChildren() {
    selectedChildren.clear();
    notifyListeners();
  }

  // Sets the selected date-time
  void setSelectedDateTime(DateTime dateTime) {
    selectedDateTime = dateTime;
    notifyListeners();
  }
}
