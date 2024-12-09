import 'dart:async';
import 'dart:convert';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_file_dialog/flutter_file_dialog.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
// import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
// import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:secure_app/Widgets/PdfViewer.dart';
import 'package:secure_app/customProvider.dart';
// import 'package:provider/provider.dart';
// import 'package:secure_app/customProvider.dart';

import 'package:secure_app/dioSingleton.dart';
import 'package:secure_app/Screens/inwardScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:shared_preferences/shared_preferences.dart';

class ProposalDocuments extends StatefulWidget {
  final Map inwardData;
  final inwardType;
  final Map? ckycData;
  final FormData? ckycDocuments;
  final isEdit;
  final isView;

  ProposalDocuments(
      {super.key,
      required this.inwardData,
      required this.inwardType,
      required this.ckycData,
      required this.ckycDocuments,
      this.isEdit = false,
      this.isView = false});

  @override
  State<ProposalDocuments> createState() => _ProposalDocumentsState();
}

class _ProposalDocumentsState extends State<ProposalDocuments> {
  File? galleryFile;
  Map<String, List> documents = {
    'proposalDocuments': [],
    'otherDocuments': ['', '']
  };
  Map<String, List> edittedDocuments = {
    'proposalDocuments': [],
    'otherDocuments': ['', '']
  };

  Map<String, List> oldFileNames = {
    'proposalDocuments': [],
    'otherDocuments': [null, null]
  };
  int inwardId = 0;
  Dio dio = DioSingleton.dio;
  final picker = ImagePicker();
  bool isSubmitted = false;
  bool isLoading = false;
  // String token = '';
  int proposal_doc_count = 4;
  String status = '';

  // late AnimationController _animationController;
  // late Animation<double> _animation;
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  void initState() {
    super.initState();
    print(widget.inwardData);

    getDocumentCountProposal();
    final appState = Provider.of<AppState>(context, listen: false);
    setState(() {
      inwardId = appState.proposalId;
    });
    // _animationController =
    //     AnimationController(vsync: this, duration: const Duration(seconds: 2));
    // _animationController.forward();
    // _animation = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
    //     parent: _animationController, curve: Curves.easeInOutCirc));
  }

  createBlobUrl(Uint8List fileData, String mimetype) {
    var blob = html.Blob([fileData], mimetype);
    final blobUrl = html.Url.createObjectUrlFromBlob(blob);
    return blobUrl;
  }

  fetchFilePath(String filename) async {
    final dir = await getApplicationDocumentsDirectory();
    final filePath = '${dir.path}/$filename';
    SharedPreferences prefs = await _prefs;
    var token = prefs.getString('token') ?? '';
    final appState = Provider.of<AppState>(context, listen: false);
    Map<String, String> headers = {"Authorization": appState.accessToken};

    var proposalId = appState.proposalId;
    final response = await dio.download(
        'https://uatcld.sbigeneral.in/SecureApp/proposalDocument/$proposalId/$filename',
        options: Options(headers: headers),
        filePath);
    if (response.statusCode == 200) {
      return filePath;
    } else {
      return null;
    }
  }

