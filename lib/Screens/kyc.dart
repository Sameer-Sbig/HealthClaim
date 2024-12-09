import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:secure_app/Widgets/DatePickerFormField.dart';
import 'package:secure_app/Widgets/DropdownWidget.dart';
import 'package:secure_app/Encryption-Decryption/crypto-utils.dart';
import 'package:secure_app/Widgets/customInputContainer%201.dart';
import 'package:secure_app/customProvider.dart';
import 'package:secure_app/dioSingleton.dart';
import 'package:secure_app/Screens/uploadProposal.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';

class KYCForm extends StatefulWidget {
  final isEdit;
  final isView;
  final inwardData;
  final inwardType;
  final edit;
  const KYCForm({
    super.key,
    this.isEdit = false,
    this.isView = false,
    this.inwardData,
    this.inwardType,
    this.edit = false,
  });

  @override
  State<KYCForm> createState() => _KYCFormState();
}

class _KYCFormState extends State<KYCForm> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  var productName;
  String? _kycAvailable;
  String? _panAvailable;
  String? _cinAvailable;
  String? selectedValue;
  String? selectedDocument;
  String? selectedIdentity;
  String? selectedIdentity2;
  String? selectedIdentity3;
  String? selectedIdentity4;
  String? selectedIdentity5;
  String? selectedIdentity6;
  String? selectedIdentity7;
  String? selectedAddress;
  String incorporationDate = DateFormat('dd-MM-yyyy').format(DateTime.now());
  final controller1 = TextEditingController();
  var oldVersion;
  var checkKYC;
  TextEditingController panNumberController = TextEditingController();
  bool isFetched = false;
  Map labelling = {
    "pan_form60": 'Select Documents',
    "id_proof": 'Proof of Identity',
    "address_proof": 'Proof of Address'
  };
  Map<String, String?> selectedCategories = {
    "pan_form60": null,
    "id_proof": null,
    "address_proof": null,
  };
  Map<String, List> ckycDocuments = {
    "pan_form60": [''],
    "id_proof": [''],
    "address_proof": ['']
  };

  Map<String, List> edittedDocuments = {
    "pan_form60": [''],
    "id_proof": [''],
    "address_proof": ['']
  };

  Map<String, List> oldFileNames = {
    "pan_form60": [null],
    "id_proof": [null],
    "address_proof": [null]
  };
  Map<String, int?> documentIds = {
    "pan_form60": null,
    "id_proof": null,
    "address_proof": null
  };
  List<String> rejectionList = [
    'Registration Certificate',
    'Certificate of Incorporation/Formation'
  ];
  String option = '';
  bool noKYC = false;
  bool editKYC = false;
  bool edit = false;
  bool isSubmitted = false;
  bool fetchKYC = true;
  List<String> entity = <String>[];
  // List<String> entity = <String>[
  //   'Sole Proprietorship',
  //   'Partnership Firm',
  //   'HUF',
  //   'Private Limited Company',
  //   'Public Limited Company',
  //   'Society',
  //   'Association of Persons',
  //   'Trust',
  //   'Liquidator',
  //   'Limited Liability Partnership',
  //   'Artificial Liability Partnership',
  //   'Public Sector Banks',
  //   'Central/ State Gov Dept',
  //   'Section 8 Companies',
  //   'Artificial Jurisdical Person',
  //   'International Organisation/ Agency',
  //   'Not Categorized',
  //   'Foreign Portfolio Investors',
  //   'Others'
  // ];

  List<String> documents = <String>[
    'PAN Card',
    'Form 60',
  ];
  List<String> identity1 = <String>[
    'Registration Certificate',
    'Activity Proof-1',
    'Activity Proof-2',
  ];
  List<String> identity2 = <String>[
    'OVD in respect of person authorized to transact',
    'Power of Atterney granted to Manager',
    'Registration Certificate',
    'Partnership Deed'
  ];

  List<String> identity3 = <String>[
    'OVD in respect of person authorized to transact',
    'Power of Atterney granted to Manager',
    'Registration Certificate',
  ];

  List<String> identity4 = <String>[
    'OVD in respect of person authorized to transact',
    'Power of Atterney granted to Manager',
    'Certificate of Incorporation/Formation',
    'Registration Certificate',
    'Memorandum and Articles of Association',
    'Board Resolution'
  ];
  List<String> identity5 = <String>[
    'OVD in respect of person authorized to transact',
    'Power of Atterney granted to Manager',
    'Registration Certificate',
    'Partnership Deed',
    'Trust Deed',
    'Board Resolution'
  ];
  List<String> identity6 = <String>[
    'OVD in respect of person authorized to transact',
    'Power of Atterney granted to Manager',
    'Registration Certificate',
    'Trust Deed',
    'Board Resolution'
  ];

  List<String> identity7 = <String>[
    'OVD in respect of person authorized to transact',
    'Power of Atterney granted to Manager',
    'Registration Certificate',
    'Board Resolution'
  ];
  List<String> address1 = <String>['Registration Certificate', 'Others'];
  List<String> address2 = <String>[
    'Certificate of Incorporation/Formation',
    'Registration Certificate',
    'Others'
  ];
  File? galleryFile;
  final picker = ImagePicker();
  Dio dio = DioSingleton.dio;
  TextEditingController ckycIDController = TextEditingController();
  TextEditingController companyIDController = TextEditingController();
  TextEditingController idProofController = TextEditingController();
  TextEditingController addressProofController = TextEditingController();
  // Map ckycData = {};
  bool isLoading = false;
  Map ckycData = {"CKYCNumber": "", "CKYCFullName": "", "CKYCDOB": ""};
  List ckycEntities = [];
  List entityDropdownData = [];
  final _formKey = GlobalKey<FormState>();
  String inputType = '';
  String inputNo = '';
  var entityID;
  bool kyc = false;
  bool pan = false;
  bool isPan = false;
  bool isCIN = false;
  bool cin = false;
  bool manual = false;
  bool fetchKyc = false;
  bool fetchPan = false;
  bool fetchCIN = false;
  bool enableCKYC = false;
  bool enablePan = false;
  bool enableCIN = false;
  bool enable2 = false;
  bool disable = false;

  var onChanged;
  var onChanged2;
  var onChanged3;
  var onChanged4;

  getCkycEntities() async {
    print('done');
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
      final response = await dio.get(
          'https://uatcld.sbigeneral.in/SecureApp/ckycEntity',
          options: Options(headers: headers));
      var entityData = jsonDecode(response.data);
      print(entityData);

      setState(() {
        ckycEntities = entityData;
        entity = ckycEntities.map<String>((e) => e['entity_type']).toList();
      });
      setState(() {
        isLoading = false;
      });
      if (widget.isView) {
        getCKYCDetails();
      }
    } catch (err) {
      print(err);
      setState(() {
        isLoading = false;
      });
    }
  }

  getCategoryDropdowns(ckycEntityId) async {
    // setState(() {
    //   isLoading = true;
    // });
    SharedPreferences prefs = await _prefs;
    var token = prefs.getString('token') ?? '';
    final appState = Provider.of<AppState>(context, listen: false);
    Map<String, String> headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      "Accept": "application/json",
      "Authorization": appState.accessToken
    };

    Map postData = {"ckyc_entity_type_id": ckycEntityId};
    try {
      final response = await dio.post(
          'https://uatcld.sbigeneral.in/SecureApp/document-types',
          data: postData,
          options: Options(headers: headers));
      var data = jsonDecode(response.data);
      setState(() {
        entityDropdownData = data['categories'];
        // isLoading = false;
        print(entityDropdownData);
      });
    } catch (err) {
      print(err);
      setState(() {
        isLoading = false;
      });
    }
  }

  void initState() {
    super.initState();

    print('thisss');
    print("isEdit ${widget.isEdit}");
    print("edit ${widget.edit}");
    // if (widget.edit == false && widget.isEdit) {
    //   setState(() {
    //     editKYC = false;
    //   });
    // } else if (widget.edit == false && widget.isEdit == false) {
    //   setState(() {
    //     editKYC = false;
    //   });
    // } else if (widget.isEdit || widget.edit) {
    //   setState(() {
    //     editKYC = true;
    //   });
    // }
    getVersion();
    getCkycEntities();

    setState(() {
      onChanged = (value) {
        if (_kycAvailable != value) {
          resetVariable();
          // kyc = false;
          isPan = false;
          pan = false;
          isCIN = false;
          cin = false;
          manual = false;
          fetchPan = false;
          fetchCIN = false;
        }
        setState(() {
          _kycAvailable = value;
        });
        if (_kycAvailable == 'Yes') {
          setState(() {
            kyc = true;
            fetchKyc = true;
            isPan = false;
            pan = false;
            isCIN = false;
            cin = false;
            manual = false;
            fetchPan = false;
            fetchCIN = false;
          });
        }
      };
      onChanged2 = (value) {
        if (_kycAvailable != value) {
          resetVariable();
          // kyc = false;
          kyc = false;
          fetchKyc = false;
          isPan = false;
          pan = false;
          fetchPan = false;
          isCIN = false;
          fetchCIN = false;
          cin = false;
          manual = false;
        }
        setState(() {
          _kycAvailable = value;
        });
        if (_kycAvailable == 'No') {
          setState(() {
            // _panAvailable = 'Yes';
            ckycIDController = TextEditingController();
            kyc = false;
            fetchKyc = false;
            isPan = true;
            pan = false;
            fetchPan = false;
            isCIN = false;
            fetchCIN = false;
            cin = false;
            manual = false;
          });
        }
      };
      onChanged3 = (value) {
        if (_panAvailable != value) {
          setState(() {
            _cinAvailable = null;
            selectedValue = null;
            selectedDocument = null;
            selectedCategories = {
              "pan_form60": null,
              "id_proof": null,
              "address_proof": null,
            };
            selectedIdentity = null;
            selectedIdentity2 = null;
            selectedIdentity3 = null;
            selectedIdentity4 = null;
            selectedIdentity5 = null;
            selectedIdentity6 = null;
            selectedIdentity7 = null;
            selectedAddress = null;
            // ckycIDController = TextEditingController();
            companyIDController = TextEditingController();
            idProofController = TextEditingController();
            addressProofController = TextEditingController();
            incorporationDate = DateFormat('dd-MM-yyyy').format(DateTime.now());
            kyc = false;
            fetchKyc = false;
            isPan = true;
            pan = false;
            fetchPan = false;
            isCIN = false;
            fetchCIN = false;
            cin = false;
            manual = false;
          });
        }
        setState(() {
          _panAvailable = value;
        });
        if (_panAvailable == 'Yes') {
          setState(() {
            if (_kycAvailable == 'Yes') {
              kyc = true;
              fetchKyc = false;
            } else {
              ckycIDController = TextEditingController();
              kyc = false;
            }
            fetchKyc = false;
            isPan = true;
            pan = true;
            fetchPan = true;
            isCIN = false;
            fetchCIN = false;
            cin = false;
            manual = false;
          });
        }
        if (_panAvailable == 'No') {
          setState(() {
            if (_kycAvailable == 'Yes') {
              kyc = true;
              fetchKyc = false;
            } else {
              ckycIDController = TextEditingController();
              kyc = false;
            }
            // else {
            //
            // }
            panNumberController = TextEditingController();
            fetchKyc = false;
            isPan = true;
            pan = false;
            fetchPan = false;
            isCIN = true;
            fetchCIN = false;
            cin = false;
            manual = false;
          });
        }
        // if (value == 'Yes') {
        //   setState(() {
        //     _cinAvailable = 'No';
        //     pan = true;
        //     fetchPan = true;
        //   });
        // }
        // if (value == 'No') {
        //   setState(() {
        //     _cinAvailable = null;
        //     _gender = null;
        //     pan = false;
        //     isAadhar = true;
        //     fetchKyc = false;
        //     fetchPan = false;
        //   });
        // }
      };
      onChanged4 = (value) {
        if (_cinAvailable != value) {
          setState(() {
            _cinAvailable = null;
            selectedValue = null;
            selectedDocument = null;
            selectedIdentity = null;
            selectedIdentity2 = null;
            selectedIdentity3 = null;
            selectedIdentity4 = null;
            selectedIdentity5 = null;
            selectedIdentity6 = null;
            selectedIdentity7 = null;
            selectedAddress = null;
            selectedCategories = {
              "pan_form60": null,
              "id_proof": null,
              "address_proof": null,
            };
            // ckycIDController = TextEditingController();
            companyIDController = TextEditingController();
            idProofController = TextEditingController();
            addressProofController = TextEditingController();
            incorporationDate = DateFormat('dd-MM-yyyy').format(DateTime.now());
            kyc = false;
            fetchKyc = false;
            isPan = true;
            pan = false;
            fetchPan = false;
            isCIN = true;
            fetchCIN = false;
            cin = false;
            manual = false;
          });
        }
        setState(() {
          _cinAvailable = value;
        });
        if (_cinAvailable == 'Yes') {
          setState(() {
            if (_kycAvailable == 'Yes') {
              kyc = true;
              fetchKyc = false;
            } else {
              ckycIDController = TextEditingController();
              kyc = false;
              fetchKyc = false;
            }
            if (_panAvailable == 'Yes') {
              isPan = true;
              pan = true;
              fetchPan = false;
            } else {
              panNumberController = TextEditingController();
              isPan = true;
              pan = false;
              fetchPan = false;
            }

            isCIN = true;
            fetchCIN = true;
            cin = true;
            manual = false;
          });
        }
        if (_cinAvailable == 'No') {
          setState(() {
            if (_kycAvailable == 'Yes') {
              kyc = true;
              fetchKyc = false;
            } else {
              ckycIDController = TextEditingController();
              kyc = false;
              fetchKyc = false;
            }
            if (_panAvailable == 'Yes') {
              isPan = true;
              pan = true;
              fetchPan = false;
            } else {
              panNumberController = TextEditingController();
              isPan = true;
              pan = false;
              fetchPan = false;
            }
            companyIDController = TextEditingController();
            isCIN = true;
            fetchCIN = false;
            cin = false;
            manual = true;
            onChanged = null;
            onChanged2 = null;
            onChanged3 = null;
            onChanged4 = null;
            disable = true;
            enableCKYC = true;
            enablePan = true;
            enableCIN = true;
          });
        }
        // if (value == 'Yes') {
        //   setState(() {
        //     aadhar = true;
        //     fetchAadhar = true;
        //   });
        // }
        // if (value == 'No') {
        //   setState(() {
        //     aadhar = false;
        //     manual = true;
        //     fetchKyc = false;
        //     fetchPan = false;
        //     fetchAadhar = false;
        //   });
        // }
      };
    });
    // getToken();
    // fetchCKYC();
  }

  getCKYCDetails() async {
    print("asdasd");
    setState(() {
      isLoading = true;
    });
    SharedPreferences prefs = await _prefs;
    var token = prefs.getString('token') ?? '';
    final appState = Provider.of<AppState>(context, listen: false);

    var proposalId = appState.proposalId;
    Map<String, dynamic> postData = {"proposal_id": proposalId};

    print(postData);
    Map<String, String> headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      "Accept": "application/json",
      "Authorization": appState.accessToken
    };

    String result = aesGcmEncryptJson(jsonEncode(postData));
    Map<String, dynamic> encryptedData = {'encryptedData': result};
    print(encryptedData);

    try {
      final response = await dio.post(
          'https://uatcld.sbigeneral.in/SecureApp/ckycDetails',
          options: Options(headers: headers),
          data: encryptedData);
      // var data = jsonDecode(response.data);
      String decryptedData = aesGcmDecryptJson(response.data);
      print(decryptedData);
      var data = jsonDecode(decryptedData);
      // var data = const JsonDecoder().convert(jsonMap);
      // var data = jsonDecode(decryptedData);

      print(data);
      setState(() {
        productName = widget.inwardData['product'];
        incorporationDate = data['dob'];
        _kycAvailable = data['ckyc_num'] != null ? "Yes" : 'No';
        if (data['ckyc_num'] != null) {
          kyc = true;
          fetchKyc = false;
          ckycIDController.text = data['ckyc_num'] ?? '';
        }
      });
      setState(() {
        _panAvailable = data['pan_avail'] == '1' ? "Yes" : 'No';
        if (data['pan_avail'] == '1') {
          isPan = true;
          pan = true;
          fetchPan = false;
          panNumberController.text = data['pan_num'] ?? '';
        } else {
          isPan = true;
          pan = false;
          fetchPan = false;
        }
      });
      setState(() {
        _cinAvailable = data['cin_avail'] == '1' ? "Yes" : 'No';
        if (data['cin_avail'] == '1') {
          isCIN = true;
          cin = true;
          fetchCIN = false;
          companyIDController.text = data['cin'] ?? '';
        }
        if (data["ckyc_entity_type_id"] != null) {
          isCIN = true;
          cin = false;
          fetchCIN = false;
          manual = true;
          selectedValue = entity[data["ckyc_entity_type_id"] - 1];
        }
        if (data['response_ckyc_num'] != null) {
          isFetched = true;
          ckycData["CKYCNumber"] = data['response_ckyc_num'] ?? '';
          ckycData["CKYCFullName"] = data['response_ckyc_customer_name'] ?? '';
          ckycData["CKYCDOB"] = data['response_ckyc_dob'] ?? '';
          isSubmitted = true;
          isLoading = false;
        }
        onChanged = null;
        onChanged2 = null;
        onChanged3 = null;
        onChanged4 = null;
        disable = true;
        enableCKYC = true;
        enablePan = true;
        enableCIN = true;
        enable2 = true;
      });
      setState(() {
        addressProofController.text = data["doc_addr_proof_number"] ?? '';
        documentIds['id_proof'] = data["doc_id_proof_type_selected"];
        if (data["doc_addr_proof_type_selected"] != null) {
          documentIds['address_proof'] = data["doc_addr_proof_type_selected"];
        }
        documentIds['pan_form60'] = data["doc_pan_form60_type_selected"];
        print('new');
        print(data["doc_pan_form60_type_selected"]);
        print(documentIds);
        print('doneeeee');
      });
      print(addressProofController.text);
      print(data["doc_id_proof_type_selected"]);
      if (data["doc_id_proof_type_selected"] == null &&
          data["doc_pan_form60_type_selected"] == null) {
        setState(() {
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = true;
        });
        getDocuments(
            data["ckyc_entity_type_id"], data["doc_addr_proof_number"]);
      }
    } catch (error) {
      print(error);
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text("Technical Error!"),
          action: SnackBarAction(
            label: ' Cancel',
            onPressed: () {},
          )));
    }
  }

  getVersion() async {
    print('version');
    setState(() {
      isLoading = true;
    });
    try {
      SharedPreferences prefs = await _prefs;
      var token = prefs.getString('token') ?? '';
      final appState = Provider.of<AppState>(context, listen: false);
      Map<String, String> headers = {"Authorization": appState.accessToken};
      Map<String, dynamic> postData = {'proposal_id': appState.proposalId};
      final response = await dio.post(
          'https://uatcld.sbigeneral.in/SecureApp/getCkycDocVersion',
          data: postData,
          options: Options(headers: headers));
      var data = jsonDecode(response.data);
      print(data);
      setState(() {
        oldVersion = data['latestDocVersion'];
        checkKYC = data['ckycAvailable'];
      });
      print('ckyc available: ${checkKYC}');
      print(data['customer_type'].toLowerCase());
      if (widget.isEdit) {
        if (checkKYC == true &&
            data['customer_type'].toLowerCase() == 'other') {
          setState(() {
            editKYC = true;
          });
        } else {
          setState(() {
            editKYC = false;
          });
        }
      }

      setState(() {
        isLoading = false;
      });
    } catch (err) {
      setState(() {
        isLoading = false;
      });
      print(err);
    }
  }

  Future<bool> editCkycDocuments() async {
    setState(() {
      isLoading = true;
    });
    try {
      final appState = Provider.of<AppState>(context, listen: false);
      await uploadCkycDocuments(appState.proposalId);
      print('done edit');
      setState(() {
        isLoading = false;
      });
      return false;
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
      return true;
    }
  }

  Future<String> uploadCkycDocuments(proposalId) async {
    SharedPreferences prefs = await _prefs;
    var token = prefs.getString('token') ?? '';
    final appState = Provider.of<AppState>(context, listen: false);
    Map<String, String> headers = {"Authorization": appState.accessToken};
    var formData = FormData();
    double newVersion = oldVersion == 0 ? 1.0 : double.parse(oldVersion) + 0.1;
    print(newVersion);
    formData.fields.add(MapEntry('proposal_id', proposalId.toString()));
    formData.fields.add(MapEntry('version', newVersion.toStringAsFixed(1)));
    if (entityDropdownData.isEmpty) {
      formData.fields.add(const MapEntry('docAvailable', 'N'));
    } else {
      for (var i = 0; i < ckycDocuments['pan_form60']!.length; i++) {
        if (ckycDocuments['pan_form60']![i] != '') {
          var fileExtension =
              ckycDocuments['pan_form60']![i].path.split('.').last;
          formData.files.add(MapEntry(
              'files',
              await MultipartFile.fromFile(ckycDocuments['pan_form60']![i].path,
                  filename:
                      '${documentIds['pan_form60']}_page${i + 1}.$fileExtension')));
        }
      }
      for (var i = 0; i < ckycDocuments['id_proof']!.length; i++) {
        if (ckycDocuments['id_proof']![i] != '') {
          var fileExtension =
              ckycDocuments['id_proof']![i].path.split('.').last;
          formData.files.add(MapEntry(
              'files',
              await MultipartFile.fromFile(ckycDocuments['id_proof']![i].path,
                  filename:
                      '${documentIds['id_proof']}_page${i + 1}.$fileExtension')));
        }
      }
      for (var i = 0; i < ckycDocuments['address_proof']!.length; i++) {
        if (ckycDocuments['address_proof']![i] != '') {
          var fileExtension =
              ckycDocuments['address_proof']![i].path.split('.').last;
          formData.files.add(MapEntry(
              'files',
              await MultipartFile.fromFile(
                  ckycDocuments['address_proof']![i].path,
                  filename:
                      '${documentIds['address_proof']}_page${i + 1}.$fileExtension')));
        }
      }
    }

    print("ckycDocuments");
    try {
      final response = await dio.post(
          'https://uatcld.sbigeneral.in/SecureApp/updateCkycDocuments',
          data: formData,
          options: Options(headers: headers));

      print('form submitted');
      print(response);

      return 'CKYC Documents Submitted';
    } on DioException catch (error) {
      print(error.message);
      return "Ckyc Documents not submitted. Try again!";
    }
  }

  resetVariable() {
    setState(() {
      _panAvailable = null;
      _cinAvailable = null;
      isPan = false;
      pan = false;
      isCIN = false;
      cin = false;
      enableCKYC = false;
      enablePan = false;
      enableCIN = false;
      manual = false;
      disable = false;
      enable2 = false;
      selectedValue = null;
      selectedDocument = null;
      selectedIdentity = null;
      selectedIdentity2 = null;
      selectedIdentity3 = null;
      selectedIdentity4 = null;
      selectedIdentity5 = null;
      selectedIdentity6 = null;
      selectedIdentity7 = null;
      selectedAddress = null;
      selectedCategories = {
        "pan_form60": null,
        "id_proof": null,
        "address_proof": null,
      };
      ckycIDController = TextEditingController();
      panNumberController = TextEditingController();
      companyIDController = TextEditingController();
      idProofController = TextEditingController();
      addressProofController = TextEditingController();
      incorporationDate = DateFormat('dd-MM-yyyy').format(DateTime.now());
      ckycDocuments = {
        "pan_form60": [''],
        "id_proof": [''],
        "address_proof": ['']
      };
      entityDropdownData = [];
      onChanged = (value) {
        if (_kycAvailable != value) {
          resetVariable();
          isPan = false;
          pan = false;
          isCIN = false;
          cin = false;
          manual = false;
          fetchPan = false;
          fetchCIN = false;
        }
        setState(() {
          _kycAvailable = value;
        });
        if (_kycAvailable == 'Yes') {
          setState(() {
            kyc = true;
            fetchKyc = true;
            isPan = false;
            pan = false;
            isCIN = false;
            cin = false;
            manual = false;
            fetchPan = false;
            fetchCIN = false;
          });
        }
      };
      onChanged2 = (value) {
        if (_kycAvailable != value) {
          resetVariable();
          kyc = false;
          fetchKyc = false;
          isPan = false;
          pan = false;
          fetchPan = false;
          isCIN = false;
          fetchCIN = false;
          cin = false;
          manual = false;
        }
        setState(() {
          _kycAvailable = value;
        });
        if (_kycAvailable == 'No') {
          setState(() {
            ckycIDController = TextEditingController();
            kyc = false;
            fetchKyc = false;
            isPan = true;
            pan = false;
            fetchPan = false;
            isCIN = false;
            fetchCIN = false;
            cin = false;
            manual = false;
          });
        }
      };
      onChanged3 = (value) {
        if (_panAvailable != value) {
          setState(() {
            _cinAvailable = null;
            selectedValue = null;
            selectedDocument = null;
            selectedIdentity = null;
            selectedIdentity2 = null;
            selectedIdentity3 = null;
            selectedIdentity4 = null;
            selectedIdentity5 = null;
            selectedIdentity6 = null;
            selectedIdentity7 = null;
            selectedAddress = null;
            selectedCategories = {
              "pan_form60": null,
              "id_proof": null,
              "address_proof": null,
            };
            companyIDController = TextEditingController();
            idProofController = TextEditingController();
            addressProofController = TextEditingController();
            incorporationDate = DateFormat('dd-MM-yyyy').format(DateTime.now());
            kyc = false;
            fetchKyc = false;
            isPan = true;
            pan = false;
            fetchPan = false;
            isCIN = false;
            fetchCIN = false;
            cin = false;
            manual = false;
          });
        }
        setState(() {
          _panAvailable = value;
        });
        if (_panAvailable == 'Yes') {
          setState(() {
            if (_kycAvailable == 'Yes') {
              kyc = true;
              fetchKyc = false;
            } else {
              ckycIDController = TextEditingController();
              kyc = false;
            }
            fetchKyc = false;
            isPan = true;
            pan = true;
            fetchPan = true;
            isCIN = false;
            fetchCIN = false;
            cin = false;
            manual = false;
          });
        }
        if (_panAvailable == 'No') {
          setState(() {
            if (_kycAvailable == 'Yes') {
              kyc = true;
              fetchKyc = false;
            } else {
              ckycIDController = TextEditingController();
              kyc = false;
            }

            panNumberController = TextEditingController();
            fetchKyc = false;
            isPan = true;
            pan = false;
            fetchPan = false;
            isCIN = true;
            fetchCIN = false;
            cin = false;
            manual = false;
          });
        }
      };
      onChanged4 = (value) {
        if (_cinAvailable != value) {
          setState(() {
            _cinAvailable = null;
            selectedValue = null;
            selectedDocument = null;
            selectedCategories = {
              "pan_form60": null,
              "id_proof": null,
              "address_proof": null,
            };
            selectedIdentity = null;
            selectedIdentity2 = null;
            selectedIdentity3 = null;
            selectedIdentity4 = null;
            selectedIdentity5 = null;
            selectedIdentity6 = null;
            selectedIdentity7 = null;
            selectedAddress = null;

            companyIDController = TextEditingController();
            idProofController = TextEditingController();
            addressProofController = TextEditingController();
            incorporationDate = DateFormat('dd-MM-yyyy').format(DateTime.now());
            kyc = false;
            fetchKyc = false;
            isPan = true;
            pan = false;
            fetchPan = false;
            isCIN = true;
            fetchCIN = false;
            cin = false;
            manual = false;
          });
        }
        setState(() {
          _cinAvailable = value;
        });
        if (_cinAvailable == 'Yes') {
          setState(() {
            if (_kycAvailable == 'Yes') {
              kyc = true;
              fetchKyc = false;
            } else {
              ckycIDController = TextEditingController();
              kyc = false;
              fetchKyc = false;
            }
            if (_panAvailable == 'Yes') {
              isPan = true;
              pan = true;
              fetchPan = false;
            } else {
              panNumberController = TextEditingController();
              isPan = true;
              pan = false;
              fetchPan = false;
            }

            isCIN = true;
            fetchCIN = true;
            cin = true;
            manual = false;
          });
        }
        if (_cinAvailable == 'No') {
          setState(() {
            if (_kycAvailable == 'Yes') {
              kyc = true;
              fetchKyc = false;
            } else {
              ckycIDController = TextEditingController();
              kyc = false;
              fetchKyc = false;
            }
            if (_panAvailable == 'Yes') {
              isPan = true;
              pan = true;
              fetchPan = false;
            } else {
              panNumberController = TextEditingController();
              isPan = true;
              pan = false;
              fetchPan = false;
            }
            companyIDController = TextEditingController();
            isCIN = true;
            fetchCIN = false;
            cin = false;
            manual = true;
            onChanged = null;
            onChanged2 = null;
            onChanged3 = null;
            onChanged4 = null;
            disable = true;
            enableCKYC = true;
            enablePan = true;
            enableCIN = true;
          });
        }
      };
    });
    // String _member = '';
  }

  fetchCKYC() async {
    setState(() {
      isLoading = true;
    });
    SharedPreferences prefs = await _prefs;
    var token = prefs.getString('token') ?? '';
    Map<String, dynamic> kycData = {
      "A99RequestData": {
        "RequestId": "ITSECURE${DateTime.now().millisecondsSinceEpoch}",
        "source": "gromoinsure",
        "policyNumber": "",
        "GetRecordType": "LE",
        "InputIdType": inputType,
        "InputIdNo": inputNo,
        "DateOfBirth": incorporationDate,
        "MobileNumber": "",
        "Pincode": "",
        "BirthYear": "",
        "Tags": "",
        "ApplicationRefNumber": "",
        "FirstName": '',
        "MiddleName": '',
        "LastName": '',
        "Gender": "",
        "ResultLimit": "Latest",
        "photo": "",
        "AdditionalAction": ""
      }
    };

    print(kycData);
    final appState = Provider.of<AppState>(context, listen: false);
    String result = aesGcmEncryptJson(jsonEncode(kycData));
    Map<String, dynamic> encryptedData = {'encryptedData': result};
    Map<String, String> headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      "Accept": "application/json",
      "Authorization": appState.accessToken
    };
    try {
      final response = await dio.post(
          'https://uatcld.sbigeneral.in/SecureApp/ckyc',
          data: encryptedData,
          options: Options(headers: headers));

      if (response.statusCode == 200) {
        // final Map<String, dynamic> data = jsonDecode(response.data);
        String decryptedData = aesGcmDecryptJson(response.data);

        var data = jsonDecode(decryptedData);
        print(data);
        // var data = const JsonDecoder().convert(jsonMap);
        setState(() {
          isFetched = true;
          ckycData = data;
          isLoading = false;
          isSubmitted = true;
          fetchKYC = false;
          if (_kycAvailable == 'Yes') {
            fetchKyc = false;
          }
          if (_panAvailable == 'Yes') {
            fetchKyc = false;
            fetchPan = false;
          }
          if (_cinAvailable == 'Yes') {
            fetchKyc = false;
            fetchPan = false;
            fetchCIN = false;
          }
        });
      }
    } catch (error) {
      setState(() {
        isLoading = false;
        isFetched = false;
        noKYC = true;
        editKYC = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text("No Records Found!"),
          action: SnackBarAction(
            label: ' Cancel',
            onPressed: () {},
          )));
    }
  }

  getDocumentCategory(documentId) async {
    print("document category function callled");
    print(documentId);
    SharedPreferences prefs = await _prefs;
    var token = prefs.getString('token') ?? '';
    final appState = Provider.of<AppState>(context, listen: false);

    Map<String, String> headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      "Accept": "application/json",
      "Authorization": appState.accessToken
    };
    try {
      final response = await dio.post(
          'https://uatcld.sbigeneral.in/SecureApp/documentId',
          data: {"id": documentId},
          options: Options(headers: headers));
      print('asdas');
      print(response);
      print("document category function response");
      return jsonDecode(response.data);
    } catch (err) {
      return null;
    }
  }

  fetchFilePath(String filename) async {
    final dir = await getApplicationDocumentsDirectory();
    final filePath = '${dir.path}/$filename';
    SharedPreferences prefs = await _prefs;
    var token = prefs.getString('token') ?? '';
    final appState = Provider.of<AppState>(context, listen: false);

    var proposalId = appState.proposalId;
    Map<String, String> headers = {"Authorization": appState.accessToken};

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

  getDocuments(ckycEntityTypeId, addressProofNumber) async {
    setState(() {
      isLoading = true;
    });
    print('zalaaaa');
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
      final response = await dio.post(
          'https://uatcld.sbigeneral.in/SecureApp/proposalDocuments',
          data: {'proposal_id': proposalId, 'doc_type': 'ckyc'},
          options: Options(headers: headers));
      var data = List.from(jsonDecode(response.data));
      await getCategoryDropdowns(ckycEntityTypeId);
      // List documentIdsInternal = [];

      for (var i = 0; i < data.length; i++) {
        print(data[i]['file_name']);
        var documentId = data[i]['file_name'].split('.')[0].split('_')[5];
        print(documentId);
        String documentName = data[i]['file_name'].split('.')[0];
        var documentIndex = int.parse(documentName[documentName.length - 1]);
        print(documentIndex);
        Map? categoryMap = await getDocumentCategory(int.parse(documentId));
        print(categoryMap);
        // if (documentIdsInternal.contains(documentId) == false) {
        //   documentIdsInternal.add(documentId);
        // }
        if (categoryMap != null) {
          print(data[i]['file_name']);
          ckycDocuments[categoryMap['category']]![documentIndex - 1] =
              File(await fetchFilePath(data[i]['file_name']));
        }
      }
      print(documentIds);
      Map? panForm60Map = await getDocumentCategory(documentIds['pan_form60']);
      Map? idProofMap = await getDocumentCategory(documentIds['id_proof']);
      Map? addressProofMap;
      if (documentIds['address_proof'] != null) {
        addressProofMap =
            await getDocumentCategory(documentIds['address_proof']);
      }
      print(idProofMap);
      print(panForm60Map);
      print(addressProofMap);
      setState(() {
        selectedCategories['pan_form60'] = panForm60Map!['sub_category'];
        selectedCategories['id_proof'] = idProofMap!['sub_category'];
        if (documentIds['address_proof'] != null) {
          selectedCategories['address_proof'] =
              addressProofMap!['sub_category'];
          print(addressProofNumber);
          addressProofController.text = addressProofNumber;
        }
      });
      setState(() {
        isLoading = false;
      });
      print(selectedCategories);
    } catch (error) {
      setState(() {
        isLoading = false;
      });

      print(error);
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error! Failed to fetch documents')));
    }
  }

  sendCkyc(kycData, formData, context) async {
    print('sending');
    setState(() {
      isLoading = true;
    });
    print('sent');

    try {
      final appState = Provider.of<AppState>(context, listen: false);
      print(appState.proposalId);

      String result = aesGcmEncryptJson(
        jsonEncode({"proposal_detail_id": appState.proposalId, ...kycData}),
      );
      print(kycData);

      Map<String, dynamic> encryptedCkycData = {'encryptedData': result};
      print(encryptedCkycData);
      SharedPreferences prefs = await _prefs;
      var token = prefs.getString('token') ?? '';
      Map<String, String> headers = {
        'Content-Type': 'application/json; charset=UTF-8',
        "Accept": "application/json",
        "Authorization": appState.accessToken
      };
      final response = await dio.post(
          'https://uatcld.sbigeneral.in/SecureApp/postCkycDetails',
          data: encryptedCkycData,
          options: Options(headers: headers));
      print(response.data);
      String uploadDocResult =
          await uploadCkycDocs(appState.proposalId, formData);
      print(uploadDocResult);
      if (uploadDocResult == "" || entityDropdownData.isEmpty) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ProposalDocuments(
                    inwardData: widget.inwardData,
                    inwardType: widget.inwardType,
                    isView: widget.isView,
                    isEdit: widget.isEdit,
                    ckycData: kycData,
                    ckycDocuments: formData)));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(uploadDocResult),
            action: SnackBarAction(
              label: ' Cancel',
              onPressed: () {},
            )));
      }

      setState(() {
        isLoading = false;
        editKYC = true;
      });
    } catch (err) {
      print(err);
      setState(() {
        isLoading = false;
      });
    }
  }

  editCkyc(kycData, formData, context) async {
    print('editedd');
    setState(() {
      isLoading = true;
    });
    print(kycData);

    try {
      final appState = Provider.of<AppState>(context, listen: false);
      print(appState.proposalId);
      print(kycData);
      SharedPreferences prefs = await _prefs;
      var token = prefs.getString('token') ?? '';

      String result = aesGcmEncryptJson(
        jsonEncode({"proposal_detail_id": appState.proposalId, ...kycData}),
      );

      Map<String, dynamic> encryptedCkycData = {'encryptedData': result};

      Map<String, String> headers = {
        'Content-Type': 'application/json; charset=UTF-8',
        "Accept": "application/json",
        "Authorization": appState.accessToken
      };
      final response = await dio.post(
          'https://uatcld.sbigeneral.in/SecureApp/updateCkycDetails',
          data: encryptedCkycData,
          options: Options(headers: headers));
      print(response.data);
      bool ckycError = await editCkycDocuments();
      setState(() {
        isLoading = false;
      });
      if (ckycError) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: const Text("Ckyc Documents not editted!"),
            action: SnackBarAction(
              label: ' Cancel',
              onPressed: () {},
            )));
        return;
      } else {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ProposalDocuments(
                    inwardData: widget.inwardData,
                    inwardType: widget.inwardType,
                    isView: widget.isView,
                    isEdit: widget.isEdit,
                    ckycData: kycData,
                    ckycDocuments: formData)));
        setState(() {
          editKYC = true;
        });
      }
    } catch (err) {
      print(err);
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<String> uploadCkycDocs(proposalId, FormData formData) async {
    SharedPreferences prefs = await _prefs;
    final appState = Provider.of<AppState>(context, listen: false);
    var token = prefs.getString('token') ?? '';
    Map<String, String> headers = {"Authorization": appState.accessToken};

    formData.fields.add(MapEntry('proposal_id', proposalId.toString()));
    formData.fields.add(const MapEntry('doc_type', 'ckyc'));
    print("ckycDocuments");
    try {
      final response = await dio.post(
          'https://uatcld.sbigeneral.in/SecureApp/proposalDocument',
          data: formData,
          options: Options(headers: headers));

      print('form submitted');
      print(response);

      return "";
    } catch (error) {
      return "Documents not submitted, Please try again";
    }
  }

  void _submitKYC() async {
    Map kycData;
    Map responseCkyc;
    if (manual) {
      responseCkyc = {};
      if (_formKey.currentState!.validate()) {
        if (selectedCategories['pan_form60'] != null) {
          if (ckycDocuments['pan_form60']!.every((dat) => dat == '')) {
            _showAlertDialog(
                context, "Please Upload ${selectedCategories['pan_form60']}");

            return;
          }
        }
        if (selectedCategories['id_proof'] != null) {
          if (ckycDocuments['id_proof']!.every((dat) => dat == '')) {
            _showAlertDialog(
                context, "Please Upload Document For Proof of Identity");
            return;
          }
        }
        if (selectedCategories['address_proof'] != null) {
          if (ckycDocuments['address_proof']!.every((dat) => dat == '')) {
            _showAlertDialog(
                context, "Please Upload Document For Proof of Address");
            return;
          }
        }

        kycData = {
          "ckyc_exist": _kycAvailable == 'Yes' ? 'Y' : 'N',
          "ckyc_num":
              ckycIDController.text == '' ? null : ckycIDController.text,
          "pan_avail": _panAvailable == 'Yes' ? '1' : '0',
          "cin_avail": _cinAvailable == 'Yes' ? '1' : '0',
          "customer_type": "Other",
          "pan_num":
              panNumberController.text == '' ? null : panNumberController.text,
          "doc_addr_proof_number": addressProofController.text,
          "cin":
              companyIDController.text == '' ? null : companyIDController.text,
          "doc_id_proof_type_selected": documentIds['id_proof'],
          "doc_addr_proof_type_selected": documentIds['address_proof'],
          "doc_pan_form60_type_selected": documentIds['pan_form60'],
          "ckyc_entity_type_id": entityID,
          "dob": DateFormat("yyyy-MM-dd")
              .format(DateFormat("dd-MM-yyyy").parse(incorporationDate)),
          ...responseCkyc
        };
        var formData = FormData();

        for (var i = 0; i < ckycDocuments['pan_form60']!.length; i++) {
          if (ckycDocuments['pan_form60']![i] != '') {
            var fileExtension =
                ckycDocuments['pan_form60']![i].path.split('.').last;
            formData.files.add(MapEntry(
                'files',
                await MultipartFile.fromFile(
                    ckycDocuments['pan_form60']![i].path,
                    filename:
                        '${documentIds['pan_form60']}_page${i + 1}.$fileExtension')));
          }
        }
        for (var i = 0; i < ckycDocuments['id_proof']!.length; i++) {
          if (ckycDocuments['id_proof']![i] != '') {
            var fileExtension =
                ckycDocuments['id_proof']![i].path.split('.').last;
            formData.files.add(MapEntry(
                'files',
                await MultipartFile.fromFile(ckycDocuments['id_proof']![i].path,
                    filename:
                        '${documentIds['id_proof']}_page${i + 1}.$fileExtension')));
          }
        }
        for (var i = 0; i < ckycDocuments['address_proof']!.length; i++) {
          if (ckycDocuments['address_proof']![i] != '') {
            var fileExtension =
                ckycDocuments['address_proof']![i].path.split('.').last;
            formData.files.add(MapEntry(
                'files',
                await MultipartFile.fromFile(
                    ckycDocuments['address_proof']![i].path,
                    filename:
                        '${documentIds['address_proof']}_page${i + 1}.$fileExtension')));
          }
        }
        if (checkKYC == false) {
          sendCkyc(kycData, formData, context);
        } else {
          editCkyc(kycData, formData, context);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: const Text("Please fill out all the form fields"),
            action: SnackBarAction(
              label: ' Cancel',
              onPressed: () {},
            )));
      }
    } else {
      kycData = {
        "ckyc_exist": _kycAvailable == 'Yes' ? 'Y' : 'N',
        "ckyc_num": ckycIDController.text == '' ? null : ckycIDController.text,
        "pan_avail": _panAvailable == 'Yes' ? '1' : '0',
        "cin_avail": _cinAvailable == 'Yes' ? '1' : '0',
        "customer_type": "Other",
        "pan_num":
            panNumberController.text == '' ? null : panNumberController.text,
        "doc_addr_proof_number": addressProofController.text,
        "cin": companyIDController.text == '' ? null : companyIDController.text,
        "doc_id_proof_type_selected": documentIds['id_proof'],
        "doc_addr_proof_type_selected": documentIds['address_proof'],
        "doc_pan_form60_type_selected": documentIds['pan_form60'],
        "ckyc_entity_type_id": entityID,
        "dob": DateFormat("yyyy-MM-dd")
            .format(DateFormat("dd-MM-yyyy").parse(incorporationDate)),
        "response_ckyc_num": ckycData['CKYCNumber'],
        "response_ckyc_dob": DateFormat("yyyy-MM-dd")
            .format(DateFormat("dd-MMM-yyyy").parse(ckycData['CKYCDOB'])),
        "response_ckyc_customer_name": ckycData['CKYCFullName'],
      };
      FormData formData = FormData();

      if (checkKYC == false) {
        sendCkyc(kycData, formData, context);
      } else {
        editCkyc(kycData, formData, context);
      }
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
              color: const Color.fromRGBO(176, 34, 204, 1),
            ),
            title: GradientText('KYC Module',
                colors: const [
                  Color.fromRGBO(176, 34, 204, 1),
                  Color.fromRGBO(13, 154, 189, 1),
                ],
                gradientType: GradientType.linear,
                gradientDirection: GradientDirection.ltr,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                )),
            centerTitle: false,
            flexibleSpace: Container(
              decoration: const BoxDecoration(color: Colors.white),
            ),
            shadowColor: Colors.grey,
            elevation: 7,
          ),
          body: Form(
            key: _formKey,
            child: Container(
              padding: const EdgeInsets.all(15),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    CustomInputContainer(
                      children: [
                        _heightGap(),
                        Wrap(
                          spacing: 20,
                          runSpacing: 15,
                          alignment: WrapAlignment.start,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            const SizedBox(
                              width: 320,
                              child: Wrap(spacing: 2, children: [
                                Text(
                                  'CKYC Available?* ',
                                  maxLines: 5,
                                  style: TextStyle(
                                      color: Color.fromRGBO(143, 19, 168, 1),
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  '(W.e.f 01st January 2023, CKYC ID creation is mandatory for all the policies at the time of Inception of risk for both Individual and Organization Customers) ',
                                  maxLines: 6,
                                  style: TextStyle(
                                    color: Color.fromRGBO(143, 19, 168, 1),
                                    fontSize: 11,
                                  ),
                                ),
                              ]),
                            ),
                            SizedBox(
                              width: 350,
                              child: Row(
                                children: [
                                  Radio(
                                      activeColor:
                                          const Color.fromRGBO(143, 19, 168, 1),
                                      autofocus: false,
                                      value: 'Yes',
                                      groupValue: _kycAvailable,
                                      onChanged: onChanged),
                                  const Text('Yes'),
                                  Radio(
                                      activeColor:
                                          const Color.fromRGBO(143, 19, 168, 1),
                                      autofocus: false,
                                      value: 'No',
                                      groupValue: _kycAvailable,
                                      onChanged: onChanged2),
                                  const Text('No'),
                                ],
                              ),
                            ),
                            kyc
                                ? CustomInputField2(
                                    enable: enableCKYC,
                                    controller: ckycIDController,
                                    inputFormatters: <TextInputFormatter>[
                                      FilteringTextInputFormatter.digitsOnly
                                    ],
                                    maxLength: 14,
                                    title: 'CKYC ID',
                                    hintText: 'Enter CKYC ID',
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return 'Please Enter the CKYC ID';
                                      } else if (int.parse(value) == 0) {
                                        return 'Please Enter valid CKYC';
                                      } else if (value.length < 14) {
                                        return 'Please Enter 14-Digit CKYC ID';
                                      }
                                      final singleDigitRegex = RegExp(
                                          r'^(?!.*(0{14}|1{14}|2{14}|3{14}|4{14}|5{14}|6{14}|7{14}|8{14}|9{14})).*$');
                                      if (!singleDigitRegex.hasMatch(value)) {
                                        return 'Please Enter valid CKYC';
                                      }
                                      return null;
                                    },
                                  )
                                : const SizedBox.shrink(),
                          ],
                        ),
                        _heightGap(),
                        _heightGap(),
                        DatePickerFormField(
                          disabled: disable,
                          labelText: 'Date of Incorporation',
                          onChanged: (DateTime? value) {
                            setState(() {
                              incorporationDate = DateFormat('dd-MM-yyyy')
                                  .format(value as DateTime);
                            });
                            print('Selected date: $value');
                          },
                          date: incorporationDate,
                        ),
                        _heightGap(),
                      ],
                    ),
                    _heightGap(),
                    fetchKyc
                        ? Container(
                            decoration: const BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                              color: Color.fromRGBO(143, 19, 168, 1),
                            ),
                            child: TextButton(
                                onPressed: () {
                                  print('done');
                                  if (_kycAvailable != null &&
                                      _formKey.currentState!.validate()) {
                                    setState(() {
                                      inputType = 'Z';
                                      inputNo = ckycIDController.text;
                                      option = 'PAN Number';
                                    });
                                    fetchCKYC();
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              'Please enter valid details!')),
                                    );
                                  }
                                },
                                child: const Text(
                                  'Fetch CKYC Details',
                                  style: TextStyle(color: Colors.white),
                                )),
                          )
                        : const SizedBox.shrink(),
                    _heightGap(),
                    isPan
                        ? CustomInputContainer(
                            children: [
                              Wrap(
                                  spacing: 20,
                                  runSpacing: 15,
                                  alignment: WrapAlignment.start,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    _customRadio('Do you have PAN?',
                                        _panAvailable, onChanged3),
                                    pan
                                        ? CustomInputField2(
                                            enable: enablePan,
                                            maxLength: 10,
                                            inputFormatters: <TextInputFormatter>[
                                              FilteringTextInputFormatter.allow(
                                                  RegExp("[0-9a-zA-Z]")),
                                            ],
                                            controller: panNumberController,
                                            title: 'PAN Number',
                                            hintText: 'Enter PAN Number',
                                            onChanged: (value) {
                                              panNumberController.value =
                                                  TextEditingValue(
                                                      text: value.toUpperCase(),
                                                      selection:
                                                          panNumberController
                                                              .selection);
                                            },
                                            validator: (value) {
                                              if (value == null ||
                                                  value.isEmpty) {
                                                return 'Please Enter PAN Number';
                                              }

                                              final alphanumericRegex = RegExp(
                                                  r'^[A-Z]{5}[0-9]{4}[A-Z]$');
                                              if (!alphanumericRegex
                                                  .hasMatch(value)) {
                                                return 'Please Enter Valid PAN Number';
                                              }

                                              if (value == '0') {
                                                return 'Please Enter Valid PAN Number’ ';
                                              }

                                              return null;
                                            },
                                          )
                                        : const SizedBox.shrink(),
                                  ]),
                              _heightGap()
                            ],
                          )
                        : const SizedBox.shrink(),
                    _heightGap(),
                    fetchPan
                        ? Container(
                            decoration: const BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                              color: Color.fromRGBO(143, 19, 168, 1),
                            ),
                            child: TextButton(
                                onPressed: () {
                                  print('done');
                                  if (_panAvailable != null &&
                                      _formKey.currentState!.validate()) {
                                    setState(() {
                                      inputType = 'C';
                                      inputNo = panNumberController.text;
                                      option = 'Company ID Number';
                                    });
                                    fetchCKYC();
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              'Please enter valid details!')),
                                    );
                                  }
                                },
                                child: const Text(
                                  'Fetch CKYC Details',
                                  style: TextStyle(color: Colors.white),
                                )),
                          )
                        : const SizedBox.shrink(),
                    isCIN
                        ? CustomInputContainer(
                            children: [
                              Wrap(
                                  spacing: 20,
                                  runSpacing: 15,
                                  alignment: WrapAlignment.start,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    _customRadio(
                                        'Do you have Company ID Number?',
                                        _cinAvailable,
                                        onChanged4),
                                    cin
                                        ? CustomInputField2(
                                            enable: enableCIN,
                                            maxLength: 21,
                                            controller: companyIDController,
                                            title: 'CIN',
                                            hintText: 'Enter CIN',
                                            validator: (value) {
                                              final alphanumeric =
                                                  RegExp(r'^[a-zA-Z0-9]+$');
                                              if (value!.isEmpty) {
                                                return 'Please Enter the CIN';
                                              } else if (value.length != 21) {
                                                return 'Please Enter 21-Digit CIN';
                                              } else if (!alphanumeric
                                                  .hasMatch(value)) {
                                                return 'Only alphanumeric characters are allowed';
                                              }
                                              return null;
                                            },
                                          )
                                        : const SizedBox.shrink(),
                                  ]),
                              _heightGap()
                            ],
                          )
                        : const SizedBox.shrink(),
                    _heightGap(),
                    fetchCIN
                        ? Container(
                            decoration: const BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                              color: Color.fromRGBO(143, 19, 168, 1),
                            ),
                            child: TextButton(
                                onPressed: () {
                                  print('done');
                                  if (_panAvailable != null &&
                                      _formKey.currentState!.validate()) {
                                    setState(() {
                                      inputType = '02';
                                      inputNo = companyIDController.text;
                                      option = 'Document Upload';
                                    });
                                    fetchCKYC();
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              'Please enter valid details!')),
                                    );
                                  }
                                },
                                child: const Text(
                                  'Fetch CKYC Details',
                                  style: TextStyle(color: Colors.white),
                                )),
                          )
                        : const SizedBox.shrink(),
                    manual
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _customDropDown(
                                  'Entity Type:', 'Select Entity Type',
                                  (value) {
                                setState(() {
                                  selectedCategories = {
                                    "pan_form60": null,
                                    "id_proof": null,
                                    "address_proof": null,
                                  };
                                  ckycDocuments = {
                                    "pan_form60": [''],
                                    "id_proof": [''],
                                    "address_proof": ['']
                                  };
                                  selectedValue = value;
                                  print(selectedValue);
                                  var id = ckycEntities
                                      .where((d) => d['entity_type'] == value)
                                      .first['id'];
                                  getCategoryDropdowns(id);
                                  entityID = id;
                                  print(entityID);
                                });
                              }, entity, selectedValue),
                              _heightGap(),
                              entityDropdownData.isNotEmpty
                                  ? Wrap(
                                      spacing: 20,
                                      runSpacing: 15,
                                      alignment: WrapAlignment.start,
                                      crossAxisAlignment:
                                          WrapCrossAlignment.center,
                                      // crossAxisAlignment:
                                      //     CrossAxisAlignment.start,
                                      children: [
                                        _customDropDown('Select Documents',
                                            'Select Documents',
                                            (String? newValue) {
                                          setState(() {
                                            ckycDocuments['pan_form60'] = [''];
                                            selectedCategories['pan_form60'] =
                                                newValue;
                                            var indexDocumentType =
                                                List<String>.from(
                                                        entityDropdownData[0]
                                                            ['sub_categories'])
                                                    .indexOf(newValue!);
                                            if (indexDocumentType != -1) {
                                              documentIds['pan_form60'] =
                                                  entityDropdownData[0]
                                                          ["documentIds"]
                                                      [indexDocumentType];
                                            }
                                          });
                                        },
                                            List<String>.from(
                                                entityDropdownData[0]
                                                    ['sub_categories']),
                                            selectedCategories['pan_form60']),
                                        _heightGap(),
                                        ckycDocuments['pan_form60']!.length <
                                                    2 &&
                                                selectedCategories[
                                                        'pan_form60'] !=
                                                    null
                                            ? Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                children: [
                                                  widget.isView == false
                                                      ? TextButton(
                                                          onPressed: () {
                                                            setState(() {
                                                              ckycDocuments[
                                                                      'pan_form60']!
                                                                  .add('');
                                                              if (widget
                                                                  .isEdit) {
                                                                edittedDocuments[
                                                                        'pan_form60']!
                                                                    .add('');
                                                                oldFileNames[
                                                                        'pan_form60']!
                                                                    .add(null);
                                                              }
                                                            });
                                                          },
                                                          child: const Text(
                                                            '+',
                                                            style: TextStyle(
                                                                color: Color
                                                                    .fromRGBO(
                                                                        11,
                                                                        133,
                                                                        163,
                                                                        1),
                                                                fontSize: 20,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          ),
                                                        )
                                                      : const SizedBox.shrink(),
                                                ],
                                              )
                                            : const SizedBox.shrink(),
                                        selectedCategories['pan_form60'] != null
                                            ? Wrap(
                                                spacing: 20,
                                                runSpacing: 15,
                                                alignment: WrapAlignment.center,
                                                runAlignment:
                                                    WrapAlignment.center,
                                                children: [
                                                  ...List.generate(
                                                      ckycDocuments[
                                                              'pan_form60']!
                                                          .length, (index) {
                                                    return _uploadDocument(
                                                        'pan_form60', index);
                                                  }),
                                                ],
                                              )
                                            : const SizedBox.shrink(),
                                        _heightGap(),
                                        _customDropDown('Proof of Identity',
                                            'Select Proof of Identity',
                                            (String? newValue) {
                                          setState(() {
                                            ckycDocuments["address_proof"] = [
                                              ''
                                            ];
                                            addressProofController.text == '';
                                            selectedCategories[
                                                'address_proof'] = null;
                                            ckycDocuments['id_proof'] = [''];
                                            selectedCategories['id_proof'] =
                                                newValue;
                                            var indexDocumentType =
                                                List<String>.from(
                                                        entityDropdownData[2]
                                                            ['sub_categories'])
                                                    .indexOf(newValue!);
                                            if (indexDocumentType != -1) {
                                              documentIds['id_proof'] =
                                                  entityDropdownData[2]
                                                          ["documentIds"]
                                                      [indexDocumentType];
                                            }
                                          });
                                        },
                                            List<String>.from(
                                                entityDropdownData[2]
                                                    ['sub_categories']),
                                            selectedCategories['id_proof']),
                                        _heightGap(),
                                        selectedCategories['id_proof'] != null
                                            ? Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  entityInputs(
                                                      selectedCategories[
                                                          'id_proof']),
                                                  _heightGap(),
                                                  ckycDocuments['id_proof']!
                                                                  .length <
                                                              8 &&
                                                          selectedCategories[
                                                                  'id_proof'] !=
                                                              null
                                                      ? Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .end,
                                                          children: [
                                                            widget.isView ==
                                                                    false
                                                                ? TextButton(
                                                                    onPressed:
                                                                        () {
                                                                      setState(
                                                                          () {
                                                                        ckycDocuments['id_proof']!
                                                                            .add('');
                                                                        if (widget
                                                                            .isEdit) {
                                                                          edittedDocuments['id_proof']!
                                                                              .add('');
                                                                          oldFileNames['id_proof']!
                                                                              .add(null);
                                                                        }
                                                                      });
                                                                    },
                                                                    child:
                                                                        const Text(
                                                                      '+',
                                                                      style: TextStyle(
                                                                          color: Color.fromRGBO(
                                                                              11,
                                                                              133,
                                                                              163,
                                                                              1),
                                                                          fontSize:
                                                                              20,
                                                                          fontWeight:
                                                                              FontWeight.bold),
                                                                    ),
                                                                  )
                                                                : const SizedBox
                                                                    .shrink(),
                                                          ],
                                                        )
                                                      : const SizedBox.shrink(),
                                                  _heightGap(),
                                                  Wrap(
                                                    spacing: 20,
                                                    runSpacing: 15,
                                                    alignment:
                                                        WrapAlignment.start,
                                                    children: [
                                                      ...List.generate(
                                                          ckycDocuments[
                                                                  'id_proof']!
                                                              .length, (index) {
                                                        return _uploadDocument(
                                                            'id_proof', index);
                                                      }),
                                                    ],
                                                  ),
                                                ],
                                              )
                                            : const SizedBox.shrink(),
                                        _heightGap(),
                                        selectedCategories['id_proof'] !=
                                                    null &&
                                                rejectionList.contains(
                                                        selectedCategories[
                                                            'id_proof']) ==
                                                    false
                                            ? Column(
                                                children: [
                                                  _customDropDown(
                                                      'Proof of Address',
                                                      'Select Proof of Address',
                                                      (String? newValue) {
                                                    setState(() {
                                                      ckycDocuments[
                                                          'address_proof'] = [
                                                        ''
                                                      ];
                                                      selectedCategories[
                                                              'address_proof'] =
                                                          newValue;
                                                      var indexDocumentType = List<
                                                                  String>.from(
                                                              entityDropdownData[
                                                                      1][
                                                                  'sub_categories'])
                                                          .indexOf(newValue!);
                                                      if (indexDocumentType !=
                                                          -1) {
                                                        documentIds[
                                                                'address_proof'] =
                                                            entityDropdownData[
                                                                        1][
                                                                    "documentIds"]
                                                                [
                                                                indexDocumentType];
                                                        print(documentIds);
                                                      }
                                                    });
                                                  },
                                                      List<String>.from(
                                                          entityDropdownData[1][
                                                              'sub_categories']),
                                                      selectedCategories[
                                                          'address_proof']),
                                                  _heightGap(),
                                                  selectedCategories[
                                                              'address_proof'] !=
                                                          null
                                                      ? Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            entityInputs(
                                                                selectedCategories[
                                                                    'address_proof']),
                                                            _heightGap(),
                                                            ckycDocuments['address_proof']!
                                                                            .length <
                                                                        8 &&
                                                                    selectedCategories[
                                                                            'address_proof'] !=
                                                                        null
                                                                ? Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .end,
                                                                    children: [
                                                                      widget.isView ==
                                                                              false
                                                                          ? TextButton(
                                                                              onPressed: () {
                                                                                setState(() {
                                                                                  ckycDocuments['address_proof']!.add('');
                                                                                  if (widget.isEdit) {
                                                                                    edittedDocuments['address_proof']!.add('');
                                                                                    oldFileNames['address_proof']!.add(null);
                                                                                  }
                                                                                });
                                                                              },
                                                                              child: const Text(
                                                                                '+',
                                                                                style: TextStyle(color: Color.fromRGBO(11, 133, 163, 1), fontSize: 20, fontWeight: FontWeight.bold),
                                                                              ),
                                                                            )
                                                                          : const SizedBox
                                                                              .shrink(),
                                                                    ],
                                                                  )
                                                                : const SizedBox
                                                                    .shrink(),
                                                            _heightGap(),
                                                            Wrap(
                                                              spacing: 20,
                                                              runSpacing: 15,
                                                              alignment:
                                                                  WrapAlignment
                                                                      .start,
                                                              runAlignment:
                                                                  WrapAlignment
                                                                      .center,
                                                              children: [
                                                                ...List.generate(
                                                                    ckycDocuments[
                                                                            'address_proof']!
                                                                        .length,
                                                                    (index) {
                                                                  return _uploadDocument(
                                                                      'address_proof',
                                                                      index);
                                                                }),
                                                              ],
                                                            ),
                                                          ],
                                                        )
                                                      : const SizedBox.shrink(),
                                                ],
                                              )
                                            : const SizedBox.shrink(),
                                        _heightGap(),
                                      ],
                                    )
                                  : const SizedBox.shrink(),
                              //     for (var category in entityDropdownData)
                              //       Column(
                              //         crossAxisAlignment: CrossAxisAlignment.start,
                              //         children: [
                              //           _customDropDown(
                              //               labelling[
                              //                   category['category'].toString()],
                              //               'Select ${labelling[category['category'].toString()]}',
                              //               (String? newValue) {
                              //             setState(() {
                              //               selectedCategories[
                              //                   category['category']] = newValue;
                              //             });
                              //           },
                              //               List<String>.from(
                              //                   category['sub_categories']),
                              //               selectedCategories[
                              //                   category['category']]),
                              //           _heightGap(),
                              //           Wrap(
                              //             spacing: 20,
                              // runSpacing: 15,
                              //             children: List.generate(
                              //     ckycDocuments[category['category'].toString()]!.length, (index) {
                              //   return _uploadDocument(category['category'].toString(), index);
                              // }),
                              //           ),
                              //           _heightGap(),
                              //         ],
                              //       ),

                              // Column(
                              //   crossAxisAlignment: CrossAxisAlignment.start,
                              //   children: [
                              //     SizedBox(height: 10),
                              //     Text(
                              //       category['category'].toString(),
                              //       style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              //     ),
                              //     SizedBox(height: 5),
                              //     DropdownButtonFormField<String>(
                              //       value: selectedCategories[category['category']],
                              //       items: (category['sub_categories'] as List<String>).map((String value) {
                              //         return DropdownMenuItem<String>(
                              //           value: value,
                              //           child: Text(value),
                              //         );
                              //       }).toList(),
                              //       onChanged: (String? newValue) {
                              //         setState(() {
                              //           selectedCategories[category['category']] = newValue;
                              //         });
                              //       },
                              //       decoration: InputDecoration(
                              //         labelText: 'Select ${category['category']}',
                              //         border: OutlineInputBorder(),
                              //       ),
                              //     ),
                              //   ],
                              // ),
                              // selectedValue == 'Liquidator'
                              //     ? _panUpload()
                              //     : SizedBox.shrink(),
                              // selectedValue == 'Sole Proprietorship'
                              //     ? _identity1()
                              //     : SizedBox.shrink(),
                              // selectedValue == 'Partnership Firm' ||
                              //         selectedValue ==
                              //             'Limited Liability Partnership' ||
                              //         selectedValue ==
                              //             'Artificial Liability Partnership'
                              //     ? _identity(identity2)
                              //     : SizedBox.shrink(),
                              // selectedValue == 'HUF' ||
                              //         selectedValue == 'Association of Persons'
                              //     ? _identity(identity3)
                              //     : SizedBox.shrink(),
                              // selectedValue == 'Private Limited Company' ||
                              //         selectedValue ==
                              //             'Public Limited Company' ||
                              //         selectedValue == 'Section 8 Companies'
                              //     ? _identity(identity4)
                              //     : SizedBox.shrink(),
                              // selectedValue == 'Society'
                              //     ? _identity(identity5)
                              //     : SizedBox.shrink(),
                              // selectedValue == 'Trust'
                              //     ? _identity(identity6)
                              //     : SizedBox.shrink(),
                              // selectedValue == 'Public Sector Banks' ||
                              //         selectedValue ==
                              //             'Artificial Jurisdical Person'
                              //     ? _identity(identity7)
                              //     : SizedBox.shrink(),
                              // selectedIdentity == 'Activity Proof-1' ||
                              //         selectedIdentity == 'Activity Proof-2'
                              //     ? _activityProof()
                              //     : SizedBox.shrink(),
                              // selectedIdentity ==
                              //             'OVD in respect of person authorized to transact' ||
                              //         selectedIdentity ==
                              //             'Power of Atterney granted to Manager' ||
                              //         selectedIdentity == 'Partnership Deed'
                              //     ? _identityDocuments()
                              //     : SizedBox.shrink(),
                              // selectedIdentity == 'Registration Certificate'
                              //     ? _registrationCertificate()
                              //     : SizedBox.shrink(),
                              // selectedIdentity ==
                              //         'Certificate of Incorporation/Formation'
                              //     ? _certificate()
                              //     : SizedBox.shrink(),
                              _heightGap(),
                              Container(
                                decoration: const BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                  color: Color.fromRGBO(11, 133, 163, 1),
                                ),
                                child: TextButton(
                                    onPressed: () {
                                      if (widget.isView) {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    ProposalDocuments(
                                                        inwardData: {
                                                          "product": productName
                                                        },
                                                        inwardType:
                                                            widget.inwardType,
                                                        isView: widget.isView,
                                                        isEdit: widget.isEdit,
                                                        ckycData: null,
                                                        ckycDocuments: null)));
                                      } else {
                                        _submitKYC();
                                      }
                                    },
                                    child: Text(
                                      widget.isView ? 'Next' : 'Submit CKYC',
                                      style:
                                          const TextStyle(color: Colors.white),
                                    )),
                              )
                            ],
                          )
                        : const SizedBox.shrink(),
                    _heightGap(),
                    _heightGap(),
                    isFetched
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              _heightGap(),
                              _heightGap(),
                              _heightGap(),
                              Container(
                                width: double.infinity,
                                padding:
                                    const EdgeInsets.only(left: 15, right: 15),
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        color: const Color.fromRGBO(
                                            11, 133, 163, 1),
                                        width: 2),
                                    borderRadius: BorderRadius.circular(10)),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _heightGap(),
                                    _text(
                                        'Customer Name:  ${ckycData['CKYCFullName']}'),
                                    _heightGap(),
                                    _text(
                                        'CKYC ID: ${ckycData['CKYCNumber'].toString()}'),
                                    _heightGap(),
                                    widget.isView == true
                                        ? _text('DOI: ${ckycData['CKYCDOB']}')
                                        : _text(
                                            'DOI: ${DateFormat("yyyy-MM-dd").format(DateFormat("dd-MMM-yyyy").parse(ckycData['CKYCDOB']))}'),
                                    _heightGap(),
                                  ],
                                ),
                              ),
                              _heightGap(),
                              isSubmitted
                                  ? Container(
                                      decoration: const BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10)),
                                        color: Color.fromRGBO(11, 133, 163, 1),
                                      ),
                                      child: TextButton(
                                          onPressed: () {
                                            if (widget.isView) {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          ProposalDocuments(
                                                              isView:
                                                                  widget.isView,
                                                              isEdit:
                                                                  widget.isEdit,
                                                              inwardData: widget
                                                                  .inwardData,
                                                              inwardType: widget
                                                                  .inwardType,
                                                              ckycData: null,
                                                              ckycDocuments:
                                                                  null)));
                                            } else {
                                              _submitKYC();
                                            }
                                          },
                                          child: Text(
                                            widget.isView
                                                ? 'Next'
                                                : 'Submit CKYC',
                                            style: const TextStyle(
                                                color: Colors.white),
                                          )),
                                    )
                                  : Container()
                            ],
                          )
                        : const SizedBox.shrink(),
                  ],
                ),
              ),
            ),
          ),
        ),
        noKYC
            ? Positioned(
                top: 0,
                right: 0,
                left: 0,
                bottom: 0,
                child: Stack(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      decoration: const BoxDecoration(color: Colors.black38),
                    ),
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        width: MediaQuery.of(context).size.width * 0.8,
                        height: MediaQuery.of(context).size.height * 0.25,
                        // margin: const EdgeInsets.fromLTRB(30, 300, 30, 300),
                        decoration: BoxDecoration(
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
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Alert!',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                      decoration: TextDecoration.none,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black)),
                              _heightGap(),
                              Text(
                                  'CKYC Information is unavailable/not fetched using entered details.Please try with ${option} option.',
                                  maxLines: 5,
                                  style: const TextStyle(
                                      fontSize: 13,
                                      decoration: TextDecoration.none,
                                      // fontWeight: FontWeight.w600,
                                      color: Colors.black54)),
                              _heightGap(),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton(
                                      onPressed: () {
                                        setState(() {
                                          noKYC = false;
                                          if (_cinAvailable == 'Yes') {
                                            setState(() {
                                              _cinAvailable = 'Yes';
                                              if (_kycAvailable == 'Yes') {
                                                kyc = true;
                                                fetchKyc = false;
                                              } else {
                                                kyc = false;
                                              }
                                              fetchKyc = false;
                                              if (_panAvailable == 'Yes') {
                                                isPan = true;
                                                pan = true;
                                                fetchPan = false;
                                              } else {
                                                isPan = false;
                                                pan = false;
                                              }

                                              fetchPan = false;
                                              isCIN = true;
                                              cin = true;
                                              fetchCIN = true;
                                              manual = false;
                                            });
                                          } else if (_panAvailable == 'Yes') {
                                            print('next aadhar');
                                            setState(() {
                                              if (_kycAvailable == 'Yes') {
                                                kyc = true;
                                                fetchKyc = false;
                                              } else {
                                                kyc = false;
                                              }
                                              fetchKyc = false;
                                              _panAvailable = 'Yes';
                                              isPan = true;
                                              pan = true;
                                              fetchPan = true;
                                              isCIN = false;
                                              cin = false;
                                              fetchCIN = false;
                                              manual = false;
                                            });
                                          } else if (_kycAvailable == 'Yes') {
                                            setState(() {
                                              kyc = true;
                                              fetchKyc = true;
                                              isPan = false;
                                              pan = false;
                                              fetchPan = false;
                                              isCIN = false;
                                              fetchCIN = false;
                                              cin = false;
                                              manual = false;
                                            });
                                          }
                                        });
                                      },
                                      child: const Text('EDIT',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            color:
                                                Color.fromRGBO(15, 5, 158, 1),
                                          ))),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  TextButton(
                                      onPressed: () {
                                        // getVersion();
                                        setState(() {
                                          noKYC = false;
                                        });
                                        if (_cinAvailable == 'Yes') {
                                          setState(() {
                                            onChanged = null;
                                            onChanged2 = null;
                                            onChanged3 = null;
                                            onChanged4 = null;
                                            disable = true;
                                            enableCKYC = true;
                                            enablePan = true;
                                            enableCIN = true;
                                            if (_kycAvailable == 'Yes') {
                                              kyc = true;
                                              fetchKyc = false;
                                            }
                                            fetchKyc = false;
                                            if (_panAvailable == 'Yes') {
                                              isPan = true;
                                              pan = true;
                                              fetchPan = false;
                                            }
                                            fetchPan = false;

                                            isCIN = true;
                                            cin = true;
                                            fetchCIN = false;
                                            manual = true;
                                          });
                                        } else if (_panAvailable == 'Yes') {
                                          print('next aadhar');
                                          setState(() {
                                            if (_kycAvailable == 'Yes') {
                                              kyc = true;
                                              fetchKyc = false;
                                              disable = true;
                                              enableCKYC = true;
                                            } else {
                                              kyc = false;
                                            }
                                            onChanged = null;
                                            onChanged2 = null;
                                            onChanged3 = null;
                                            enablePan = true;
                                            fetchKyc = false;
                                            isPan = true;
                                            pan = true;
                                            fetchPan = false;
                                            _cinAvailable = 'Yes';
                                            isCIN = true;
                                            cin = true;
                                            fetchCIN = true;
                                            manual = false;
                                          });
                                        } else if (_kycAvailable == 'Yes') {
                                          setState(() {
                                            kyc = true;
                                            fetchKyc = false;
                                            onChanged = null;
                                            onChanged2 = null;
                                            disable = true;
                                            enableCKYC = true;
                                            _panAvailable = 'Yes';
                                            isPan = true;
                                            pan = true;
                                            fetchPan = true;
                                            isCIN = false;
                                            fetchCIN = false;
                                            cin = false;
                                            manual = false;
                                          });
                                        }
                                      },
                                      child: const Text('NEXT',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            color:
                                                Color.fromRGBO(15, 5, 158, 1),
                                          ))),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                ],
                              )
                            ]),
                      ),
                    ),
                  ],
                ),
              )
            : const SizedBox.shrink(),
        editKYC
            ? Positioned(
                top: 0,
                right: 0,
                left: 0,
                bottom: 0,
                child: Stack(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      decoration: const BoxDecoration(color: Colors.black38),
                    ),
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        width: MediaQuery.of(context).size.width * 0.8,
                        height: MediaQuery.of(context).size.height * 0.25,
                        // margin: const EdgeInsets.fromLTRB(30, 300, 30, 300),
                        decoration: BoxDecoration(
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
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Alert!',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                      decoration: TextDecoration.none,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black)),
                              _heightGap(),
                              const Text(
                                  'Do you want to edit CKYC Information ?',
                                  maxLines: 5,
                                  style: TextStyle(
                                      fontSize: 13,
                                      decoration: TextDecoration.none,
                                      // fontWeight: FontWeight.w600,
                                      color: Colors.black54)),
                              _heightGap(),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton(
                                      onPressed: () {
                                        Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    ProposalDocuments(
                                                      inwardData:
                                                          widget.inwardData,
                                                      inwardType:
                                                          widget.inwardType,
                                                      ckycData: null,
                                                      ckycDocuments: null,
                                                      isEdit: widget.isEdit,
                                                      isView: widget.isView,
                                                    )));
                                      },
                                      child: const Text('No',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            color:
                                                Color.fromRGBO(15, 5, 158, 1),
                                          ))),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  TextButton(
                                      onPressed: () {
                                        setState(() {
                                          // getVersion();
                                          _kycAvailable = null;
                                          resetVariable();
                                          editKYC = false;
                                          // edit = true;
                                        });
                                      },
                                      child: const Text('Yes',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            color:
                                                Color.fromRGBO(15, 5, 158, 1),
                                          ))),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                ],
                              )
                            ]),
                      ),
                    ),
                  ],
                ),
              )
            : const SizedBox.shrink(),
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

  entityInputs(String? type) {
    List inputsAllowed = [
      'Registration Certificate',
      'Certificate of Incorporation/Formation',
      'Others'
    ];

    if (inputsAllowed.contains(type)) {
      if (type == 'Registration Certificate') {
        return CustomInputField2(
            enable: enable2,
            controller: addressProofController,
            // inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            title: 'Registration Certificate',
            hintText: 'Enter Registration Certificate',
            validator: (value) {
              RegExp regExp = RegExp(r'^[a-zA-Z0-9(){}\[\]\\]+$');

              if (value == null || value.isEmpty) {
                return 'Registration number is required';
              } else if (!regExp.hasMatch(value)) {
                return 'Invalid Registration number';
              }
              return null;
            });
      } else if (type == 'Certificate of Incorporation/Formation') {
        return CustomInputField2(
          enable: enable2,
          controller: addressProofController,
          title: 'Company Id Number',
          hintText: 'Enter Company Id Number',
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Company Id Number is required';
            }
            RegExp regExp = RegExp(r'^[a-zA-Z0-9]{21}$');
            if (!regExp.hasMatch(value)) {
              return 'Must be exactly 21 alphanumeric characters';
            }
            return null;
          },
        );
      } else {
        return CustomInputField2(
          enable: enable2,
          controller: addressProofController,
          title: 'Other document name',
          hintText: 'Enter Other document name',
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Other document name is required';
            }
            return null;
          },
        );
      }
    } else {
      return Container();
    }
  }

  _identity(identity) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _panUpload(),
        _customDropDown('Proof of Identity:', 'Select option', (value) {
          setState(() {
            print('set hua');
            selectedIdentity = value;
            print(selectedIdentity);
          });
        }, identity, selectedIdentity),
        _heightGap(),
      ],
    );
  }

  _identity1() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _customDropDown('Select Documents:', 'Select option', (value) {
          setState(() {
            selectedDocument = value;
          });
        }, documents, selectedDocument),
        _heightGap(),
        selectedDocument == 'PAN Card' || selectedDocument == 'Form 60'
            ? _uploadDocument('identityProofDocuments', 0)
            : const SizedBox.shrink(),
        _heightGap(),
        _customDropDown('Proof of Identity:', 'Select option', (value) {
          setState(() {
            selectedIdentity = value;
          });
        }, identity1, selectedIdentity),
        _heightGap(),
      ],
    );
  }

  _identityDocuments() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _heightGap(),
        _uploadDocument('identityProofDocuments', 0),
        _heightGap(),
        _addressProof(address2)
      ],
    );
  }

  _registrationCertificate() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomInputField(
          title: 'Registration Certificate',
          hintText: 'Enter Registration Certificate',
          validator: (value) {
            if (value!.isEmpty) {
              return 'Please Enter the Registration Certificate';
            } else if (value == '0') {
              return 'Please Enter valid Registration Certificate';
            }
            return null;
          },
        ),
        _heightGap(),
        _uploadDocument('addressProofDocuments', 0)
      ],
    );
  }

  _certificate() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomInputField(
          title: 'Certificate of Incorporation/Formation',
          hintText: 'Enter Company ID Number',
          validator: (value) {
            if (value!.isEmpty) {
              return 'Please Enter the Company ID Number';
            } else if (int.parse(value) == 0) {
              return 'Please Enter valid Company ID Number';
            }
            return null;
          },
        ),
        _heightGap(),
        _uploadDocument('addressProofDocuments', 0)
      ],
    );
  }

  _activityProof() {
    return Column(
      children: [
        _uploadDocument('addressProofDocuments', 0),
        _addressProof(address1)
      ],
    );
  }

  _panUpload() {
    return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pan Upload',
            style: TextStyle(
                color: Color.fromRGBO(11, 133, 163, 1),
                fontSize: 13,
                fontWeight: FontWeight.bold),
          ),
          _heightGap(),
          _uploadDocument('entityDocuments', 0),
          _heightGap()
        ]);
  }

  _heightGap() {
    return const SizedBox(height: 10);
  }

  _customRadio(String label, mode, onChanged) {
    return Wrap(
        spacing: 20,
        runSpacing: 5,
        alignment: WrapAlignment.start,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          SizedBox(
            width: 320,
            height: 60,
            child: Text(
              label,
              style: const TextStyle(
                  color: Color.fromRGBO(143, 19, 168, 1),
                  fontSize: 13,
                  fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(
            width: 200,
            child: Row(
              children: [
                Radio(
                  activeColor: const Color.fromRGBO(143, 19, 168, 1),
                  value: 'Yes',
                  autofocus: false,
                  groupValue: mode,
                  onChanged: onChanged,
                ),
                const Text('Yes'),
                const SizedBox(
                  width: 50,
                ),
                Radio(
                  activeColor: const Color.fromRGBO(143, 19, 168, 1),
                  value: 'No',
                  autofocus: false,
                  groupValue: mode,
                  onChanged: onChanged,
                ),
                const Text('No'),
              ],
            ),
          ),
        ]);
  }

  _customDropDown(String label, String hint, onChanged, items, value) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
                color: Color.fromRGBO(143, 19, 168, 1),
                fontSize: 13,
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(
            height: 10,
          ),
          DropdownWidget(
            view: enable2,
            items: items,
            value: value,
            onChanged: onChanged,
            hintText: hint,
          )
        ]);
  }

  _addressProof(address) {
    return Column(
      children: [
        _heightGap(),
        _customDropDown('Proof of Address:', 'Select option', (value) {
          setState(() {
            selectedAddress = value;
          });
        }, address, selectedAddress),
        _heightGap(),
        selectedAddress == 'Registration Certificate'
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomInputField(
                    title: 'Registration Certificate',
                    hintText: 'Enter Registration Certificate',
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please Enter the Registration Certificate';
                      } else if (int.parse(value) == 0) {
                        return 'Please Enter valid Registration Certificate';
                      }
                      return null;
                    },
                  ),
                  _heightGap(),
                  _uploadDocument('addressProofDocuments', 0)
                ],
              )
            : const SizedBox.shrink(),
        selectedAddress == 'Others'
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomInputField(
                    title: 'Other Document',
                    hintText: 'Enter other Document Name',
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please Enter the Document Name';
                      } else if (int.parse(value) == 0) {
                        return 'Please Enter valid Document Name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  _uploadDocument('addressProofDocuments', 0)
                ],
              )
            : const SizedBox.shrink(),
        const SizedBox(
          height: 10,
        ),
      ],
    );
  }

  // _uploadDocument(String type, index) {
  //   return Stack(
  //     clipBehavior: Clip.none,
  //     children: [
  //       Container(
  //         height: 120.0,
  //         width: 140.0,
  //         decoration: BoxDecoration(
  //             borderRadius: BorderRadius.circular(6),
  //             border: Border.all(
  //                 color: const Color.fromRGBO(13, 154, 189, 1), width: 2)),
  //         child: galleryFile == null && _pdfFile == null
  //             ? Padding(
  //                 padding: const EdgeInsets.all(10),
  //                 child: ElevatedButton(
  //                   style: ElevatedButton.styleFrom(
  //                       shape: RoundedRectangleBorder(
  //                           borderRadius: BorderRadius.circular(6)),
  //                       backgroundColor:
  //                           const Color.fromARGB(169, 235, 234, 234)),
  //                   child: const Text(
  //                     'Upload\nDocument',
  //                     textAlign: TextAlign.center,
  //                     style: TextStyle(
  //                       fontWeight: FontWeight.bold,
  //                       fontSize: 13,
  //                       color: Color.fromRGBO(11, 133, 163, 1),
  //                     ),
  //                   ),
  //                   onPressed: () {
  //                     _showPicker(context: context);
  //                   },
  //                 ),
  //               )
  //             : Padding(
  //                 padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
  //                 child: Center(
  //                     child: _pdfFile != null
  //                         ? PDFView(
  //                             filePath: _pdfFile!.path,
  //                             enableSwipe: true,
  //                             swipeHorizontal: true,
  //                             autoSpacing: false,
  //                             pageSnap: true,
  //                           )
  //                         : galleryFile != null
  //                             ? Image.file(galleryFile!)
  //                             : Container()),
  //               ),
  //       ),
  //       galleryFile != null || _pdfFile != null
  //           ? Positioned(
  //               top: -20,
  //               right: -30,
  //               child: TextButton(
  //                   child: const Text(
  //                     'X',
  //                     style: TextStyle(
  //                       fontSize: 18,
  //                       color: Colors.red,
  //                     ),
  //                   ),
  //                   onPressed: () {
  //                     setState(() {
  //                       _pdfFile = null;
  //                       galleryFile = null;
  //                     });
  //                   }),
  //             )
  //           : Container()
  //     ],
  //   );
  // }

  _uploadDocument(String type, int index) {
    if (widget.isView && ckycDocuments[type]![index] == '') {
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
          child: ckycDocuments[type]![index] != ''
              ? Padding(
                  padding: const EdgeInsets.all(10),
                  child: Center(
                    child: ckycDocuments[type]![index].path.endsWith('.pdf')
                        ? PDFView(
                            filePath: ckycDocuments[type]![index].path,
                            enableSwipe: true,
                            swipeHorizontal: true,
                            autoSpacing: false,
                            pageSnap: true,
                          )
                        : Image.file(ckycDocuments[type]![index]),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(10),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6)),
                        backgroundColor:
                            const Color.fromRGBO(235, 234, 234, 0.663)),
                    child: const Text(
                      "Upload\nDocument",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: Color.fromRGBO(11, 133, 163, 1),
                      ),
                    ),
                    onPressed: () {
                      if (widget.isView == false) {
                        _showPicker(context: context, type: type, index: index);
                      }
                    },
                  ),
                ),
        ),
        ckycDocuments[type]![index] != '' && widget.isView == false
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
                      ckycDocuments[type]![index] = '';
                    });
                  },
                ),
              )
            : const Text('')
      ],
    );
  }

  Future<void> _pickPDF(String type, int index) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      File resultFile = File(result.files.single.path!);
      int sizeInBytes = resultFile.lengthSync();
      double sizeInMb = sizeInBytes / (1024 * 1024);
      if (sizeInMb < 2) {
        setState(() {
          ckycDocuments[type]![index] = File(result.files.single.path!);
          if (widget.isEdit) {
            edittedDocuments[type]![index] = File(result.files.single.path!);
          }
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('File size exceeds 2mb')));
      }
    } else {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No document selected')),
      );
    }
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
                  _pickPDF(type, index);
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
        ckycDocuments[type]![index] = File(pickedFile.path);
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

  _text(String text) {
    return Text(
      text,
      maxLines: 3,
      style: const TextStyle(
          color: Color.fromRGBO(11, 133, 163, 1),
          fontSize: 13,
          fontWeight: FontWeight.bold),
    );
  }

  void _showAlertDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Alert"),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}

