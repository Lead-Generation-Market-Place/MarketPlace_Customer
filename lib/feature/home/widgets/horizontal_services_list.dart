import 'package:flutter/material.dart';
import 'package:us_connector/core/constants/file_urls.dart';

class HorizontalServicesList extends StatelessWidget {
  final List<Map<String, dynamic>> services;
  final Function(Map<String, dynamic>) onServiceTap;
  final double itemWidth;
  final double itemHeight;
  final double imageHeight;

  const HorizontalServicesList({
    super.key,
    required this.services,
    required this.onServiceTap,
    this.itemWidth = 140,
    this.itemHeight = 180,
    this.imageHeight = 110,
  });

  @override
  Widget build(BuildContext context) {
    if (services.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 48.0),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.search_off, size: 64, color: Colors.grey),
              const SizedBox(height: 12),
              Text(
                "No services found",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 6),
              Text(
                "Try refreshing or check back later",
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      height: itemHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: services.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final service = services[index];
          final imageUrl = service['service_image_url'] ?? '';
          
          return GestureDetector(
            onTap: () => onServiceTap(service),
            child: SizedBox(
              width: itemWidth,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: imageUrl.isNotEmpty
                        ? Image.network(
                            '${FileUrls.servicesLogos}$imageUrl',
                            height: imageHeight,
                            width: itemWidth,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: imageHeight,
                                width: itemWidth,
                                color: Colors.grey[300],
                                child: const Icon(
                                  Icons.broken_image,
                                  size: 40,
                                  color: Colors.grey,
                                ),
                              );
                            },
                          )
                        : Container(
                            height: imageHeight,
                            width: itemWidth,
                            color: Colors.grey[300],
                            child: const Icon(
                              Icons.image,
                              size: 40,
                              color: Colors.grey,
                            ),
                          ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    service['name'] ?? 'Unnamed Service',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
} 