  Future<String> getDocuments(nofetch) async {
    print('2222');
    print(widget.isEdit);
    print('no');
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
    try {
      final appState = Provider.of<AppState>(context, listen: false);
      var proposalId = appState.proposalId;
      print(proposalId);
      final response = await dio.post(
          'https://uatcld.sbigeneral.in/SecureApp/proposalDocuments',
          data: {"proposal_id": proposalId},
          options: Options(headers: headers));
      var data = List.from(jsonDecode(response.data));
      print(data);

      var proposalList =
          data.where((dat) => dat['doc_type'] == 'proposal').toList();
      var otherList = data.where((dat) => dat['doc_type'] == 'other').toList();
      print(proposalList);
      print(otherList);
      for (var i = 0; i < proposalList.length; i++) {
        var filePage = int.parse(
                proposalList[i]['file_name'].split('.')[0].split('-')[1]) -
            1;
        if (nofetch == false) {
          documents['proposalDocuments']![filePage] =
              File(await fetchFilePath(proposalList[i]['file_name']));
        }

        if (widget.isEdit) {
          oldFileNames['proposalDocuments']![filePage] = {
            'file_name': proposalList[i]['file_name'],
            'version': proposalList[i]['version']
          };
        }
      }
      for (var i = 0; i < otherList.length; i++) {
        var filePage =
            int.parse(otherList[i]['file_name'].split('.')[0].split('-')[1]) -
                1;
        if (nofetch == false) {
          documents['otherDocuments']![filePage] =
              File(await fetchFilePath(otherList[i]['file_name']));
        }
        if (widget.isEdit) {
          oldFileNames['otherDocuments']![filePage] = {
            'file_name': otherList[i]['file_name'],
            'version': otherList[i]['version']
          };
        }
      }
      setState(() {
        // proposalList.map((d) async {
        //   print(d['file_name'].split('.')[0].split('-')[1]);
        //   documents['proposalDocuments']![
        //           int.parse(d['file_name'].split('.')[0].split('-')[1])] =
        //       await fetchFilePath(d['file_name']);
        // });
        // otherList.map((d) async {
        //   documents['otherDocuments']![d['file_name']
        //       .split('.')[0]
        //       .split('-')[1]] = await fetchFilePath(d['file_name']);
        // });
        isLoading = false;
      });
      print(documents);
      // var proposalList = data.where((dat) => dat['doctype'] == 'proposal');
      // var otherList = data.where((dat) => dat['doctype'] == 'other');

      // proposalList.map((d){
      //   documents['proposalDocuments']![d['file_name'].split('.')[0].split('-')[1]] = File(d['file_name']);
      // });
      // otherList.map((d){
      //   documents['otherDocuments']![d['file_name'].split('.')[0].split('-')[1]] = File(d['file_name']);
      // });
      return "Documents Fetched";
    } catch (err) {
      print(err);
      setState(() {
        isLoading = false;
      });
      return "";
      // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      //     content: const Text("Technical Error!"),
      //     action: SnackBarAction(
      //       label: ' Cancel',
      //       onPressed: () {},
      //     )));
    }
  }

  getDocumentCountProposal() async {
    print('1');
    print(widget.inwardData["product"]);
    setState(() {
      isLoading = true;
    });
    if (widget.inwardType == "Replenishment") {
      for (int i = 0; i < 6; i++) {
        documents['otherDocuments']!.add('');
      }
    }

    SharedPreferences prefs = await _prefs;
    var token = prefs.getString('token') ?? '';
    final appState = Provider.of<AppState>(context, listen: false);
    Map<String, String> headers = {"Authorization": appState.accessToken};

    try {
      final response = await dio.post(
          'https://uatcld.sbigeneral.in/SecureApp/inwardProducts/productDetails',
          data: {"productName": widget.inwardData["product"]},
          options: Options(headers: headers));
      var data = jsonDecode(response.data);
      print(data);
      if (data['proposal_doc_count'] == null) {
        documents['proposalDocuments']!.add('');
        documents['proposalDocuments']!.add('');
        if (widget.isEdit) {
          edittedDocuments['proposalDocuments']!.add('');
          edittedDocuments['proposalDocuments']!.add('');
          oldFileNames['proposalDocuments']!.add(null);
          oldFileNames['proposalDocuments']!.add(null);
        }
      } else {
        for (int i = 0; i < data['proposal_doc_count']; i++) {
          if (widget.isEdit) {
            edittedDocuments['proposalDocuments']!.add('');
            oldFileNames['proposalDocuments']!.add(null);
          }
          documents['proposalDocuments']!.add('');
        }
      }
      setState(() {
        proposal_doc_count = data['proposal_doc_count'] ?? 2;
        isLoading = false;
      });
      print(widget.isEdit);
      if (widget.isView || widget.isEdit) {
        await getDocuments(false);
      }
    } catch (err) {
      print(err);
      setState(() {
        isLoading = false;
      });
    }
  }

  // Future<String> uploadCkycDocuments(proposalId) async {
  //   if (widget.ckycDocuments == null) {
  //     return 'Documents Submitted';
  //   }
  //   SharedPreferences prefs = await _prefs;
  //   var token = prefs.getString('token') ?? '';
  //   Map<String, String> headers = {"Authorization": appState.accessToken};

