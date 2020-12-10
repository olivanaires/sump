import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sumpapp/helpers/page_manager_provider.dart';

class DrawerTile extends StatelessWidget {
  final IconData icon;
  final String text;
  final PageController controller;
  final int page;

  DrawerTile(this.icon, this.text, this.controller, this.page);

  @override
  Widget build(BuildContext context) {
    final int currentPage = context.watch<PageManager>().currentPage;

    final color = Theme.of(context).primaryColor;
    final menuColor = currentPage == page ? color : Colors.grey[700];
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          context.read<PageManager>().setPage(page);
        },
        child: Container(
          height: 60.0,
          child: Row(
            children: [
              Icon(
                icon,
                size: 32.0,
                color: menuColor,
              ),
              SizedBox(
                width: 32.0,
              ),
              Text(
                text,
                style: TextStyle(
                  fontSize: 16.0,
                  color: menuColor,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
