part of 'expanded_area_bloc.dart';

abstract class ExpandedAreaState {
  const ExpandedAreaState();
}

class ExpandedInitial extends ExpandedAreaState {
  final bool isExpanded;
  const ExpandedInitial({this.isExpanded = true});
}