class CustomInputField2 extends StatelessWidget {
  final String? title;
  final String? hintText;
  final TextEditingController? controller;
  final List<TextInputFormatter>? inputFormatters;
  final FormFieldValidator? validator;
  final onChanged;
  final maxLength;
  final enable;

  const CustomInputField2(
      {super.key,
      this.title,
      this.hintText,
      this.controller,
      this.inputFormatters,
      this.validator,
      this.onChanged,
      this.maxLength,
      this.enable});

  @override
  Widget build(BuildContext context) {
    FocusNode focusNode1 = FocusNode();
    return SizedBox(
      width: 250,
      child: TextFormField(
        readOnly: enable,
        maxLength: maxLength,
        controller: controller,
        onChanged: onChanged,
        decoration: InputDecoration(
          counterText: '',
          enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.black12, width: 2),
              borderRadius: BorderRadius.circular(10)),
          focusedBorder: OutlineInputBorder(
            borderSide: enable == true
                ? const BorderSide(
                    color: Color.fromARGB(255, 209, 209, 209), width: 2)
                : const BorderSide(
                    color: Color.fromRGBO(143, 19, 168, 1), width: 2),
            borderRadius: BorderRadius.circular(10),
          ),
          prefixIconColor:
              MaterialStateColor.resolveWith((Set<MaterialState> states) {
            if (states.contains(MaterialState.focused)) {
              return const Color.fromRGBO(143, 19, 168, 1);
            }
            return Colors.grey;
          }),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          labelText: title,
          labelStyle: TextStyle(
              color: focusNode1.hasFocus
                  ? const Color.fromRGBO(143, 19, 168, 1)
                  : Colors.grey),
          hintText: hintText,
        ),
        validator: validator,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        inputFormatters: inputFormatters,
      ),
    );
  }
}

