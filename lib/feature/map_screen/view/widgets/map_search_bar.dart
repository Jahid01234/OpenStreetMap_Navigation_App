import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:open_streetmap_app/feature/map_screen/controller/map_connection_controller.dart';


class MapSearchBar extends StatelessWidget {
  final MapConnectionController controller;

  const MapSearchBar({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Search Input ──────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
            child: Material(                          // ← fixes "No Material ancestor"
              elevation: 4,
              borderRadius: BorderRadius.circular(28),
              shadowColor: Colors.black.withOpacity(0.15),
              child: TextField(
                controller: controller.searchController,
                onChanged: controller.searchPlace,
                decoration: InputDecoration(
                  hintText: 'Search destination...',
                  hintStyle: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Color(0xFF5B8DEF),
                    size: 22,
                  ),
                  // ← fixes Obx improper use: use a plain ValueListenableBuilder
                  // instead of Obx for a TextEditingController
                  suffixIcon: ValueListenableBuilder<TextEditingValue>(
                    valueListenable: controller.searchController,
                    builder: (_, value, __) {
                      return value.text.isNotEmpty
                          ? GestureDetector(
                        onTap: controller.clearRoute,
                        child: const Icon(
                          Icons.close,
                          color: Colors.grey,
                          size: 20,
                        ),
                      )
                          : const SizedBox.shrink();
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(28),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 14,
                  ),
                ),
              ),
            ),
          ),

          // ── Search Results Dropdown ───────────────────────────────────────
          Obx(() {
            if (controller.searchResults.isEmpty) {
              return const SizedBox.shrink();
            }

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Material(                        // ← fixes overflow + Material
                elevation: 4,
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(16),
                ),
                shadowColor: Colors.black.withOpacity(0.1),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 300),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: controller.searchResults.length,
                    separatorBuilder: (_, __) =>
                    const Divider(height: 1, indent: 16),
                    itemBuilder: (_, i) {
                      final result = controller.searchResults[i];
                      return ListTile(
                        dense: true,
                        leading: const Icon(
                          Icons.location_on_outlined,
                          color: Color(0xFF5B8DEF),
                          size: 20,
                        ),
                        title: Text(
                          result.displayName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 13),
                        ),
                        onTap: () => controller.selectDestination(result),
                      );
                    },
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}