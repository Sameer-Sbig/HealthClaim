import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';

import 'package:secure_app/Encryption-Decryption/crypto-utils.dart';
import 'package:secure_app/customProvider.dart';

import 'package:secure_app/dioSingleton.dart';
import 'package:secure_app/Screens/inwardForm%201.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';

class InwardStatus2 extends StatefulWidget {
  const InwardStatus2({super.key});

  @override
  State<InwardStatus2> createState() => _InwardStatus2State();
}

class _InwardStatus2State extends State<InwardStatus2> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  int _currentIndex1 = 0;
  var widgetArray = [];
  List proposalData = [];
  Map status = {
    "Proposal Sourced": 0,
    "Discrepancy": 0,
    "Declined": 0,
    "Completed": 0,
    "totalCount": 6
  };
  String proposalID = '';
  String statusOfID = '';
  bool _isSearching = false;
  final _controller = SearchController();
  // List<Employee> employees = <Employee>[
  //   Employee(1172943, 'Test New', 26166, 'Private Car 4W', 1000, 'Proposal',
  //       '25/02/2024', 'Proposal Sourced'),
  //   Employee(1176479, 'Test Created', 26166, 'Car Insurance', 2000, 'Proposal',
  //       '14/02/2024', 'Declined'),
  //   Employee(1172333, 'Test ', 26166, 'Private Car 4W', 1000, 'Proposal',
  //       '12/02/2024', 'Proposal Sourced'),
  //   Employee(1172337, 'Test ', 26166, 'Private Car 4W', 1000, 'Proposal',
  //       '12/02/2024', 'Discrepency'),
  //   Employee(1172332, 'Test ', 26166, 'Private Car 4W', 1000, 'Proposal',
  //       '12/02/2024', 'Completed'),
  //   Employee(1172336, 'Test ', 26166, 'Private Car 4W', 1000, 'Proposal',
  //       '12/02/2024', 'Discrepency'),
  //   Employee(1172338, 'Test ', 26166, 'Private Car 4W', 1000, 'Proposal',
  //       '12/02/2024', 'Completed'),
  // ];
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Dio dio = DioSingleton.dio;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    getProposalDetails();
    setState(() {
      widgetArray = [];
    });
  }

  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  List _searchResult = [];

  void _search(String query) {
    _searchResult.clear();
    if (query.isEmpty) {
      setState(() {
        _isSearching = false;
      });
      return;
    }
    final String lowerCaseQuery = query.toLowerCase();
    _searchResult = proposalData.where((item) {
      return item['id'].toString().toLowerCase().contains(lowerCaseQuery) ||
          item['customer_name'].toLowerCase().contains(lowerCaseQuery);
    }).toList();
    setState(() {});
  }

  getProposalDetailsByStatus(String status) async {
    setState(() {
      isLoading = true;
    });
    SharedPreferences prefs = await _prefs;
    var token = prefs.getString('token') ?? '';
    final appState = Provider.of<AppState>(context, listen: false);
    Map<String, String> headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      "Accept": "application/json",
      "Authorization": appState.accessToken
    };
    Map<String, String> postData = {"status": status};
    String result = aesGcmEncryptJson(jsonEncode(postData));

    Map<String, dynamic> encryptedData = {'encryptedData': result};
    print(encryptedData);
    try {
      setState(() {
        isLoading = false;
      });
      final response = await dio.post(
          'https://uatcld.sbigeneral.in/SecureApp/proposalDetails/by-status',
          options: Options(headers: headers),
          data: encryptedData);
      String decryptedData = aesGcmDecryptJson(response.data);
      print(decryptedData);
      // var jsonMap = jsonDecode(decryptedData);
      // print(jsonMap);
      // var data = const JsonDecoder().convert(jsonMap);
      var data = jsonDecode(decryptedData);
      // final data = jsonDecode(response.data);
      setState(() {
        proposalData = data.reversed.toList();
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  getProposalDetails() async {
    setState(() {
      isLoading = true;
    });

    final appState = Provider.of<AppState>(context, listen: false);

    Map<String, String> headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      "Accept": "application/json",
      "Authorization": appState.accessToken
    };

    var postData = {"employee_code": appState.employee_code};

    if (appState.imdCode != null) {
      postData = {"imd_code": appState.imdCode};
    }
    print(postData);

    try {
      final response = await dio.post(
          'https://uatcld.sbigeneral.in/SecureApp/proposalDetails/secureMobileWeb',
          options: Options(headers: headers),
          data: {"encryptedData": aesGcmEncryptJson(jsonEncode(postData))});

      if (response.statusCode == 200) {
        String decryptedData = aesGcmDecryptJson(response.data);
        // var tdata = jsonDecode(decryptedData);
        var data = const JsonDecoder().convert(decryptedData);
        print(data);
        setState(() {
          status = data['counts'];
        });
        setState(() {
          proposalData = data['proposalDetails'].reversed.toList();
        });
        setState(() {
          isLoading = false;
        });
      }
    } catch (error) {
      print(error);
      setState(() {
        isLoading = false;
      });
    }
  }

  // getInwardDetails(proposalID) async {
  //   SharedPreferences prefs = await _prefs;
  //   var token = prefs.getString('token') ?? '';
  //   Map<String, String> postData = {"id": proposalID};
  //   print(postData);
  //   Map<String, String> headers = {
  //     'Content-Type': 'application/json; charset=UTF-8',
  //     "Accept": "application/json",
  //     "Authorization":
  //         "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiMSIsImVtYWlsIjoiYXJ5YUBzYmlnZW5lcmFsLmluIiwiaWF0IjoxNzE3NDgyMDQ0fQ.GF5_JFoyyl8q-tM5uHF5aCRl3G21TxIsOQxKSVmbcyY"
  //   };
  //   try {
  //     final response = await dio.post(
  //         'https://uatcld.sbigeneral.in/SecureApp/allProposalDetails',
  //         options: Options(headers: headers),
  //         data: postData);

  //     // if (response.statusCode == 201) {
  //     Navigator.push(context,
  //         MaterialPageRoute(builder: (context) => const InwardDetailsScreen()));
  //     // }
  //   } on DioException catch (error) {
  //     print(error.message);
  //   }
  // }

  // final List<Employees> employees = List.generate(
  //     100, // generate 100 employees for the example
  //     (index) => Employees(
  //           name: 'Employee $index',
  //           role: index % 2 == 0 ? 'Developer' : 'Designer',
  //           age: 20 + (index % 30),
  //         ));

  @override
  Widget build(BuildContext context) {
    final EmployeesDataSource dataSource =
        EmployeesDataSource(proposalData, context);
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: GradientText(
              'Inwarding Management System',
              colors: const [
                Color.fromRGBO(176, 34, 204, 1),
                Color.fromRGBO(13, 154, 189, 1),
              ],
              gradientType: GradientType.linear,
              gradientDirection: GradientDirection.ltr,
              style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic),
            ),
            centerTitle: false,
            flexibleSpace: Container(
              decoration: const BoxDecoration(color: Colors.white),
            ),
            shadowColor: Colors.grey,
            elevation: 7,
            actions: [
              Container(
                // width: 80,
                height: 60,
                padding: const EdgeInsets.fromLTRB(0, 10, 15, 10),
                child: Image.asset(
                  "assets/sbi_logo.PNG",
                  fit: BoxFit.cover,
                ),
              ),
            ],
            backgroundColor: Colors.white,

            // titleTextStyle: const TextStyle(
            //     color: Colors.purpleAccent,
            //     fontWeight: FontWeight.bold,
            //     fontStyle: FontStyle.italic),
          ),
          body: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(15),
              decoration: const BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                    Color.fromRGBO(176, 34, 204, 0.2),
                    Color.fromRGBO(13, 154, 189, 0.2),
                  ])),
              child: Column(
                children: [
                  // SizedBox(
                  //   height: MediaQuery.of(context).size.height * 0.03,
                  // ),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    child: Wrap(
                      // spacing: 15,
                      runSpacing: 15,
                      alignment: WrapAlignment.spaceBetween,
                      runAlignment: WrapAlignment.spaceBetween,
                      // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // SizedBox(
                        //   width: MediaQuery.of(context).size.width * 0.01,
                        // ),
                        Container(
                          width: 1050,
                          height: 40,
                          // margin: const EdgeInsets.only(left: 15),
                          child: SearchBar(
                              controller: _controller,
                              shape: MaterialStatePropertyAll(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      10), // Set border radius for rectangular shape
                                ),
                              ),
                              padding:
                                  const MaterialStatePropertyAll<EdgeInsets>(
                                      EdgeInsets.symmetric(horizontal: 15.0)),
                              hintText: 'Inward No/Customer Name',
                              hintStyle:
                                  const MaterialStatePropertyAll<TextStyle>(
                                      TextStyle(fontSize: 13)),
                              elevation: const MaterialStatePropertyAll(15),
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  const Color.fromARGB(255, 255, 255, 255)),
                              surfaceTintColor:
                                  MaterialStateProperty.all<Color>(
                                      const Color.fromARGB(255, 255, 255, 255)),
                              // onTap: () {
                              //   _controller.openView();
                              // },
                              onChanged: (query) {
                                // _controller.openView();
                                setState(() {
                                  _isSearching = true;
                                });

                                _search(query);
                              },
                              trailing: <Widget>[
                                IconButton(
                                    onPressed: () {},
                                    icon: ShaderMask(
                                      shaderCallback: _linearGradient,
                                      child: const Icon(
                                        Icons.search,
                                        size: 24,
                                      ),
                                    ))
                              ]),
                        ),
                        // SizedBox(
                        //   width: MediaQuery.of(context).size.width * 0.01,
                        // ),
                        Container(
                          width: 230,
                          height: 40,
                          // margin: const EdgeInsets.only(right: 15),
                          child: ElevatedButton(
                              style: ButtonStyle(
                                  elevation: const MaterialStatePropertyAll(15),
                                  backgroundColor: MaterialStateProperty.all<
                                          Color>(
                                      const Color.fromARGB(255, 255, 255, 255)),
                                  surfaceTintColor: MaterialStateProperty.all<
                                          Color>(
                                      const Color.fromARGB(255, 255, 255, 255)),
                                  shadowColor: MaterialStateProperty.all<Color>(
                                      Colors.black),
                                  shape: MaterialStatePropertyAll(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          10), // Set border radius for rectangular shape
                                    ),
                                  )),
                              onPressed: () {
                                Navigator.of(context)
                                    .push(_createRoute(const MyForm()));
                                // Navigator.push(
                                //   context,
                                //   MaterialPageRoute(builder: (context) => MyForm()),
                                // );
                              },
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ShaderMask(
                                    shaderCallback: _linearGradient,
                                    child: const Icon(
                                      Icons.library_add,
                                      size: 16,
                                    ),
                                  ),
                                  const Wrap(children: [
                                    Text('Add Inward',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color:
                                                Color.fromRGBO(176, 34, 204, 1),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12)),
                                  ])
                                ],
                              )),
                        )
                      ],
                    ),
                  ),
                  _height(),
                  _height(),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    // margin: const EdgeInsets.symmetric(horizontal: 10),
                    child: Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      runAlignment: WrapAlignment.spaceBetween,
                      // spacing: 15,
                      runSpacing: 15,
                      // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _statusContainer(
                            status['totalCount'].toString(),
                            'All Inwards',
                            const Color.fromRGBO(13, 154, 189, 1)),
                        _statusContainer(status['proposal_sourced'].toString(),
                            'proposal_sourced', Colors.grey),
                        _statusContainer(status['discrepancy'].toString(),
                            'discrepancy', Colors.orangeAccent),
                        _statusContainer(status['declined'].toString(),
                            'declined', Colors.red),
                        _statusContainer(status['completed'].toString(),
                            'completed', Colors.green),
                      ],
                    ),
                  ),
                  _height(),
                  Container(
                    // padding: const EdgeInsets.fromLTRB(15, 0, 15, 15),
                    height: 400,

                    decoration: const BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color:
                              //  Color.fromRGBO(231, 181, 229, 0.9),
                              Color.fromRGBO(16, 47, 184, 0.25),
                          blurRadius: 5.0, // soften the shadow
                          spreadRadius: 1.0, //extend the shadow
                          offset: Offset(
                            5.0, // Move to right 5  horizontally
                            5.0, // Move to bottom 5 Vertically
                          ),
                        ),
                      ],
                    ),
                    width: MediaQuery.of(context).size.width,
                    child: Theme(
                      data: ThemeData(
                          cardTheme: CardTheme(
                        surfaceTintColor: Colors.white,
                        color: Colors.white,
                        // shadowColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        // elevation: 15
                      )),
                      child: PaginatedDataTable(
                        rowsPerPage: 6, // Number of rows per page
                        onPageChanged: (startIndex) {
                          print("Showing data starting from index $startIndex");
                        },
                        dataRowHeight: 42,
                        // headingRowColor: MaterialStateProperty.all(
                        //   const Color.fromRGBO(176, 34, 204, 0.6),
                        // ),

                        columns: [
                          DataColumn(label: _gradientText('Inward No')),
                          DataColumn(label: _gradientText('Customer Name')),
                          DataColumn(label: _gradientText('Agreement Code')),
                          DataColumn(label: _gradientText('Product')),
                          DataColumn(label: _gradientText('Premium Amount')),
                          DataColumn(label: _gradientText('Inward Type')),
                          DataColumn(label: _gradientText('Status')),
                        ],
                        source: dataSource,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        isLoading
            ? Positioned(
                top: 0,
                right: 0,
                left: 0,
                bottom: 0,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  decoration:
                      BoxDecoration(color: Colors.white.withOpacity(0.5)),
                  child: Center(
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                        const Text('Loading Data...',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Color.fromRGBO(15, 5, 158, 1),
                            )),
                        const SizedBox(
                          height: 10,
                        ),
                        LoadingAnimationWidget.threeArchedCircle(
                          color: const Color.fromRGBO(15, 5, 158, 1),
                          size: 50,
                        ),
                      ])),
                ),
              )
            : Container()
      ],
    );
  }

  _text(text) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.122,
      height: MediaQuery.of(context).size.height * 0.07,
      padding: const EdgeInsets.all(5),
      decoration:
          BoxDecoration(border: Border.all(color: Colors.black, width: 0.5)),
      child: Center(
        child: Text(
          text,
          softWrap: false,
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
          maxLines: 3,
          style: const TextStyle(
              fontSize: 13,
              // letterSpacing: 0.8,
              // fontWeight: FontWeight.bold,
              color: Colors.black),
        ),
      ),
    );
  }

  _text2(text) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.122,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
          color: const Color.fromRGBO(13, 154, 189, 0.08),
          // border: Border(right: BorderSide(color: Colors.black, width: 1))
          border: Border.all(color: Colors.black, width: 0.5)),
      child: Text(
        text,
        softWrap: false,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: const TextStyle(
            fontSize: 14,
            // letterSpacing: 0.8,
            fontWeight: FontWeight.bold,
            color: Colors.black),
      ),
    );
  }

  _width() {
    return const SizedBox(
      width: 2,
    );
  }

  _height() {
    return const SizedBox(
      height: 15,
    );
  }

  _statusContainer(
    String number,
    String status,
    Color color,
  ) {
    return Container(
        width: 200,
        height: 50,
        // margin: const EdgeInsets.symmetric(horizontal: 15),
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: color,
          boxShadow: const [
            BoxShadow(
              color:
                  //  Color.fromRGBO(231, 181, 229, 0.9),
                  Colors.black26,
              blurRadius: 5.0, // soften the shadow
              spreadRadius: 2.0, //extend the shadow
              offset: Offset(
                3.0, // Move to right 5  horizontally
                3.0, // Move to bottom 5 Vertically
              ),
            ),
          ],
        ),
        child: TextButton(
          onPressed: () {
            if (status == 'All Inwards') {
              getProposalDetails();
            } else {
              getProposalDetailsByStatus(status);
            }

            setState(() {
              _isSearching = false;
            });
            _search('');
          },
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  number,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
                Text(
                  status,
                  maxLines: 2,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold),
                )
              ],
            ),
          ),
        ));
  }

  Shader _linearGradient(Rect bounds) {
    return const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.purpleAccent,
          Colors.blueAccent,
          // Color.fromRGBO(176, 34, 204, 0.7),
          // Color.fromRGBO(176, 34, 204, 0.7),
          // Color.fromRGBO(176, 34, 204, 0.7),
          // Color.fromRGBO(13, 154, 189, 0.7),
          // Color.fromRGBO(13, 154, 189, 0.7),
          // Color.fromRGBO(13, 154, 189, 0.7),
        ]).createShader(bounds);
  }

  _gradientText(text) {
    return GradientText(
      text,
      colors: const [
        Color.fromRGBO(143, 19, 168, 1),
        Color.fromRGBO(16, 62, 163, 1),
      ],
      gradientType: GradientType.linear,
      gradientDirection: GradientDirection.ltr,
      style: const TextStyle(
        letterSpacing: 1,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

Route _createRoute(screenName) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => screenName,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      var begin = const Offset(1.0, 0.0);

      var end = Offset.zero;

      var curve = Curves.ease;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

      var offsetAnimation = animation.drive(tween);

      return SlideTransition(
        position: offsetAnimation,
        child: child,
      );
    },
  );
}

