import 'package:flutter/material.dart';
import 'package:us_connector/core/widgets/custom_input.dart';

class SearchViewWidget extends StatelessWidget {
  final String searchText;
  final String zipText;
  final ValueChanged<String>? onSearchChanged;
  final ValueChanged<String>? onZipChanged;

  const SearchViewWidget({
    super.key,
    required this.searchText,
    required this.zipText,
    this.onSearchChanged,
    this.onZipChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 52,
          child: CustomInput(
            label: searchText.isEmpty ? "Search for a service" : searchText,
            prefixIcon: const Icon(Icons.search),
            onChanged: onSearchChanged ?? (value) {},
          ),
        ),
        const SizedBox(height: 2),
        SizedBox(
          height: 52,
          child: CustomInput(
            label: zipText.isEmpty ? "Zip code" : zipText,
            prefixIcon: const Icon(Icons.location_on),
            onChanged: onZipChanged ?? (value) {},
          ),
        ),
      ],
    );
  }
}
