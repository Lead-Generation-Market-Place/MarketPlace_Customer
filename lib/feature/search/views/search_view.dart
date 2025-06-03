


import 'package:flutter/material.dart' hide SearchController;
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:us_connector/core/widgets/bottom_navbar.dart';
import 'package:us_connector/feature/search/controllers/search_controller.dart';

class SearchView extends GetView<SearchController> {
  const SearchView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavbar(),
      body: Center(child: Text('Search')),
    );
  }
}