class Employees {
  final String name;
  final String role;
  final int age;

  Employees({required this.name, required this.role, required this.age});
}

// 2. Define a custom DataTableSource subclass to manage the data
class EmployeesDataSource extends DataTableSource {
  final List proposalData;
  final BuildContext context;
  int _selectedCount = 0;

  EmployeesDataSource(this.proposalData, this.context);

  @override
  int get rowCount => proposalData.length;

  @override
  bool get hasMoreRows => false;

  @override
  int get selectedRowCount => _selectedCount;

  @override
  DataRow getRow(int index) {
    assert(index >= 0);
    if (index >= proposalData.length) {
      return null!;
    }
    final data = proposalData[index];
    return DataRow.byIndex(
      // color: MaterialStateProperty.all(Colors.grey[300]),
      index: index,
      selected: false,
      cells: [
        DataCell(TextButton(
          child: Text(data['id'].toString()),
          onPressed: () {
            Navigator.of(context).push(_createRoute(MyForm(
              proposalId: proposalData[index]['id'].toString(),
              isView: proposalData[index]['status'] != 'discrepancy',
              isEdit: proposalData[index]['status'] == 'discrepancy',
            )));
          },
        )),
        DataCell(SizedBox(width: 100, child: Text(data['customer_name']))),
        DataCell(Text(data['agreement_code'])),
        DataCell(SizedBox(
          width: 100,
          child: Text(
            data['product'],
            maxLines: 2,
          ),
        )),
        DataCell(Text(data['premium_amount'].toString())),
        DataCell(Text(data['inward_type'])),
        DataCell(
          Container(
            padding: const EdgeInsets.all(5),
            width: 90,
            height: 35,
            decoration: BoxDecoration(
                color: (proposalData[index]['status'] == 'declined')
                    ? Colors.red
                    : proposalData[index]['status'] == 'completed'
                        ? Colors.green
                        : proposalData[index]['status'] == 'discrepancy'
                            ? Colors.orangeAccent
                            : Colors.grey,
                borderRadius: BorderRadius.circular(5)),
            child: Center(
              child: Text(
                ' ${data['status']} ',
                softWrap: false,
                maxLines: 3,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontSize: 12,
                    // fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ),
          ),
        )
      ],
    );
  }

  @override
  // TODO: implement isRowCountApproximate
  bool get isRowCountApproximate => false;
}
