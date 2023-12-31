// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:sqliteviewer/src/core/helpers/db_helper.dart';
import 'package:sqliteviewer/src/core/utils/print.dart';
import 'package:sqliteviewer/src/core/widgets/loading.dart';
import 'package:sqliteviewer/src/features/db_table_viewer/presentation/screens/db_table_content_viewer.dart';

class DBTableColumnsSelectViewer extends StatefulWidget {
  final String tableName;
  const DBTableColumnsSelectViewer({
    Key? key,
    required this.tableName,
  }) : super(key: key);

  static const String routeName = "/db_table_select_columns";

  static Route route(String tableName) {
    return MaterialPageRoute(
      settings: const RouteSettings(name: routeName),
      builder: (_) => DBTableColumnsSelectViewer(tableName: tableName),
    );
  }

  @override
  State<DBTableColumnsSelectViewer> createState() =>
      _DBTableColumnsSelectViewerState();
}

class _DBTableColumnsSelectViewerState
    extends State<DBTableColumnsSelectViewer> {
  late final List<Map<String, dynamic>> result;
  late final List<String> allColumns;
  final List<String> selectedColumns = []; // List to store selected columns

  bool isLoading = true;
  @override
  void initState() {
    initData();
    super.initState();
  }

  Future initData() async {
    result = await DatabaseHelper.instance.getColumnNames(widget.tableName);
    appPrint(result);
    allColumns = result.map((column) => column['name'] as String).toList();
    selectedColumns.addAll(allColumns);

    setState(() {
      isLoading = false;
    });
  }

  void sortAsInDatabase() {
    /// Sort columns as in database table
    selectedColumns.sort(
      (a, b) {
        final aMap = result.firstWhere((element) => element["name"] == a);
        final bMap = result.firstWhere((element) => element["name"] == b);

        final aId = (aMap["cid"] as int);
        final bId = (bMap["cid"] as int);
        return aId.compareTo(bId);
      },
    );
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
                final column = result[index];
                final columnName = column["name"];
                final bool isPK = column["pk"] == 1;
                return CheckboxListTile(
                  title: Text(columnName),
                  value: selectedColumns.contains(columnName),
                  subtitle: Wrap(
                    spacing: 20,
                    children: [
                      Text(
                        column["type"].toString(),
                        style: const TextStyle(
                          color: Colors.purpleAccent,
                        ),
                      ),
                      Text(
                        column["notnull"] == 0 ? "NULLABLE" : "NOT NULL",
                        style: const TextStyle(
                          color: Colors.purpleAccent,
                        ),
                      ),
                      Text(
                        "Default Value: ${column["dft_value"]}",
                        style: const TextStyle(
                          color: Colors.purpleAccent,
                        ),
                      ),
                      if (isPK) Icon(isPK ? Icons.key : Icons.boy),
                    ],
                  ),
                  onChanged: (bool? value) {
                    setState(() {
                      if (value == true) {
                        selectedColumns.add(columnName);
                      } else {
                        selectedColumns.remove(columnName);
                      }
                    });
                  },
                );
              },
              separatorBuilder: (context, index) {
                return const Divider();
              },
            ),
      bottomNavigationBar: BottomAppBar(
        child: ListTile(
          title: const Text("Show", textAlign: TextAlign.center),
          onTap: () {
            sortAsInDatabase();
            Navigator.push(
              context,
              DBTableContentViewer.route(
                tableName: widget.tableName,
                columns: selectedColumns,
              ),
            );
          },
        ),
      ),
    );
  }
}