  //   widget.ckycDocuments!.fields.add(MapEntry('proposal_id', proposalId));
  //   widget.ckycDocuments!.fields.add(const MapEntry('doc_type', 'ckyc'));
  //   print(widget.ckycDocuments);
  //   print("ckycDocuments");
  //   try {
  //     String route = 'proposalDocument';
  //     if (widget.isEdit) {
  //       route = 'updateProposalDocument';
  //     }
  //     final response = await dio.post(
  //         'https://uatcld.sbigeneral.in/SecureApp/${route}',
  //         data: widget.ckycDocuments,
  //         options: Options(headers: headers));

  //     print('form submitted');
  //     print(response);

  //     return 'CKYC Documents Submitted';
  //   } on DioException catch (error) {
  //     print(error.message);
  //     return "Documents not submitted. Try again!";
  //     // // ignore: use_build_context_synchronously
  //     // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
  //     //     content: const Text("CKYC Documents not submitted. Try again!"),
  //     //     action: SnackBarAction(
  //     //       label: ' Cancel',
  //     //       onPressed: () {},
  //     //     )));
  //   }
  // }

  Future<String> uploadProposalDocuments(
      proposalId, fileArray, String docType) async {
    if (docType == 'other') {
      if (documents['otherDocuments']!.every((element) => element == '')) {
        return "No Other Documents found";
      }
    }
    print('file names');
    print(fileArray);
    print('see above');
    SharedPreferences prefs = await _prefs;
    var token = prefs.getString('token') ?? '';
    final appState = Provider.of<AppState>(context, listen: false);
    Map<String, String> headers = {"Authorization": appState.accessToken};
    var formData = FormData();
    formData.fields.add(MapEntry('proposal_id', proposalId));
    formData.fields.add(MapEntry('doc_type', docType));

    for (var i = 0; i < fileArray.length; i++) {
      if (fileArray[i] != '') {
        var fileExtension = fileArray[i].path.split('.').last;
        formData.files.add(MapEntry(
            'files',
            await MultipartFile.fromFile(fileArray[i].path,
                filename: '${docType}page-${i + 1}.$fileExtension')));
      }
    }
    try {
      String route = 'proposalDocument';
      if (widget.isEdit) {
        route = 'updateProposalDocument';
      }
      print(route);
      final response = await dio.post(
          'https://uatcld.sbigeneral.in/SecureApp/$route',
          data: formData,
          options: Options(headers: headers));

      print('form submitted');
      print(response);
      return 'Proposal Documents Submitted';
    } on DioException catch (error) {
      print(error.message);
      return "Documents not submitted. Try again!";
      // // ignore: use_build_context_synchronously
      // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      //     content: const Text("Proposal Documents not submitted. Try again!"),
      //     action: SnackBarAction(
      //       label: ' Cancel',
      //       onPressed: () {},
      //     )));
    }
  }

