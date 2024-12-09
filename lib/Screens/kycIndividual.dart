import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
import 'package:secure_app/Screens/inwardForm%201.dart';
import 'package:secure_app/Screens/uploadProposal.dart';
import 'package:secure_app/Validations/validators.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';

class KYCIndividual extends StatefulWidget {
  final inwardData;
  final inwardType;
  final isEdit;
  final isView;
  final edit;
  const KYCIndividual({
    super.key,
    required this.inwardData,
    required this.inwardType,
    this.isEdit = false,
    this.isView = false,
    this.edit = false,
  });

  @override
  State<KYCIndividual> createState() => _KYCIndividualState();
}

class _KYCIndividualState extends State<KYCIndividual> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  var productName;
  File? galleryFile;

  final picker = ImagePicker();
  String? _kycAvailable;
  String? _panAvailable;
  String? _aadharAvailable;
  String? _gender;
  String? _member;
  String? selectedValue;
  String? selectedDocument;
  String? selectedAddress;
  Map<String, List> kycDocumnet = {
    'customerPhoto': [''],
    'idProof': ['', ''],
    'addressProof': ['', '']
  };

  String birthDate = DateFormat('dd-MM-yyyy').format(DateTime.now());
  List<String> documents = <String>[
    'PAN Card',
    'Form 60',
    'Form 61',
  ];
  Map<String, int> documentIds = {"id_proof": 0, "address_proof": 0};

  List<String> address = <String>[
    'Voter ID',
    'Passport',
    'Driving License',
    'Masked Aadhar'
  ];
  String option = '';
  // var _accessToken = '';
  bool isFetched = false;
  bool isSubmitted = false;
  bool fetchKYC = true;
  bool noKYC = false;
  String salutation = 'Mr';
  TextEditingController panNumberController = TextEditingController();
  TextEditingController ckycIDController = TextEditingController();
  TextEditingController adhaarNumberController = TextEditingController();
  TextEditingController adhaarNameController = TextEditingController();
  TextEditingController salutationController = TextEditingController();
  TextEditingController firstNameController = TextEditingController();
  TextEditingController middleNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController idProofController = TextEditingController();
  TextEditingController addressProofController = TextEditingController();
  String inputType = '';
  String inputNo = '';
  Dio dio = DioSingleton.dio;
  Map ckycData = {"CKYCNumber": "", "CKYCFullName": "", "CKYCDOB": ""};
  final _formKey = GlobalKey<FormState>();
  bool editKYC = false;
  bool edit = false;
  bool isLoading = false;
  bool kyc = false;
  bool pan = false;
  bool isPan = false;
  bool isAadhar = false;
  bool aadhar = false;
  bool manual = false;
  bool fetchKyc = false;
  bool fetchPan = false;
  bool fetchAadhar = false;
  bool enableCKYC = false;
  bool enablePan = false;
  bool enableAadharNo = false;
  bool enableAadharName = false;
  bool enable2 = false;
  bool disable = false;
  var onChanged;
  var onChanged2;
  var onChanged3;
  var onChanged4;
  var onChanged5;
  var onChanged6;
  var oldVersion;
  var checkKYC;

  void initState() {
    super.initState();

    print('thisss');
    print(widget.isEdit);
    print(widget.edit);
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
    if (widget.isView) {
      getCKYCDetails();
    }
    setState(() {
      onChanged = (value) {
        if (_kycAvailable != value) {
          resetVariable();
          // kyc = false;
          isPan = false;
          pan = false;
          isAadhar = false;
          aadhar = false;
          manual = false;
          fetchPan = false;
          fetchAadhar = false;
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
            isAadhar = false;
            aadhar = false;
            manual = false;
            fetchPan = false;
            fetchAadhar = false;
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
          isAadhar = false;
          fetchAadhar = false;
          aadhar = false;
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
            isAadhar = false;
            fetchAadhar = false;
            aadhar = false;
            manual = false;
          });
        }
      };
      onChanged3 = (value) {
        if (_panAvailable != value) {
          setState(() {
            _aadharAvailable = null;
            _gender = null;
            _member = null;
            birthDate = DateFormat('dd-MM-yyyy').format(DateTime.now());

            adhaarNumberController = TextEditingController();
            adhaarNameController = TextEditingController();
            salutationController = TextEditingController();
            firstNameController = TextEditingController();
            middleNameController = TextEditingController();
            lastNameController = TextEditingController();
            idProofController = TextEditingController();
            addressProofController = TextEditingController();
            // kyc = true;
            kyc = false;
            fetchKyc = false;
            isPan = true;
            pan = false;
            fetchPan = false;
            isAadhar = false;
            fetchAadhar = false;
            aadhar = false;
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
            isAadhar = false;
            fetchAadhar = false;
            aadhar = false;
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
            isAadhar = true;
            fetchAadhar = false;
            aadhar = false;
            manual = false;
          });
        }
        // if (value == 'Yes') {
        //   setState(() {
        //     _aadharAvailable = 'No';
        //     pan = true;
        //     fetchPan = true;
        //   });
        // }
        // if (value == 'No') {
        //   setState(() {
        //     _aadharAvailable = null;
        //     _gender = null;
        //     pan = false;
        //     isAadhar = true;
        //     fetchKyc = false;
        //     fetchPan = false;
        //   });
        // }
      };
      onChanged4 = (value) {
        if (_aadharAvailable != value) {
          setState(() {
            _member = null;
            birthDate = DateFormat('dd-MM-yyyy').format(DateTime.now());
            adhaarNumberController = TextEditingController();
            adhaarNameController = TextEditingController();
            _gender = null;
            // ckycIDController = TextEditingController();

            salutationController = TextEditingController();
            firstNameController = TextEditingController();
            middleNameController = TextEditingController();
            lastNameController = TextEditingController();
            idProofController = TextEditingController();
            addressProofController = TextEditingController();
            kyc = false;
            fetchKyc = false;
            isPan = true;
            pan = false;
            fetchPan = false;
            isAadhar = true;
            fetchAadhar = false;
            aadhar = false;
            manual = false;
          });
        }
        setState(() {
          _aadharAvailable = value;
        });
        if (_aadharAvailable == 'Yes') {
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

            // adhaarNumberController =
            //     TextEditingController();
            // adhaarNameController =
            //     TextEditingController();
            // _gender = null;

            isAadhar = true;
            fetchAadhar = true;
            aadhar = true;
            manual = false;
          });
        }
        if (_aadharAvailable == 'No') {
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
            adhaarNumberController = TextEditingController();
            adhaarNameController = TextEditingController();
            _gender = null;
            isAadhar = true;
            fetchAadhar = false;
            aadhar = false;
            manual = true;
            onChanged = null;
            onChanged2 = null;
            onChanged3 = null;
            onChanged4 = null;
            onChanged5 = null;
            disable = true;
            enableCKYC = true;
            enablePan = true;
            enableAadharNo = true;
            enableAadharName = true;
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
      onChanged5 = (value) {
        setState(() {
          _gender = value;
        });
      };
      onChanged6 = (value) {
        setState(() {
          _member = value;
        });
      };
    });
    // getToken();
    // fetchCKYC();
  }

  areKycDocumentsValid(Map<String, List<dynamic>> documents) {
    if (documents['customerPhoto']![0] == '') {
      return "Customer Photo";
    }
    if (documents['idProof']![0] == '' && documents['idProof']![1] == '') {
      return "Id Proof";
    }
    if (documents['addressProof']![0] == '' &&
        documents['addressProof']![1] == '') {
      return "Id Proof";
    }
    return '';
  }

  resetVariable() {
    setState(() {
      _panAvailable = null;
      _aadharAvailable = null;
      isPan = false;
      pan = false;
      isAadhar = false;
      aadhar = false;
      enableCKYC = false;
      enablePan = false;
      enableAadharName = false;
      enableAadharNo = false;
      manual = false;
      disable = false;
      enable2 = false;
      _gender = null;
      _member = null;
      salutation = 'Mr';
      birthDate = DateFormat('dd-MM-yyyy').format(DateTime.now());
      selectedValue = null;
      selectedDocument = null;
      selectedAddress = null;
      panNumberController = TextEditingController();
      ckycIDController = TextEditingController();
      adhaarNumberController = TextEditingController();
      adhaarNameController = TextEditingController();
      salutationController = TextEditingController();
      firstNameController = TextEditingController();
      middleNameController = TextEditingController();
      lastNameController = TextEditingController();
      idProofController = TextEditingController();
      addressProofController = TextEditingController();
      kycDocumnet = {
        'customerPhoto': [''],
        'idProof': ['', ''],
        'addressProof': ['', '']
      };
      setState(() {
        onChanged = (value) {
          if (_kycAvailable != value) {
            resetVariable();
            // kyc = false;
            isPan = false;
            pan = false;
            isAadhar = false;
            aadhar = false;
            manual = false;
            fetchPan = false;
            fetchAadhar = false;
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
              isAadhar = false;
              aadhar = false;
              manual = false;
              fetchPan = false;
              fetchAadhar = false;
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
            isAadhar = false;
            fetchAadhar = false;
            aadhar = false;
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
              isAadhar = false;
              fetchAadhar = false;
              aadhar = false;
              manual = false;
            });
          }
        };
        onChanged3 = (value) {
          if (_panAvailable != value) {
            setState(() {
              _aadharAvailable = null;
              _gender = null;
              _member = null;
              birthDate = DateFormat('dd-MM-yyyy').format(DateTime.now());
              adhaarNumberController = TextEditingController();
              adhaarNameController = TextEditingController();
              salutationController = TextEditingController();
              firstNameController = TextEditingController();
              middleNameController = TextEditingController();
              lastNameController = TextEditingController();
              idProofController = TextEditingController();
              addressProofController = TextEditingController();
              kyc = false;
              fetchKyc = false;
              isPan = true;
              pan = false;
              fetchPan = false;
              isAadhar = false;
              fetchAadhar = false;
              aadhar = false;
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
              isAadhar = false;
              fetchAadhar = false;
              aadhar = false;
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
              isAadhar = true;
              fetchAadhar = false;
              aadhar = false;
              manual = false;
            });
          }
        };
        onChanged4 = (value) {
          if (_aadharAvailable != value) {
            setState(() {
              _member = null;
              birthDate = DateFormat('dd-MM-yyyy').format(DateTime.now());
              adhaarNumberController = TextEditingController();
              adhaarNameController = TextEditingController();
              _gender = null;
              salutationController = TextEditingController();
              firstNameController = TextEditingController();
              middleNameController = TextEditingController();
              lastNameController = TextEditingController();
              idProofController = TextEditingController();
              addressProofController = TextEditingController();
              kyc = false;
              fetchKyc = false;
              isPan = true;
              pan = false;
              fetchPan = false;
              isAadhar = true;
              fetchAadhar = false;
              aadhar = false;
              manual = false;
            });
          }
          setState(() {
            _aadharAvailable = value;
          });
          if (_aadharAvailable == 'Yes') {
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
              isAadhar = true;
              fetchAadhar = true;
              aadhar = true;
              manual = false;
            });
          }
          if (_aadharAvailable == 'No') {
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
              adhaarNumberController = TextEditingController();
              adhaarNameController = TextEditingController();
              _gender = null;
              isAadhar = true;
              fetchAadhar = false;
              aadhar = false;
              manual = true;
              onChanged = null;
              onChanged2 = null;
              onChanged3 = null;
              onChanged4 = null;
              onChanged5 = null;
              disable = true;
              enableCKYC = true;
              enablePan = true;
              enableAadharNo = true;
              enableAadharName = true;
            });
          }
        };
        onChanged5 = (value) {
          setState(() {
            _gender = value;
          });
        };
        onChanged6 = (value) {
          setState(() {
            _member = value;
          });
        };
      });
    });
  }

  fetchCKYC() async {
    print('fetching ckyc');
    String firstName = '';
    String middleName = '';
    String lastName = '';
    var adhaarNameValue = adhaarNameController.text.split(' ');
    if (adhaarNameValue.length == 3) {
      firstName = adhaarNameValue[0];
      middleName = adhaarNameValue[1];
      lastName = adhaarNameValue[2];
    }
    if (adhaarNameValue.length == 2) {
      firstName = adhaarNameValue[0];
      lastName = adhaarNameValue[1];
    }
    if (adhaarNameValue.length == 1) {
      firstName = adhaarNameValue[0];
    }

    setState(() {
      isLoading = true;
    });
    SharedPreferences prefs = await _prefs;
    var token = prefs.getString('token') ?? '';
    Map<String, dynamic> kycData = {
      "A99RequestData": {
        "RequestId": "896598",
        "source": "gromoinsure",
        "policyNumber": "",
        "GetRecordType": "IND",
        "InputIdType": inputType,
        "InputIdNo": inputNo,
        "DateOfBirth": birthDate,
        "MobileNumber": "",
        "Pincode": "",
        "BirthYear": "",
        "Tags": "",
        "ApplicationRefNumber": "",
        "FirstName": firstName,
        "MiddleName": middleName,
        "LastName": lastName,
        "Gender": _gender,
        "ResultLimit": "Latest",
        "photo": "",
        "AdditionalAction": ""
      }
    };

    print(kycData);
    final appState = Provider.of<AppState>(context, listen: false);
    Map<String, String> headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      "Accept": "application/json",
      "Authorization": appState.accessToken
    };

    String result = aesGcmEncryptJson(jsonEncode(kycData));
    Map<String, dynamic> encryptedData = {'encryptedData': result};
    print(encryptedData);
    try {
      final response = await dio.post(
          'https://uatcld.sbigeneral.in/SecureApp/ckyc',
          data: encryptedData,
          options: Options(headers: headers));

      String decryptedData = aesGcmDecryptJson(response.data);

      var data = jsonDecode(decryptedData);
      print('fetched ckyc');
      print(data);
      // var data = const JsonDecoder().convert(jsonMap);
      // final Map<String, dynamic> data = jsonDecode(response.data);
      setState(() {
        isLoading = false;
        isFetched = true;
        ckycData = data;

        isSubmitted = true;
        fetchKYC = false;
        if (_kycAvailable == 'Yes') {
          fetchKyc = false;
        }
        if (_panAvailable == 'Yes') {
          fetchKyc = false;
          fetchPan = false;
        }
        if (_aadharAvailable == 'Yes') {
          fetchKyc = false;
          fetchPan = false;
          fetchAadhar = false;
        }
        onChanged = null;
        onChanged2 = null;
        onChanged3 = null;
        onChanged4 = null;
        onChanged5 = null;
        onChanged6 = null;
        disable = true;
        enableCKYC = true;
        enablePan = true;
        enableAadharNo = true;
        enableAadharName = true;
        enable2 = true;
      });
    } catch (error) {
      print(error);
      setState(() {
        isLoading = false;
        isFetched = false;
        noKYC = true;
      });
      if (_aadharAvailable == 'Yes') {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: const Text(
                "No CKYC Record found for the given Aadhar Card Details"),
            action: SnackBarAction(
              label: ' Cancel',
              onPressed: () {},
            )));
      } else if (_panAvailable == 'Yes') {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: const Text("No CKYC Record found for this PAN Number"),
            action: SnackBarAction(
              label: ' Cancel',
              onPressed: () {},
            )));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: const Text("No Records Found!"),
            action: SnackBarAction(
              label: ' Cancel',
              onPressed: () {},
            )));
      }
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
    } on DioException catch (error) {
      print(error.message);
      return "Documents not submitted, Please try again";
    }
  }

  sendCkyc(kycData, formData, context) async {
    setState(() {
      isLoading = true;
    });
    print('sent');
    final appState = Provider.of<AppState>(context, listen: false);
    try {
      print(appState.proposalId);
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
          'https://uatcld.sbigeneral.in/SecureApp/postCkycDetails',
          data: encryptedCkycData,
          options: Options(headers: headers));
      print(response.data);
      print(formData.files);
      String uploadDocResult =
          await uploadCkycDocs(appState.proposalId, formData);
      print(uploadDocResult);
      if (uploadDocResult == "") {
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
            data['customer_type'].toLowerCase() == 'individual') {
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
    print('version : ${newVersion.toStringAsFixed(1)}');
    for (var i = 0; i < kycDocumnet['idProof']!.length; i++) {
      if (kycDocumnet['idProof']![i] != '') {
        var fileExtension = kycDocumnet['idProof']![i].path.split('.').last;
        formData.files.add(MapEntry(
            'files',
            await MultipartFile.fromFile(kycDocumnet['idProof']![i].path,
                filename:
                    '${documents.indexOf(selectedDocument!)}_page${i + 1}.$fileExtension')));
      }
    }
    for (var i = 0; i < kycDocumnet['addressProof']!.length; i++) {
      if (kycDocumnet['addressProof']![i] != '') {
        var fileExtension =
            kycDocumnet['addressProof']![i].path.split('.').last;
        formData.files.add(MapEntry(
            'files',
            await MultipartFile.fromFile(kycDocumnet['addressProof']![i].path,
                filename:
                    '${address.indexOf(selectedAddress!)}_page${i + 1}.$fileExtension')));
      }
    }
    for (var i = 0; i < kycDocumnet['customerPhoto']!.length; i++) {
      if (kycDocumnet['customerPhoto']![i] != '') {
        var fileExtension =
            kycDocumnet['customerPhoto']![i].path.split('.').last;
        formData.files.add(MapEntry(
            'files',
            await MultipartFile.fromFile(kycDocumnet['customerPhoto']![i].path,
                filename: '8_page${i + 1}.$fileExtension')));
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

  editCkyc(kycData, formData, context) async {
    print('editedd');
    setState(() {
      isLoading = true;
    });
    print(kycData);

    try {
      final appState = Provider.of<AppState>(context, listen: false);
      print(appState.proposalId);
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
      bool ckycError = await editCkycDocuments();
      print(response.data);
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

  void _submitKYC(String? ckycType, context) async {
    if (widget.isView) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ProposalDocuments(
                  inwardData: {"product": productName},
                  inwardType: widget.inwardType,
                  ckycData: null,
                  ckycDocuments: null)));
      return;
    }
    Map kycData;
    Map responseCkyc;
    if (ckycType == 'Manual') {
      responseCkyc = {};

      if (_formKey.currentState!.validate()) {
        List combinedDocuments = documents + address;
        String areDocumentsValid = areKycDocumentsValid(kycDocumnet);
        if (areDocumentsValid == '') {
          kycData = {
            "ckyc_exist": _kycAvailable == 'Yes' ? 'Y' : 'N',
            "ckyc_num":
                ckycIDController.text == '' ? null : ckycIDController.text,
            "pan_avail": _panAvailable == 'Yes' ? '1' : '0',
            "aadhar_avail": _aadharAvailable == 'Yes' ? '1' : '0',
            "customer_type": "Individual",
            "pan_num": panNumberController.text == ''
                ? null
                : panNumberController.text,
            "dob": DateFormat("yyyy-MM-dd")
                .format(DateFormat("dd-MM-yyyy").parse(birthDate)),
            "aadhar_card_last_4_digit_number": adhaarNumberController.text == ''
                ? null
                : adhaarNumberController.text,
            "aadhar_card_full_name": adhaarNameController.text == ''
                ? null
                : adhaarNameController.text,
            "aadhar_card_gender": _gender,
            "aadhar_card_dob": null,
            "relative_type_selected": _member,
            "relative_prefix": _member == 'Spouse'
                ? salutation
                : _member == "Father's \nDetails"
                    ? 'Mr'
                    : _member == "Mother's \nDetails"
                        ? 'Mrs'
                        : '',
            "relative_first_name": firstNameController.text,
            "relative_middle_name": middleNameController.text,
            "relative_last_name": lastNameController.text,
            "doc_addr_proof_number": addressProofController.text,
            "doc_id_proof_type_selected":
                documents.indexOf(selectedDocument!) + 1,
            "doc_addr_proof_type_selected":
                combinedDocuments.indexOf(selectedAddress!) + 1,
            ...responseCkyc
          };
          print(kycData);
          FormData formData = FormData();
          for (var i = 0; i < kycDocumnet['idProof']!.length; i++) {
            if (kycDocumnet['idProof']![i] != '') {
              var fileExtension =
                  kycDocumnet['idProof']![i].path.split('.').last;
              formData.files.add(MapEntry(
                  'files',
                  await MultipartFile.fromFile(kycDocumnet['idProof']![i].path,
                      filename:
                          '${documents.indexOf(selectedDocument!)}_page${i + 1}.$fileExtension')));
            }
          }
          for (var i = 0; i < kycDocumnet['addressProof']!.length; i++) {
            if (kycDocumnet['addressProof']![i] != '') {
              var fileExtension =
                  kycDocumnet['addressProof']![i].path.split('.').last;
              formData.files.add(MapEntry(
                  'files',
                  await MultipartFile.fromFile(
                      kycDocumnet['addressProof']![i].path,
                      filename:
                          '${address.indexOf(selectedAddress!)}_page${i + 1}.$fileExtension')));
            }
          }
          for (var i = 0; i < kycDocumnet['customerPhoto']!.length; i++) {
            if (kycDocumnet['customerPhoto']![i] != '') {
              var fileExtension =
                  kycDocumnet['customerPhoto']![i].path.split('.').last;
              formData.files.add(MapEntry(
                  'files',
                  await MultipartFile.fromFile(
                      kycDocumnet['customerPhoto']![i].path,
                      filename: '8_page${i + 1}.$fileExtension')));
            }
          }
          if (checkKYC == false) {
            sendCkyc(kycData, formData, context);
          } else {
            editCkyc(kycData, formData, context);
          }
          // if (widget.isEdit == false && edit == false) {
          //   sendCkyc(kycData, formData, context);
          // } else if (widget.isEdit == true && edit == false) {
          //   if (checkKYC = false) {
          //     sendCkyc(kycData, formData, context);
          //   } else {
          //     editCkyc(kycData, formData, context);
          //   }
          // } else {
          //   editCkyc(kycData, formData, context);
          // }
          // Navigator.push(
          //     context,
          //     MaterialPageRoute(
          //         builder: (context) => ProposalDocuments(
          //             inwardData: widget.inwardData,
          //             inwardType: widget.inwardType,
          //             ckycData: kycData,
          //             ckycDocuments: formData)));
        } else {
          if (_member == null) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: const Text("Please Select family details"),
                action: SnackBarAction(
                  label: ' Cancel',
                  onPressed: () {},
                )));
          } else if (areDocumentsValid == 'Customer Photo') {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: const Text("Please upload customer photo"),
                action: SnackBarAction(
                  label: ' Cancel',
                  onPressed: () {},
                )));
          } else {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: const Text("Upload required documents"),
                action: SnackBarAction(
                  label: ' Cancel',
                  onPressed: () {},
                )));
          }
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
        "aadhar_avail": _aadharAvailable == 'Yes' ? '1' : '0',
        "customer_type": "Individual",
        "pan_num":
            panNumberController.text == '' ? null : panNumberController.text,
        "dob": DateFormat("yyyy-MM-dd")
            .format(DateFormat("dd-MM-yyyy").parse(birthDate)),
        "aadhar_card_last_4_digit_number": adhaarNumberController.text == ''
            ? null
            : adhaarNumberController.text,
        "aadhar_card_full_name":
            adhaarNameController.text == '' ? null : adhaarNameController.text,
        "aadhar_card_gender": _gender,
        "aadhar_card_dob": null,
        "response_ckyc_num": ckycData['CKYCNumber'],
        "response_ckyc_dob": DateFormat("yyyy-MM-dd")
            .format(DateFormat("dd-MMM-yyyy").parse(ckycData['CKYCDOB'])),
        "response_ckyc_customer_name": ckycData['CKYCFullName'],
        "relative_type_selected": _member,
        "relative_prefix": _member == 'Spouse'
            ? salutation
            : _member == "Father's \nDetails"
                ? 'Mr'
                : _member == "Mother's \nDetails"
                    ? 'Mrs'
                    : '',
      };
      print(kycData);
      FormData formData = FormData();

      if (checkKYC == false) {
        sendCkyc(kycData, formData, context);
      } else {
        editCkyc(kycData, formData, context);
      }
    }
  }

  getCKYCDetails() async {
    print("asdasd");
    setState(() {
      isLoading = true;
    });

    try {
      SharedPreferences prefs = await _prefs;
      var token = prefs.getString('token') ?? '';
      final appState = Provider.of<AppState>(context, listen: false);
      var proposalId = appState.proposalId;
      Map<String, dynamic> postData = {"proposal_id": proposalId};

      String key = 'kHkD9nYB/cZhW4L5Zz8Hdf1MTh4Vr6fLs5v2mhW7FAg=';
      String base64iv = 'AqZBb6O2mF42E4eXWuH8vw==';
      String result = aesGcmEncryptJson(jsonEncode(postData));
      Map<String, dynamic> encryptedData = {'encryptedData': result};

      print(postData);
      Map<String, String> headers = {
        'Content-Type': 'application/json; charset=UTF-8',
        "Accept": "application/json",
        "Authorization": appState.accessToken
      };

      final response = await dio.post(
          'https://uatcld.sbigeneral.in/SecureApp/ckycDetails',
          options: Options(headers: headers),
          data: encryptedData);
      // var data = jsonDecode(response.data);
      String decryptedData = aesGcmDecryptJson(response.data);

      var data = jsonDecode(decryptedData);
      // var data = const JsonDecoder().convert(jsonMap);
      print('yaha haiii');
      print(data);
      setState(() {
        productName = widget.inwardData['product'];
        birthDate = data['dob'];
        // DateFormat("yyyy-MM-dd")
        //     .format(DateFormat("dd-MM-yyyy").parse(data['dob']));
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
        _aadharAvailable = data['aadhar_avail'] == '1' ? "Yes" : 'No';
        if (data['aadhar_avail'] == '1') {
          isAadhar = true;
          aadhar = true;
          fetchAadhar = false;
          adhaarNameController.text = data['aadhar_card_full_name'] ?? '';
          adhaarNumberController.text =
              data['aadhar_card_last_4_digit_number'] ?? '';
          _gender = data['aadhar_card_gender'];
        }
        if (data['relative_type_selected'] != null) {
          isAadhar = true;
          aadhar = false;
          fetchAadhar = false;
          manual = true;
          _member = toBeginningOfSentenceCase(data['relative_type_selected']);
          salutationController.text = data['relative_prefix'] ?? '';
          firstNameController.text = data['relative_first_name'] ?? '';
          middleNameController.text = data['relative_middle_name'] ?? '';
          lastNameController.text = data['relative_last_name'] ?? '';
          idProofController.text = data['doc_id_proof_number'] ?? '';
          addressProofController.text = data['doc_addr_proof_number'] ?? '';
        }
        if (data['response_ckyc_num'] != null) {
          isFetched = true;
          ckycData["CKYCNumber"] = data['response_ckyc_num'] ?? '';
          ckycData["CKYCFullName"] = data['response_ckyc_customer_name'] ?? '';
          ckycData["CKYCDOB"] = data['response_ckyc_dob'];
          // DateFormat("yyyy-MM-dd").format(
          //     DateFormat("dd-MM-yyyy").parse(data['response_ckyc_dob']));
          isSubmitted = true;
          isLoading = false;
        }
        onChanged = null;
        onChanged2 = null;
        onChanged3 = null;
        onChanged4 = null;
        onChanged5 = null;
        onChanged6 = null;
        disable = true;
        enableCKYC = true;
        enablePan = true;
        enableAadharNo = true;
        enableAadharName = true;
        enable2 = true;
      });
      if (data['relative_type_selected'] != null) {
        setState(() {
          documentIds['id_proof'] = data["doc_id_proof_type_selected"];
          documentIds['address_proof'] = data["doc_addr_proof_type_selected"];
          if (data["doc_id_proof_type_selected"] == null) {
            setState(() {
              isLoading = false;
            });
          } else {
            setState(() {
              isLoading = true;
            });
            getDocuments(data["doc_addr_proof_number"].toString());
          }
        });
        print(data["doc_id_proof_type_selected"]);
      }
      setState(() {
        isLoading = false;
      });
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

  fetchFilePath(String filename) async {
    SharedPreferences prefs = await _prefs;
    var token = prefs.getString('token') ?? '';
    final dir = await getApplicationDocumentsDirectory();
    final filePath = '${dir.path}/$filename';
    final appState = Provider.of<AppState>(context, listen: false);

    var proposalId = appState.proposalId;
    Map<String, String> headers = {"Authorization": appState.accessToken};

    final response = await dio.download(
        'https://uatcld.sbigeneral.in/SecureApp/proposalDocument/${proposalId}/$filename',
        options: Options(headers: headers),
        filePath);
    if (response.statusCode == 200) {
      return filePath;
    } else {
      return null;
    }
  }

  getDocuments(addressProof) async {
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
      final response = await dio.post(
          'https://uatcld.sbigeneral.in/SecureApp/proposalDocuments',
          data: {'proposal_id': proposalId, 'doc_type': 'ckyc'},
          options: Options(headers: headers));
      var data = List.from(jsonDecode(response.data));
      var combinedDropdownList = documents + address;
      print(data);
      for (var i = 0; i < data.length; i++) {
        var documentId =
            int.parse(data[i]['file_name'].split('.')[0].split('_')[5]);
        String fileName = data[i]['file_name'].split('.')[0];
        print(documentId);
        if (documentId < 3) {
          selectedDocument = combinedDropdownList[documentIds['id_proof']! - 1];
          print(documentId);
          print(data[i]['file_name']);
          print(fileName);
          kycDocumnet['idProof']![int.parse(fileName[fileName.length - 1]) -
              1] = File(await fetchFilePath(data[i]['file_name']));
          setState(() {});
        } else if (documentId == 8) {
          kycDocumnet['customerPhoto']![0] =
              File(await fetchFilePath(data[i]['file_name']));
          setState(() {});
        } else {
          selectedAddress =
              combinedDropdownList[documentIds['address_proof']! - 1];
          kycDocumnet['addressProof']![
                  int.parse(fileName[fileName.length - 1]) - 1] =
              File(await fetchFilePath(data[i]['file_name']));
          addressProofController.text = addressProof;
          print(addressProof);
          setState(() {});
        }
      }
      setState(() {
        isLoading = false;
      });
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      print(error);
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error! Failed to fetch documents')));
    }
  }

  // fetchCKYC() async {
  //   Map<String, dynamic> post = {};

  // Map<String, dynamic> postData = {
  //   "encryptedData": result,
  //   "key": key,
  //   "base64IV": base64iv,
  // };

  // Map<String, dynamic> headers = {
  //   'Content-Type': 'application/json; charset=UTF-8',
  //   "Accept": "application/json",
  //   "X-IBM-Client-Id": "03d37cba-bb30-42ef-a7b5-90eff137e085",
  //   "X-IBM-Client-Secret":
  //       "aE0fW4iF6sJ0dF0vR5qT1jO3oL3bK5gI6lL1mF2vP1jF4yH3hE",
  //   "Authorization": 'Bearer ${_accessToken}'
  // };
  // try {
  //   final response = await dio.post(
  //       'https://devapi.sbigeneral.in/ept/v1/portalCkycV',
  //       data: postData,
  //       options: Options(headers: headers));
  //   var decryptedData = aesGcmDecryptJson(response.data, key, base64iv);
  //   final Map<String, dynamic> data = jsonDecode(decryptedData);
  // } catch (e) {}
  // }

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
                      child: Column(children: [
                    CustomInputContainer(children: [
                      _heightGap(),
                      Wrap(
                          spacing: 20,
                          runSpacing: 15,
                          alignment: WrapAlignment.start,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Container(
                              width: 320,
                              child: const Wrap(
                                spacing: 2,
                                children: [
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
                                ],
                              ),
                            ),
                            SizedBox(
                              width: 350,
                              child: Row(
                                children: [
                                  Radio(
                                      activeColor:
                                          Color.fromRGBO(143, 19, 168, 1),
                                      autofocus: false,
                                      value: 'Yes',
                                      groupValue: _kycAvailable,
                                      onChanged: onChanged),
                                  const Text('Yes'),
                                  const SizedBox(
                                    width: 50,
                                  ),
                                  Radio(
                                      activeColor:
                                          Color.fromRGBO(143, 19, 168, 1),
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
                                        return 'Please Enter valid CKYC ID';
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
                          ]),
                      _heightGap(),
                      _heightGap(),
                      DatePickerFormField(
                        disabled: disable,
                        labelText: 'Date of Birth',
                        onChanged: (DateTime? value) {
                          setState(() {
                            birthDate = DateFormat('dd-MM-yyyy')
                                .format(value as DateTime);
                          });
                          print('seeeeeee hereeee');
                          print(birthDate);

                          print('Selected date: $value');
                        },
                        date: birthDate,
                      ),
                      _heightGap(),
                    ]),
                    _heightGap(),

                    // _heightGap(),
                    // _heightGap(),
                    // _heightGap(),
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
                        : Container(),

                    isPan
                        ? CustomInputContainer(children: [
                            _heightGap(),
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
                                          inputFormatters: <TextInputFormatter>[
                                            FilteringTextInputFormatter.allow(
                                                RegExp("[0-9a-zA-Z]")),
                                          ],
                                          maxLength: 10,
                                          controller: panNumberController,
                                          onChanged: (value) {
                                            panNumberController.value =
                                                TextEditingValue(
                                                    text: value.toUpperCase(),
                                                    selection:
                                                        panNumberController
                                                            .selection);
                                          },
                                          title: 'PAN Number',
                                          hintText: 'Enter PAN Number',
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Please enter PAN Number';
                                            }

                                            final alphanumericRegex = RegExp(
                                                r'^[A-Z]{5}[0-9]{4}[A-Z]$');
                                            if (!alphanumericRegex
                                                .hasMatch(value)) {
                                              return 'Please enter a valid PAN Number';
                                            }

                                            if (value == '0') {
                                              return 'Please enter a valid PAN Number';
                                            }

                                            return null;
                                          },
                                        )
                                      : const SizedBox.shrink(),
                                ]),
                            _heightGap()
                          ])
                        : Container(),
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
                                      option = 'Aadhar Number';
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
                        : Container(),
                    _heightGap(),
                    isAadhar
                        ? CustomInputContainer(children: [
                            _heightGap(),
                            Wrap(
                              spacing: 20,
                              runSpacing: 15,
                              alignment: WrapAlignment.start,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                _customRadio('Do you have Aadhar?',
                                    _aadharAvailable, onChanged4),
                                aadhar
                                    ? SizedBox(
                                        width: 600,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Wrap(
                                              spacing: 20,
                                              runSpacing: 15,
                                              alignment: WrapAlignment.start,
                                              crossAxisAlignment:
                                                  WrapCrossAlignment.center,
                                              children: [
                                                CustomInputField2(
                                                  enable: enableAadharNo,
                                                  controller:
                                                      adhaarNumberController,
                                                  inputFormatters: <TextInputFormatter>[
                                                    FilteringTextInputFormatter
                                                        .digitsOnly
                                                  ],
                                                  maxLength: 4,
                                                  title:
                                                      'Enter Last 4 digits of Aadhar Number',
                                                  hintText:
                                                      'Enter Last 4 digits of Aadhar Number',
                                                  validator: (value) {
                                                    if (value!.isEmpty) {
                                                      return 'Please Enter the Aadhar Card Number';
                                                    } else if (int.parse(
                                                            value) ==
                                                        0) {
                                                      return 'Please Enter valid Aadhar Card Number';
                                                    } else if (value.length <
                                                        4) {
                                                      return ' Last 4 digits is required';
                                                    }
                                                    return null;
                                                  },
                                                ),
                                                CustomInputField2(
                                                  enable: enableAadharName,
                                                  controller:
                                                      adhaarNameController,
                                                  inputFormatters: <TextInputFormatter>[
                                                    FilteringTextInputFormatter
                                                        .allow(RegExp(
                                                            "[a-zA-Z ]")),
                                                  ],
                                                  validator: (value) {
                                                    if (value!.isEmpty) {
                                                      return 'Please Enter the Customer Full Name';
                                                    } else if (value.trim() !=
                                                        value) {
                                                      return 'Please Enter Valid Name';
                                                    }
                                                    return null;
                                                  },
                                                  onChanged: (value) {
                                                    adhaarNameController.value =
                                                        TextEditingValue(
                                                            text: value
                                                                .toUpperCase(),
                                                            selection:
                                                                adhaarNameController
                                                                    .selection);
                                                  },
                                                  title:
                                                      'Customer Full Name as per Aadhar Card',
                                                  hintText:
                                                      'Enter Customer Full Name as per Aadhar Card',
                                                ),
                                              ],
                                            ),
                                            _customRadio2(
                                                'Gender:',
                                                _gender,
                                                onChanged5,
                                                'Male',
                                                'Female',
                                                'Transgender'),
                                          ],
                                        ),
                                      )
                                    : Container(),
                              ],
                            ),
                            _heightGap(),
                          ])
                        : Container(),
                    _heightGap(),
                    fetchAadhar
                        ? Container(
                            decoration: const BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                              color: Color.fromRGBO(143, 19, 168, 1),
                            ),
                            child: TextButton(
                                onPressed: () {
                                  print('done');
                                  if (_aadharAvailable != null &&
                                      _gender != null &&
                                      _formKey.currentState!.validate()) {
                                    setState(() {
                                      inputType = 'E';
                                      inputNo = adhaarNumberController.text;
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
                        : Container(),
                    manual
                        ? CustomInputContainer(
                            children: [
                              Wrap(
                                spacing: 20,
                                runSpacing: 15,
                                alignment: WrapAlignment.start,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  _customRadio2('Family Details:', _member,
                                      onChanged6, 'Spouse', "Father", "Mother"),
                                  if (_member == 'Spouse' ||
                                      _member == "Father" ||
                                      _member == "Mother")
                                    Wrap(
                                      spacing: 20,
                                      runSpacing: 15,
                                      alignment: WrapAlignment.start,
                                      crossAxisAlignment:
                                          WrapCrossAlignment.center,
                                      children: [
                                        DropdownWidget(
                                          view: enable2,
                                          label: 'Salutation',
                                          items: ['Mr', 'Mrs'],
                                          hintText: "Please Select Inward Type",
                                          value: _member == 'Spouse'
                                              ? salutation
                                              : _member == "Father"
                                                  ? 'Mr'
                                                  : _member == "Mother"
                                                      ? 'Mrs'
                                                      : '',
                                          onChanged: _member == 'Spouse'
                                              ? (val) {
                                                  setState(() {
                                                    print(val);
                                                    salutation = val;
                                                  });
                                                }
                                              : null,
                                        ),
                                        _nameDetails(),
                                      ],
                                    ),
                                ],
                              ),
                              _heightGap(),
                              const Text(
                                'CKYC Documents:',
                                style: TextStyle(
                                    color: Color.fromRGBO(143, 19, 168, 1),
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold),
                              ),
                              Wrap(
                                children: [
                                  _ckycDocuments(),
                                  _addressProof(),
                                ],
                              ),
                              _heightGap()
                            ],
                          )
                        : Container(),
                    _heightGap(),
                    if (_member == 'Spouse' ||
                        _member == "Father" ||
                        _member == "Mother")
                      Container(
                        width: 100,
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          color: Color.fromRGBO(143, 19, 168, 1),
                        ),
                        child: TextButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                if (widget.isView) {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              ProposalDocuments(
                                                  inwardData: {
                                                    "product": productName
                                                  },
                                                  inwardType: widget.inwardType,
                                                  isView: widget.isView,
                                                  isEdit: widget.isEdit,
                                                  ckycData: null,
                                                  ckycDocuments: null)));
                                } else {
                                  _submitKYC('Manual', context);
                                }
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content:
                                          Text('Please enter all details!')),
                                );
                              }
                            },
                            child: Text(
                              widget.isView ? 'Next' : 'Submit CKYC',
                              style: const TextStyle(color: Colors.white),
                            )),
                      ),

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
                                        color: Color.fromRGBO(143, 19, 168, 1),
                                        width: 2),
                                    borderRadius: BorderRadius.circular(10)),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _heightGap(),
                                    _text(
                                        'Customer Name:       ${ckycData['CKYCFullName']}'),
                                    _heightGap(),
                                    _text(
                                        'CKYC ID:       ${ckycData['CKYCNumber'].toString()}'),
                                    _heightGap(),
                                    widget.isView == true
                                        ? _text(
                                            'DOB:       ${ckycData['CKYCDOB']}')
                                        : _text(
                                            'DOB:       ${DateFormat("yyyy-MM-dd").format(DateFormat("dd-MMM-yyyy").parse(ckycData['CKYCDOB']))}'),
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
                                        color: Color.fromRGBO(143, 19, 168, 1),
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
                                                                "product":
                                                                    productName
                                                              },
                                                              inwardType: widget
                                                                  .inwardType,
                                                              isView:
                                                                  widget.isView,
                                                              isEdit:
                                                                  widget.isEdit,
                                                              ckycData: null,
                                                              ckycDocuments:
                                                                  null)));
                                            } else {
                                              _submitKYC('Not Manual', context);
                                            }
                                          },
                                          child: Text(
                                            widget.isView
                                                ? 'Next'
                                                : 'Submit CKYC',
                                            style:
                                                TextStyle(color: Colors.white),
                                          )),
                                    )
                                  : Container()
                            ],
                          )
                        : Container(),
                  ]))),
            )),
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
                                  'CKYC information is unavailable/not fetched using entered details. Please proceed with ${option} option.',
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
                                          if (_aadharAvailable == 'Yes') {
                                            setState(() {
                                              _aadharAvailable = 'Yes';
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
                                              fetchKyc = false;
                                              fetchPan = false;
                                              isAadhar = true;
                                              aadhar = true;
                                              fetchAadhar = true;
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
                                              isAadhar = false;
                                              aadhar = false;
                                              fetchAadhar = false;
                                              manual = false;
                                            });
                                          } else if (_kycAvailable == 'Yes') {
                                            setState(() {
                                              kyc = true;
                                              fetchKyc = true;
                                              isPan = false;
                                              pan = false;
                                              fetchPan = false;
                                              isAadhar = false;
                                              fetchAadhar = false;
                                              aadhar = false;
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
                                        if (_aadharAvailable == 'Yes') {
                                          setState(() {
                                            onChanged = null;
                                            onChanged2 = null;
                                            onChanged3 = null;
                                            onChanged4 = null;
                                            onChanged5 = null;
                                            disable = true;
                                            enableAadharName = true;
                                            enableAadharNo = true;
                                            if (_kycAvailable == 'Yes') {
                                              kyc = true;
                                              fetchKyc = false;
                                              enableCKYC = true;
                                            }
                                            fetchKyc = false;
                                            if (_panAvailable == 'Yes') {
                                              isPan = true;
                                              pan = true;
                                              fetchPan = false;
                                              enablePan = true;
                                            }
                                            fetchPan = false;
                                            isAadhar = true;
                                            aadhar = true;
                                            fetchAadhar = false;
                                            manual = true;
                                          });
                                        } else if (_panAvailable == 'Yes') {
                                          print('next aadhar');
                                          setState(() {
                                            _aadharAvailable = 'Yes';
                                            if (_kycAvailable == 'Yes') {
                                              kyc = true;
                                              fetchKyc = false;
                                              enableCKYC = true;
                                              disable = true;
                                            } else {
                                              kyc = false;
                                            }
                                            fetchKyc = false;
                                            onChanged = null;
                                            onChanged2 = null;
                                            onChanged3 = null;
                                            enablePan = true;
                                            isPan = true;
                                            pan = true;
                                            fetchPan = false;
                                            isAadhar = true;
                                            aadhar = true;
                                            fetchAadhar = true;
                                            manual = false;
                                          });
                                        } else if (_kycAvailable == 'Yes') {
                                          setState(() {
                                            kyc = true;
                                            fetchKyc = false;
                                            onChanged = null;
                                            onChanged2 = null;
                                            enableCKYC = true;
                                            disable = true;
                                            _panAvailable = 'Yes';
                                            isPan = true;
                                            pan = true;
                                            fetchPan = true;
                                            isAadhar = false;
                                            fetchAadhar = false;
                                            aadhar = false;
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
            : Container(),
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
                                      onPressed: () async {
                                        print("gggggggggggg");
                                        // await getVersion();
                                        setState(() {
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
            : Container(),
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

  _heightGap() {
    return const SizedBox(height: 10);
  }

  _customRadio(String label, mode, onChanged) {
    return Wrap(
        spacing: 20,
        runSpacing: 5,
        alignment: WrapAlignment.start,
        crossAxisAlignment: WrapCrossAlignment.center,
        // crossAxisAlignment: CrossAxisAlignment.start,
        // mainAxisAlignment: MainAxisAlignment.start,
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

  _customRadio2(String label, mode, onChanged, String option1, String option2,
      String option3) {
    return Wrap(
        spacing: 20,
        runSpacing: 5,
        alignment: WrapAlignment.start,
        runAlignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          SizedBox(
            width: 80,
            height: 60,
            child: Center(
              child: Text(
                label,
                textAlign: TextAlign.left,
                style: const TextStyle(
                    color: Color.fromRGBO(143, 19, 168, 1),
                    fontSize: 15,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
          SizedBox(
            width: 300,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Radio(
                  activeColor: const Color.fromRGBO(143, 19, 168, 1),
                  value: option1,
                  autofocus: false,
                  groupValue: mode,
                  onChanged: onChanged,
                ),
                Text(option1),
                // const SizedBox(
                //   width: 50,
                // ),
                Radio(
                  activeColor: const Color.fromRGBO(143, 19, 168, 1),
                  value: option2,
                  autofocus: false,
                  groupValue: mode,
                  onChanged: onChanged,
                ),
                Text(option2),
                // const SizedBox(
                //   width: 50,
                // ),
                Radio(
                  activeColor: const Color.fromRGBO(143, 19, 168, 1),
                  value: option3,
                  autofocus: false,
                  groupValue: mode,
                  onChanged: onChanged,
                ),
                Text(option3),
              ],
            ),
          ),
        ]);
  }

  _nameDetails() {
    return Wrap(
      spacing: 20,
      runSpacing: 15,
      alignment: WrapAlignment.start,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        CustomInputField2(
          enable: enable2,
          controller: firstNameController,
          title: 'First Name',
          hintText: 'Enter First Name',
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.allow(RegExp("[a-zA-Z ]")),
          ],
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter Valid First Name';
            } else if (value.trim() != value) {
              return 'Please Enter Valid Name';
            }
            return null;
          },
        ),
        CustomInputField2(
          enable: enable2,
          controller: middleNameController,
          title: 'Middle Name',
          hintText: 'Enter Middle Name',
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.allow(RegExp("[a-zA-Z]")),
          ],
          // validator: (value) {
          //   if (value == null || value.isEmpty) {
          //     return 'Please enter Valid Middle Name';
          //   }
          //   return null;
          // },
        ),
        CustomInputField2(
          enable: enable2,
          controller: lastNameController,
          title: 'Last Name',
          hintText: 'Enter Last Name',
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.allow(RegExp("[a-zA-Z ]")),
          ],
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter Valid Last Name';
            } else if (value.trim() != value) {
              return 'Please Enter Valid Name';
            }
            return null;
          },
        ),
      ],
    );
  }

  _ckycDocuments() {
    return SizedBox(
      width: 400,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _heightGap(),
          _customDropDown('Select ID Proof', (value) {
            setState(() {
              if (selectedDocument != value) {
                selectedDocument = value;
                setState(() {
                  idProofController = TextEditingController();
                  kycDocumnet['idProof'] = ['', ''];
                });
              }
            });
          }, documents, selectedDocument),
          _heightGap(),
          _heightGap(),
          selectedDocument == 'PAN Card' ||
                  selectedDocument == 'Form 60' ||
                  selectedDocument == 'Form 61'
              ? Wrap(
                  spacing: 20,
                  runSpacing: 15,
                  alignment: WrapAlignment.start,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    _uploadDocument('Upload\nID\nProof', 0, 'idProof'),
                    const SizedBox(
                      width: 20,
                    ),
                    _uploadDocument('Upload\nID\nProof', 1, 'idProof')
                  ],
                )
              : Container(),
        ],
      ),
    );
  }

  _addressProof() {
    if (selectedAddress == 'Masked Aadhar' &&
        adhaarNumberController.text != '' &&
        widget.isView == false) {
      addressProofController.text = adhaarNumberController.text;
    }
    return SizedBox(
      width: 700,
      child: Column(
        children: [
          _heightGap(),
          Wrap(
            spacing: 20,
            runSpacing: 15,
            alignment: WrapAlignment.start,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _customDropDown('Select Address Proof', (value) {
                if (selectedAddress != value) {
                  setState(() {
                    addressProofController = TextEditingController();
                    kycDocumnet['addressProof'] = ['', ''];
                  });
                }
                setState(() {
                  selectedAddress = value;
                });
              }, address, selectedAddress),
              if (selectedAddress == 'Voter ID')
                CustomInputField2(
                  enable: enable2,
                  maxLength: 10,
                  controller: addressProofController,
                  title: 'Voter ID',
                  hintText: 'Enter Voter ID',
                  validator: Validators.voterIdValidator,
                  onChanged: (value) {
                    addressProofController.value = TextEditingValue(
                        text: value.toUpperCase(),
                        selection: addressProofController.selection);
                  },
                ),
              if (selectedAddress == 'Passport')
                CustomInputField2(
                  enable: enable2,
                  maxLength: 8,
                  controller: addressProofController,
                  title: 'Passport Number',
                  hintText: 'Enter Passport Number',
                  validator: Validators.passportIdValidator,
                  onChanged: (value) {
                    addressProofController.value = TextEditingValue(
                        text: value.toUpperCase(),
                        selection: addressProofController.selection);
                  },
                ),
              if (selectedAddress == 'Driving License')
                CustomInputField2(
                  enable: enable2,
                  maxLength: 15,
                  controller: addressProofController,
                  title: 'Driving License',
                  hintText: 'Enter Driving License',
                  validator: Validators.drivingLicenseValidator,
                  onChanged: (value) {
                    addressProofController.value = TextEditingValue(
                        text: value.toUpperCase(),
                        selection: addressProofController.selection);
                  },
                ),
              if (selectedAddress == 'Masked Aadhar')
                CustomInputField2(
                  enable: enable2,
                  maxLength: 4,
                  controller: addressProofController,
                  title: 'Enter Last 4-Digit of Aadhar Card',
                  hintText: 'Enter Last 4-Digit of Aadhar Card',
                  validator: Validators.aadhaarLast4DigitsValidator,
                  onChanged: (value) {
                    addressProofController.value = TextEditingValue(
                        text: value.toUpperCase(),
                        selection: addressProofController.selection);
                  },
                ),
              // if (selectedAddress == 'Voter ID')
              //   _text(
              //       'Voter ID (Please upload first and last page of the Voter ID)'),
              // if (selectedAddress == 'Masked Aadhar')
              //   _text(
              //       'Masked Aadhar Card (Please upload front and back side of the Aadhar Card)'),
              selectedAddress != null
                  ? Wrap(
                      spacing: 20,
                      runSpacing: 15,
                      alignment: WrapAlignment.start,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        _uploadDocument(
                            'Upload\nAddress\nProof', 0, 'addressProof'),
                        _uploadDocument(
                            'Upload\nAddress\nProof', 1, 'addressProof'),
                        selectedAddress != null
                            ? _uploadDocument(
                                'Upload\nCustomer\nPhoto', 0, 'customerPhoto')
                            : Container(),
                      ],
                    )
                  : Container(),
              _heightGap(),
            ],
          ),
        ],
      ),
    );
  }

  _text(text) {
    return SizedBox(
      width: 230,
      child: Text(
        text,
        maxLines: 5,
        style: const TextStyle(
            color: Colors.black87, fontSize: 15, fontWeight: FontWeight.bold),
      ),
    );
  }

  _customDropDown(String hint, onChanged, items, value) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          DropdownWidget(
            view: enable2,
            items: items,
            value: value,
            onChanged: onChanged,
            hintText: hint,
          )
        ]);
  }

  _uploadDocument(String label, int index, String type) {
    if (widget.isView && kycDocumnet[type]![index] == '') {
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
          child: kycDocumnet[type]![index] != ''
              ? Padding(
                  padding: const EdgeInsets.all(10),
                  child: Center(
                    child: kycDocumnet[type]![index].path.endsWith('.pdf')
                        ? PDFView(
                            filePath: kycDocumnet[type]![index].path,
                            enableSwipe: true,
                            swipeHorizontal: true,
                            autoSpacing: false,
                            pageSnap: true,
                          )
                        : Image.file(kycDocumnet[type]![index]),
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
                    child: Text(
                      label,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: Color.fromRGBO(143, 19, 168, 1),
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
        kycDocumnet[type]![index] != '' && widget.isView == false
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
                      kycDocumnet[type]![index] = '';
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
          kycDocumnet[type]![index] = File(result.files.single.path!);
        });
        ;
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
        kycDocumnet[type]![index] = File(pickedFile.path);
        // if (kycDocumnet[type]!.length > index) {
        //   kycDocumnet[type]![index] = File(pickedFile.path);
        // } else {
        //   kycDocumnet[type]!.add(File(pickedFile.path));
        // }
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No document selected')),
      );
    }
  }
}

class CustomInputField extends StatelessWidget {
  final String? title;
  final String? hintText;
  final TextEditingController? controller;
  final List<TextInputFormatter>? inputFormatters;
  final FormFieldValidator? validator;
  final onChanged;
  final maxLength;

  const CustomInputField({
    super.key,
    this.title,
    this.hintText,
    this.controller,
    this.inputFormatters,
    this.validator,
    this.onChanged,
    this.maxLength,
  });

  @override
  Widget build(BuildContext context) {
    FocusNode focusNode1 = FocusNode();
    return SizedBox(
      width: 250,
      child: TextFormField(
        // textCapitalization: TextCapitalization.words,

        // scrollPadding: EdgeInsets.all(5),
        // inputFormatters: [
        //   UpperCaseTextFormatter(),
        // ],

        maxLength: maxLength,
        controller: controller,
        onChanged: onChanged,
        decoration: InputDecoration(
          counterText: '',
          enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.black12, width: 2),
              borderRadius: BorderRadius.circular(10)),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(
                color: const Color.fromRGBO(143, 19, 168, 1), width: 2),
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
                    color: const Color.fromRGBO(143, 19, 168, 1), width: 2),
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
