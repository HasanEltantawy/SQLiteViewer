// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

import 'package:sqliteviewer/src/core/helpers/db_helper.dart';
import 'package:sqliteviewer/src/core/utils/print.dart';
import 'package:sqliteviewer/src/core/widgets/loading.dart';

class DBTableContentViewer extends StatefulWidget {
  final String tableName;
  final List<String> columns;
  const DBTableContentViewer({
    Key? key,
    required this.tableName,
    required this.columns,
  }) : super(key: key);

  @override
  State<DBTableContentViewer> createState() => _DBTableContentViewerState();
}

class _DBTableContentViewerState extends State<DBTableContentViewer> {
  late final List<Map<String, dynamic>> result;

  bool isLoading = true;
  @override
  void initState() {
    initData();
    super.initState();
  }

  Future initData() async {
    result = await DatabaseHelper.instance
        .getTableContentForSelectedColumns(widget.tableName, widget.columns);
    appPrint(result);
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.tableName),
        centerTitle: true,
      ),
      body: isLoading
          ? const Loading()
          : ListView.separated(
              itemCount: result.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: const Icon(Icons.table_rows_outlined),
                  title: SelectableText(result[index]
                      .toString()
                      .replaceAll(",", ",\n")
                      .replaceAll("{", "{\n")
                      .replaceAll("}", "\n}")),
                );
              },
              separatorBuilder: (context, index) {
                return const Divider();
              },
            ),
    );
  }
}