  editProposal() async {
    print('hereeeeeee');
    print(widget.inwardType);
    if (widget.inwardData['submission_mode'] == "Digital" ||
        widget.inwardData['submission_mode'] == "online" ||
        widget.inwardType == 'Endorsement') {
      var proposalList = documents['proposalDocuments']!.where((data) {
        return data == '';
      }).toList();
      var emptyOtherDocuments = documents['otherDocuments']!.every((data) {
        return data == '';
      });

      if (proposal_doc_count - proposalList.length < 2) {
        print(proposal_doc_count - proposalList.length);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: const Text("Upload at least two proposal Document"),
            action: SnackBarAction(
              label: ' Cancel',
              onPressed: () {},
            )));
        return;
      }
      if (widget.inwardType == "Replenishment" && emptyOtherDocuments) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: const Text("Upload at least one Other Document"),
            action: SnackBarAction(
              label: ' Cancel',
              onPressed: () {},
            )));
        return;
      }
    }
    final appState = Provider.of<AppState>(context, listen: false);
    setState(() {
      isLoading = true;
    });
    try {
      // String? otherError;
      await uploadEdittedDocuments(
          appState.proposalId, 'proposal', 'proposalDocuments');
      // print(proposalError);

      await uploadEdittedDocuments(
          appState.proposalId, 'other', 'otherDocuments');

      // print(otherError);
      await updateStatus();
      String getDocumentsError = await getDocuments(true);
      if (getDocumentsError == "") {}
      setState(() {
        isLoading = false;
        status = 'discrepancy';
      });
      setState(() {
        isSubmitted = true;
      });
    } catch (err) {
      setState(() {
        isLoading = false;
      });
      print(err);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text("Documents not editted. Try again!"),
          action: SnackBarAction(
            label: ' Cancel',
            onPressed: () {},
          )));
    }
  }

  uploadProposal() async {
    print(widget.inwardData['submission_mode']);
    if (widget.inwardData['submission_mode'] == "Digital" ||
        widget.inwardData['submission_mode'] == "online" ||
        widget.inwardType == 'Endorsement') {
      var proposalList = documents['proposalDocuments']!.where((data) {
        return data == '';
      }).toList();
      var emptyOtherDocuments = documents['otherDocuments']!.every((data) {
        return data == '';
      });

      if (proposal_doc_count - proposalList.length < 2) {
        print(proposal_doc_count - proposalList.length);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: const Text("Upload at least two proposal Document"),
            action: SnackBarAction(
              label: ' Cancel',
              onPressed: () {},
            )));
        return;
      }
      if (widget.inwardType == "Replenishment" && emptyOtherDocuments) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: const Text("Upload at least one Other Document"),
            action: SnackBarAction(
              label: ' Cancel',
              onPressed: () {},
            )));
        return;
      }
    }

    final appState = Provider.of<AppState>(context, listen: false);

    print(widget.inwardData);
    setState(() {
      isLoading = true;
    });

    try {
      Future<List<String>> results = Future.wait([
        uploadProposalDocuments(appState.proposalId.toString(),
            documents['proposalDocuments']!, 'proposal'),
        uploadProposalDocuments(appState.proposalId.toString(),
            documents['otherDocuments']!, 'other'),
        // uploadCkycDocuments(appState.proposalId.toString())
      ]);
      await updateStatus();
      setState(() {
        isLoading = false;
      });
      setState(() {
        isSubmitted = true;
      });
      print(results);
    } catch (err) {
      setState(() {
        isLoading = false;
      });
      print(err);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text("Documents not submitted. Try again!"),
          action: SnackBarAction(
            label: ' Cancel',
            onPressed: () {},
          )));
    }
    // await uploadProposalDocuments(data['proposal']['id'].toString(),
    //     documents['proposalDocuments']!, 'proposal');
    // await uploadProposalDocuments(data['proposal']['id'].toString(),
    //     documents['otherDocuments']!, 'other');
    // if (widget.ckycDocuments != null) {
    //   await uploadCkycDocuments(data['proposal']['id'].toString());
    // }
  }

  uploadEdittedDocuments(proposalId, docType, documentType) async {
    print(docType);
    print("ggggggggggggggggggggggggggggggggggggggggggg");
    print(edittedDocuments[documentType]);

    try {
      SharedPreferences prefs = await _prefs;
      var token = prefs.getString('token') ?? '';
      final appState = Provider.of<AppState>(context, listen: false);
      Map<String, String> headers = {"Authorization": appState.accessToken};

      var docs = edittedDocuments[documentType];

      for (var i = 0; i < docs!.length; i++) {
        print(docs[i]);
        print(oldFileNames[documentType]![i]);
        if (docs[i] != '') {
          String fileExtension = docs[i].path.split('.').last;
          String fileName = '${docType}page-${i + 1}.$fileExtension';
          double newVersion = 1.0;
          String oldFileName = '';
          print(oldFileNames[documentType]![i] != '');
          if (oldFileNames[documentType]![i] != null) {
            oldFileName = oldFileNames[documentType]![i]['file_name'];
            newVersion =
                double.parse(oldFileNames[documentType]![i]['version']) + 0.1;
            List oldFileNameArr = oldFileName.split('_');

            oldFileNameArr[2] = 'V${newVersion.toString().split('.')[0]}';
            oldFileNameArr[3] = newVersion.toStringAsFixed(1).split('.')[1];
            print(oldFileNameArr);
            fileName =
                '${oldFileNameArr.join('_').split('.')[0]}.$fileExtension';
          }
          print('riyaaaaaaaaaaaaaaaaaaaaaaaaaaa');
          // var formData = FormData();
          print(oldFileName);
          var formData = FormData.fromMap({
            'proposal_id': proposalId.toString(),
            'doc_type': docType,
            'oldFileName': oldFileName,
            'version': newVersion.toString(),
            'file':
                await MultipartFile.fromFile(docs[i].path, filename: fileName)
          });
          print('donee');
          print(formData);
          // formData.fields.add(MapEntry('proposal_id', proposalId.toString()));
          // formData.fields.add(MapEntry('doc_type', docType));
          // formData.fields.add(MapEntry("oldFileName",
          //     oldFileNames['proposalDocuments']![i]['file_name']));
          // formData.fields.add(MapEntry("version", newVersion.toString()));
          // formData.files.add(MapEntry(
          //     'file',
          //     await MultipartFile.fromFile(docs[i].path,
          //         filename: oldFileNameArr.join('_'))));
          try {
            final response = await dio.post(
                'https://uatcld.sbigeneral.in/SecureApp/singleProposalDocument',
                data: formData,
                options: Options(headers: headers));

            // print('form submitted');
            print(response);
            // print(oldFileNames['proposalDocuments']![i] + "Submitted");

            // return "Document Submitted";
          } on DioException catch (error) {
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('File not uploaded.')));
            print(error);
            print("Documents not submitted. Try again!");
            // return "";
          }
        }
      }
    } catch (err) {
      setState(() {
        isLoading = false;
      });
      print(err);
      // return "";
    }
    // return "";
  }

  updateStatus() async {
    final appState = Provider.of<AppState>(context, listen: false);
    Map<String, String> postData = {
      'proposal_id': appState.proposalId.toString(),
      "status": widget.isEdit ? 'discrepancy' : ''
    };
    SharedPreferences prefs = await _prefs;
    var token = prefs.getString('token') ?? '';
    Map<String, String> headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      "Accept": "application/json",
      "Authorization": appState.accessToken
    };

    try {
      final response = await dio.post(
          'https://uatcld.sbigeneral.in/SecureApp/inwardComplete',
          data: postData,
          options: Options(headers: headers));
      print(response);
    } on DioException catch (error) {
      print(error.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
            appBar: AppBar(
              leading: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.arrow_back),
                color: Colors.white,
              ),
              title: const Text(
                'Proposal Documents',
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
              centerTitle: true,
              backgroundColor: const Color.fromRGBO(13, 154, 189, 1),
              titleTextStyle: const TextStyle(color: Colors.white),
            ),
            body: Stack(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(15),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Upload Proposal Documents*: ',
                          maxLines: 2,
                          style: TextStyle(
                              color: Color.fromRGBO(11, 133, 163, 1),
                              fontSize: 13,
                              fontWeight: FontWeight.bold),
                        ),
                        _heightGap(),
                        Wrap(
                          spacing: 20,
                          runSpacing: 15,
                          children: List.generate(
                              documents['proposalDocuments']!.length, (index) {
                            return _uploadDocument('Upload\nProposal\nDocument',
                                index, 'proposalDocuments');
                          }),
                        ),

                        documents['otherDocuments']!.every(
                                            (element) => element == '') ==
                                        false &&
                                    widget.isView == true ||
                                widget.isEdit ||
                                widget.isEdit == false && widget.isView == false
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _heightGap(),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Upload Other Documents: ',
                                        maxLines: 2,
                                        style: TextStyle(
                                            color:
                                                Color.fromRGBO(11, 133, 163, 1),
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      widget.isView == false &&
                                              widget.inwardType !=
                                                  'Replenishment'
                                          ? TextButton(
                                              onPressed: () {
                                                setState(() {
                                                  if (documents[
                                                              'otherDocuments']!
                                                          .length <
                                                      12) {
                                                    documents['otherDocuments']!
                                                        .add('');
                                                  }
                                                });
                                              },
                                              child: const Text(
                                                '+',
                                                style: TextStyle(
                                                    color: Color.fromRGBO(
                                                        11, 133, 163, 1),
                                                    fontSize: 20,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            )
                                          : Container(),
                                    ],
                                  ),
                                ],
                              )
                            : Container(),
                        _heightGap(),
                        Wrap(
                          spacing: 20,
                          runSpacing: 15,
                          children: List.generate(
                              documents['otherDocuments']!.length, (index) {
                            return _uploadDocument('Upload\nOther\nDocument',
                                index, 'otherDocuments');
                          }),
                        ),
                        _heightGap(),
                        Container(
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            color: Color.fromRGBO(11, 133, 163, 1),
                          ),
                          child: TextButton(
                              onPressed: () {
                                print('submit');
                                // print(widget.inwardData);
                                // uploadEndorsement();
                                // if (widget.inwardType == 'Endorsement') {
                                //   uploadEndorsement();
                                // } else {
                                print(widget.isEdit);
                                if (widget.isEdit) {
                                  print('editing');
                                  editProposal();
                                } else if (widget.isView) {
                                  Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const InwardStatus2()));
                                } else {
                                  uploadProposal();
                                }

                                //}
                              },
                              child: Text(
                                widget.isEdit
                                    ? 'Update Inward'
                                    : widget.isView
                                        ? 'Close'
                                        : 'Submit Inward',
                                style: const TextStyle(color: Colors.white),
                              )),
                        )
                        // const Text(
                        //   'Upload Other Documents: ',
                        //   maxLines: 2,
                        //   style: TextStyle(
                        //       color: Color.fromRGBO(11, 133, 163, 1),
                        //       fontSize: 13,
                        //       fontWeight: FontWeight.bold),
                        // ),
                        // _heightGap(),
                        // Wrap(
                        //   spacing: 10,
                        //   children: List.generate(4, (index) {
                        //     return _uploadDocument(
                        //         'Upload\nOther\nDocument', index, 'otherDocuments');
                        //   }),
                        // ),
                        // _heightGap(),
                      ],
                    ),
                  ),
                ),
              ],
            )),
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
                      BoxDecoration(color: Colors.white.withOpacity(0.7)),
                  child: Center(
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                        const Text('Loading Data...',
                            style: TextStyle(
                              decoration: TextDecoration.none,
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
            : Container(),
        isSubmitted
            ? Positioned(
                // left: 20,
                // right: 20,
                // top: 40,
                // bottom: 40,
                child: Stack(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      decoration: const BoxDecoration(color: Colors.black38),
                    ),
                    Center(
                      child: Container(
                        margin: const EdgeInsets.fromLTRB(40, 160, 40, 160),
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            boxShadow: const [
                              BoxShadow(
                                color:
                                    //  Color.fromRGBO(231, 181, 229, 0.9),
                                    Color.fromRGBO(15, 5, 158, 0.4),
                                blurRadius: 5.0, // soften the shadow
                                spreadRadius: 2.0, //extend the shadow
                                offset: Offset(
                                  3.0, // Move to right 5  horizontally
                                  3.0, // Move to bottom 5 Vertically
                                ),
                              ),
                            ],
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: const Color.fromRGBO(13, 154, 189, 0.4),
                                width: 4)),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text(
                              'Form Submitted Succcessfully!',
                              maxLines: 3,
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  decoration: TextDecoration.none),
                            ),
                            const SizedBox(
                              height: 30,
                            ),
                            Text(
                              'Inward No: $inwardId',
                              maxLines: 3,
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  decoration: TextDecoration.none),
                            ),
                            const SizedBox(
                              height: 30,
                            ),
                            Container(
                              padding: const EdgeInsets.all(15),
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color.fromRGBO(38, 173, 20, 1),
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        //  Color.fromRGBO(231, 181, 229, 0.9),
                                        Color.fromRGBO(15, 5, 158, 0.4),
                                    blurRadius: 5.0, // soften the shadow
                                    spreadRadius: 2.0, //extend the shadow
                                    offset: Offset(
                                      3.0, // Move to right 5  horizontally
                                      3.0, // Move to bottom 5 Vertically
                                    ),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 70,
                              ),
                            ),
                            const SizedBox(
                              height: 30,
                            ),
                            TextButton(
                              onPressed: () => Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const InwardStatus2())),
                              child: const Text('OK'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : Container(),
      ],
    );
  }

  _heightGap() {
    return const SizedBox(height: 10);
  }

  Future<Response> fetchBlob(String blobUrl) async {
    final dio = Dio();
    return await dio.get(blobUrl,
        options: Options(responseType: ResponseType.bytes));
  }

  _uploadDocument(String label, int index, String type) {
    if (widget.isView &&
        (documents[type]![index] == null || documents[type]![index] == '')) {
      return Container();
    }
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 120.0,
          width: 140.0,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                  color: const Color.fromRGBO(13, 154, 189, 1), width: 2)),
          child: (documents[type]![index] != null &&
                  documents[type]![index] != '')
              ? Padding(
                  padding: const EdgeInsets.all(10),
                  child: Center(
                      child: documents[type]![index]["fileType"] ==
                              'application/pdf'
                          ? PdfViewer(blobUrl: documents[type]![index]["url"])
                          : Image.network(documents[type]![index]["url"])))
              : Padding(
                  padding: const EdgeInsets.all(10),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6)),
                        backgroundColor: Color.fromRGBO(235, 234, 234, 0.663)),
                    child: Text(
                      label,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: Color.fromRGBO(11, 133, 163, 1),
                      ),
                    ),
                    onPressed: () {
                      if (!widget.isView) {
                        _pickFile(type, index);
                      }
                    },
                  ),
                ),
        ),
        (documents[type]![index] != null &&
                documents[type]![index] != '' &&
                !widget.isView)
            ? Positioned(
                top: -20,
                right: -30,
                child: TextButton(
                  child: const Text(
                    'X',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.red,
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      if (documents[type]![index] != null &&
                          documents[type]![index].isNotEmpty) {
                        html.Url.revokeObjectUrl(documents[type]![index]);
                      }
                      documents[type]![index] = '';
                      edittedDocuments[type]![index] = '';
                    });
                  },
                ),
              )
            : const Text('')
      ],
    );
  }

  Future<void> _pickFile(String type, int index) async {
    html.FileUploadInputElement inputElement = html.FileUploadInputElement();
    inputElement.multiple = false;
    inputElement.accept = '.pdf,.jpg,.jpeg,.png';

    inputElement.click();

    inputElement.onChange.listen((e) {
      final files = inputElement.files;
      if (files != null && files.isNotEmpty) {
        final reader = html.FileReader();
        reader.readAsArrayBuffer(files[0]);

        reader.onLoadEnd.listen((e) {
          final fileType = files[0].type;
          final blob = html.Blob([reader.result as List<int>], fileType);
          final url = html.Url.createObjectUrlFromBlob(blob);

          setState(() {
            if (documents[type]![index] != null &&
                documents[type]![index].isNotEmpty) {
              html.Url.revokeObjectUrl(documents[type]![index]);
            }

            documents[type]![index] = {"fileType": fileType, "url": url};
            if (widget.isEdit) {
              edittedDocuments[type]![index] = {
                "fileType": fileType,
                "url": url
              };
            }
          });
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No document selected')),
        );
      }
    });
  }

  void _showPicker(
      {required BuildContext context,
      required String type,
      required int index}) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Photo Library'),
                onTap: () {
                  getImage(ImageSource.gallery, type, index);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Camera'),
                onTap: () {
                  getImage(ImageSource.camera, type, index);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.upload_file),
                title: const Text('PDF'),
                onTap: () {
                  _pickFile(type, index);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future getImage(ImageSource img, String type, int index) async {
    final pickedFile = await picker.pickImage(source: img);
    if (pickedFile != null) {
      setState(() {
        documents[type]![index] = File(pickedFile.path);
        if (widget.isEdit) {
          edittedDocuments[type]![index] = File(pickedFile.path);
        }
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No document selected')),
      );
    }
  }
}