class CustomInputField extends StatelessWidget {
  final String? title;
  final String? hintText;
  final FormFieldValidator? validator;
  final maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final TextEditingController? controller;
  final onChanged;

  const CustomInputField(
      {super.key,
      this.title,
      this.hintText,
      this.validator,
      this.controller,
      this.onChanged,
      this.maxLength,
      this.inputFormatters});

  @override
  Widget build(BuildContext context) {
    FocusNode focusNode1 = FocusNode();
    return TextFormField(
      onChanged: onChanged,
      // scrollPadding: EdgeInsets.all(5),
      maxLength: maxLength,
      inputFormatters: inputFormatters,
      controller: controller,
      decoration: InputDecoration(
        enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.black12, width: 2),
            borderRadius: BorderRadius.circular(10)),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(
              color: Color.fromRGBO(11, 133, 163, 1), width: 2),
          borderRadius: BorderRadius.circular(10),
        ),
        prefixIconColor:
            MaterialStateColor.resolveWith((Set<MaterialState> states) {
          if (states.contains(MaterialState.focused)) {
            return const Color.fromRGBO(11, 133, 163, 1);
          }
          return Colors.grey;
        }),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        labelText: title,
        labelStyle: TextStyle(
            color: focusNode1.hasFocus
                ? const Color.fromRGBO(11, 133, 163, 1)
                : Colors.grey),
        hintText: hintText,
      ),
      validator: validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
    );
  }
}

