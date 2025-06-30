import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:us_connector/core/constants/screen_size.dart';
import 'package:us_connector/core/widgets/shimmer_list_tile_widget.dart';
import 'package:us_connector/core/widgets/star_rating_widget.dart';
import 'package:us_connector/feature/professional/controllers/professional_controller.dart';
import 'package:us_connector/feature/professional/widgets/search_view_widget.dart';

class ProfessionalView extends GetView<ProfessionalController> {
  const ProfessionalView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            floating: true,
            snap: true,
            expandedHeight: ScreenSize().getHeight(context) / 6,
            flexibleSpace: FlexibleSpaceBar(
              background: Padding(
                padding: const EdgeInsets.only(
                  top: 40,
                  left: 16,
                  right: 16,
                  bottom: 8,
                ),
                child: Obx(
                  () => SearchViewWidget(
                    searchText: controller.serviceData['name'] ?? '',
                    zipText: '1029',
                  ),
                ),
              ),
            ),
            title: controller.serviceData.isNotEmpty
                ? Text(controller.serviceData['name'])
                : const Text(''),
            centerTitle: true,
          ),
          SliverToBoxAdapter(child: _buildBody(controller, context)),
        ],
      ),
    );
  }
}

Widget _buildBody(ProfessionalController controller, BuildContext context) {
  return SafeArea(
    child: Obx(() {
      if (controller.loadingPhase.value == 1) {
        return ShimmerListTileWidget();
        // return _buildLoadingMessage('Loading Service...');
      } else if (controller.loadingPhase.value == 2) {
        return ShimmerListTileWidget();
        // return _buildLoadingMessage('Loading Professionals...');
      } else if (controller.loadingPhase.value == 3) {
        return ShimmerListTileWidget();
        //_buildLoadingMessage('Loading Professionals By Area...');
      } else if (controller.loadingPhase.value == 4) {
        return _buildProfessionalList(context, controller);
      } else {
        return _buildLoadingMessage('Loaded');
      }
    }),
  );
}

Widget _buildLoadingMessage(String message) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          message,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 24),
        const CircularProgressIndicator(),
      ],
    ),
  );
}

Widget _buildProfessionalList(
  BuildContext context,
  ProfessionalController controller,
) {
  return SizedBox(
    height: ScreenSize().getHeight(context),
    width: ScreenSize().getWidth(context),
    child: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          "Professionals for this service:",
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.deepPurple,
          ),
        ),
        const SizedBox(height: 8),
        if (controller.professionals.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: Text(
                'No professionals found',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ),
          )
        else
          ...controller.professionals.map(
            (pro) => Card(
              elevation: 1.5,
              margin: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),

              child: ListTile(
                leading: ClipOval(
                  // backgroundColor: Colors.deepPurple.shade100,
                  child: CachedNetworkImage(
                    fit: BoxFit.cover,
                    width: ScreenSize().getWidth(context) / 7,
                    imageUrl: '${pro['image_url']}',
                    progressIndicatorBuilder: (context, url, progress) {
                      return CircularProgressIndicator(
                        value: progress.progress,
                        color: Colors.deepPurple,
                      );
                    },
                    errorWidget: (context, url, error) {
                      print(error.toString());
                      return Icon(Icons.person);
                    },
                  ),
                ),
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pro['business_name'] ?? 'No Name',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    StarRatingWidget(
                      onRatingChanged: (p0) => print(p0),
                      initialRating: 2,
                    ),
                  ],
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.circle,
                          color: pro['is_online_now'] == "true"
                              ? Colors.green
                              : Colors.grey,
                        ),
                        Text('Online Now'),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(Icons.workspace_premium_outlined),
                        Text('${pro['total_hires']} Hires on Yalpax'),
                      ],
                    ),
                    Text(
                      pro['introduction'] ?? "",
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.normal,
                        color: Colors.grey[800],
                      ),
                    ),
                  ],
                ),
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.deepPurple,
                ),
                onTap: () {
                  print(pro);
                },
              ),
            ),
          ),
        const SizedBox(height: 32),
        Text(
          "Professionals By Area:",
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.deepPurple,
          ),
        ),
        const SizedBox(height: 8),
        if (controller.professionalsByArea.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: Text(
                'No professionals found in this area',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ),
          )
        else
          ...controller.professionalsByArea.map(
            (pro) => Card(
              elevation: 1.5,
              margin: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.deepPurple.shade100,
                  child: Icon(
                    Icons.person_pin_circle,
                    color: Colors.deepPurple,
                  ),
                ),
                title: Text(
                  pro['users_profiles']?['name'] ?? 'No Name',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'User ID: ${pro['user_id']}',
                      style: TextStyle(fontSize: 12),
                    ),
                    if (pro['users_profiles']?['email'] != null)
                      Text(
                        pro['users_profiles']?['email'],
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                        ),
                      ),
                  ],
                ),
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.deepPurple,
                ),
                onTap: () {
                  // TODO: Navigate to professional details
                },
              ),
            ),
          ),
      ],
    ),
  );
}
