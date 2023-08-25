import 'package:flutter/material.dart';

class DrawerItem {
  final Icon icon;
  final String title;
  final Function onTap;

  DrawerItem({required this.icon, required this.title, required this.onTap});
}
// void _fetchServiceProviderTypes() async {
  //   try {
  //     final http.Response response = await http.post(
  //       Uri.parse(ApiConstants.graphqlUrl),
  //       headers: {
  //         'Content-Type': ApiConstants.contentType,
  //         'Hasura-Client-Name': ApiConstants.hasuraConsoleClientName,
  //         'x-hasura-admin-secret': ApiConstants.adminSecret,
  //       },
  //       body: jsonEncode({
  //         'query': getServiceProviderTypesQuery,
  //       }),
  //     );
  //
  //     if (response.statusCode == 200) {
  //       final data = jsonDecode(response.body);
  //       setState(() {
  //         serviceProviderTypes = data['data']['service_provider_type'];
  //       });
  //     } else {
  //       print('API Error: ${response.reasonPhrase}');
  //     }
  //   } catch (error) {
  //     print('Error fetching service provider types: $error');
  //   }
  // }
class AppDrawer extends StatelessWidget {
  final List<DrawerItem> drawerItems;
  const AppDrawer({super.key, required this.drawerItems});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: const Color(0xff006bbf),
        child: ListView(
          children: [
            const DrawerHeader(
              child: Center(
                child: Text(
                  'LOGO',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            ...drawerItems.map((item) {
              return ListTile(
                leading: item.icon,
                title: Text(
                  item.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),
                onTap: () => item.onTap(),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}