// / switch (selectedValue) {
//   'Sole Proprietorship' =>
//     _customDropDown('Select Documents', 'Select option', (value) {
//       selectedDocument = value;
//     }, documents, selectedDocument),
// TODO: Handle this case.
// String() => throw UnimplementedError(),
// },
//
// const SizedBox(
//   height: 20,
// ),
// SizedBox(
//   height: 150.0,
//   width: 200.0,
//   child: galleryFile == null
//       ? const Center(child: Text('Sorry nothing selected!!'))
//       : Center(child: Image.file(galleryFile!)),
// ),

// / Container(
//   decoration: const BoxDecoration(
//     borderRadius:
//         BorderRadius.all(Radius.circular(10)),
//     color: Color.fromRGBO(11, 133, 163, 1),
//   ),
//   child: TextButton(
//       onPressed: () {
//         print('done');
//         if (controller1.text == '12345671234567') {
//           setState(() {
//             isFetched = true;
//           });
//         } else {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//                 content: Text('Invalid CKYC ID')),
//           );
//         }
//       },
//       child: const Text(
//         'Fetch CKYC Details',
//         style: TextStyle(color: Colors.white),
//       )),
// ),
// _heightGap(),
// _heightGap(),
// isFetched
//     ? Column(
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           Container(
//             width: double.infinity,
//             padding: const EdgeInsets.only(
//                 left: 15, right: 15),
//             decoration: BoxDecoration(
//                 border: Border.all(
//                     color: const Color.fromRGBO(
//                         11, 133, 163, 1),
//                     width: 2),
//                 borderRadius:
//                     BorderRadius.circular(10)),
//             child: Column(
//               crossAxisAlignment:
//                   CrossAxisAlignment.start,
//               children: [
//                 _heightGap(),
//                 _text(
//                     'Customer Name: Abcde Fghijklmno'),
//                 _heightGap(),
//                 _text('CKYC ID: 12345671234567'),
//                 _heightGap(),
//                 _text('DOB: 12-04-1990'),
//                 _heightGap(),
//               ],
//             ),
//           ),
//           _heightGap(),
// Container(
//   decoration: const BoxDecoration(
//     borderRadius: BorderRadius.all(
//         Radius.circular(10)),
//     color: Color.fromRGBO(11, 133, 163, 1),
//   ),
//   child: TextButton(
//       onPressed: () {
//         Navigator.push(
//             context,
//             MaterialPageRoute(
//                 builder: (context) =>
//                     ProposalDocuments(
//                       inwardData: {},
//                       inwardType: {},
//                       ckycData: {},
//                       ckycDocuments: [],
//                     )));
//       },
//       child: const Text(
//         'Submit CKYC',
//         style:
//             TextStyle(color: Colors.white),
//       )),
// )
//     ],
//   )
// : Container()
