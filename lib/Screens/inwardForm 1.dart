// import 'package:dropdown_button2/dropdown_button2.dart';
// import 'package:dropdown_button2/dropdown_button2.dart';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';

import 'package:secure_app/Widgets/DatePickerFormField.dart';
import 'package:secure_app/Widgets/DropdownWidget.dart';
import 'package:secure_app/Widgets/RenderForm.dart';
import 'package:secure_app/commonFunction.dart';
import 'package:secure_app/Encryption-Decryption/crypto-utils.dart';
import 'package:secure_app/Widgets/customInputContainer%201.dart';
import 'package:secure_app/customProvider.dart';
import 'package:secure_app/dioSingleton.dart';
import 'package:secure_app/Screens/kyc.dart';
import 'package:secure_app/Screens/kycIndividual.dart';

// import 'package:secure_app/kyc.dart';
// import 'package:secure_app/kycIndividual.dart';
import 'package:secure_app/Screens/uploadProposal.dart';
import 'package:secure_app/Validations/validators.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';
// import 'package:secure_app/customInputContainer.dart';

class MyForm extends StatefulWidget {
  final String proposalId;
  final bool isView;
  final bool isEdit;

  const MyForm({
    super.key,
    this.proposalId = '',
    this.isView = false,
    this.isEdit = false,
  });
  @override
  _MyFormState createState() => _MyFormState();
}

class _MyFormState extends State<MyForm> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  // String propInwardType = 'Proposal';
  int? propProposalId;
  String? proposalName;

  List instruments = [
    {
      'instrumentType': null,
      'instrumentNumber': '',
      'instrumentAmount': '',
      'instrumentDate': DateFormat('yyyy-MM-dd').format(DateTime.now()),
    }
  ];
  List<TextEditingController> instrumentAmounts = [TextEditingController()];
  List<TextEditingController> instrumentNumbers = [TextEditingController()];
  final _formKey = GlobalKey<FormState>();
  final _formKey2 = GlobalKey<FormState>();
  List<String> productList = <String>['Nope'];
  List<String> list = <String>[
    'EFT',
    'Cash',
    'Cheque',
    'Credit Card',
    'Agent Cash Deposit',
    'Bank Guarantee',
    'Customer Cash Deposit',
    'Demand Draft',
    'Customer Balance'
  ];
  List<String> mode = <String>[
    'Physical',
    'Digital',
  ];
  List<String> yesNo = <String>[
    'Yes',
    'No',
  ];
  List<String> leaderFollower = <String>[
    'Leader',
    'Follower',
  ];
  List<String> individualOther = <String>[
    'Individual',
    'Other than Individual',
  ];
  List<String> spCodes = <String>['124456', '124452', '124458', '124459'];
  List<String> inwardType = <String>[
    'Endorsement',
  ];

  List<String> branches = <String>['Udaipur', 'Jaipur', 'Mumbai', 'Assam'];
  final List<String> items = ['23456', '12345', '34567', '23528'];
  // var dropdownValue = "";
  TextEditingController customerNameController = TextEditingController();
  TextEditingController previousPolicyController = TextEditingController();
  TextEditingController premiumAmountController = TextEditingController();
  TextEditingController instrumentNumberController = TextEditingController();
  TextEditingController instrumentAmountController = TextEditingController();
  TextEditingController salesEmailController = TextEditingController();
  TextEditingController salesMobileController = TextEditingController();
  TextEditingController policyNumberController = TextEditingController();
  TextEditingController quoteNumberController = TextEditingController();
  TextEditingController portalPolicyNumberController = TextEditingController();
  TextEditingController premiumCollectedController = TextEditingController();
  TextEditingController referenceNumberController = TextEditingController();
  TextEditingController sbigAccountNumberController = TextEditingController();
  TextEditingController paymentModeController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  TextEditingController accountHolderNameController = TextEditingController();
  TextEditingController accountNumberController = TextEditingController();
  TextEditingController ifscController = TextEditingController();
  TextEditingController accountTypeController = TextEditingController();
  TextEditingController refundAmountController = TextEditingController();
  TextEditingController customerAccountController = TextEditingController();
  TextEditingController requesterRemarkController = TextEditingController();
  TextEditingController oldValueController = TextEditingController();
// newwwwww controllerss
  TextEditingController mobileNumberController = TextEditingController();
  TextEditingController customerEmailController = TextEditingController();
  TextEditingController productController = TextEditingController();
  TextEditingController secondarySalesNameController = TextEditingController();
  TextEditingController secondarySalesCodeController = TextEditingController();
  TextEditingController spCodeController = TextEditingController();
  TextEditingController sbiBranchController = TextEditingController();
  TextEditingController intermediaryNameController = TextEditingController();
  TextEditingController intermediaryCodeController = TextEditingController();

  FocusNode focusNode1 = FocusNode();
  String? selectedCode;
  String? selectedEndorsementRequestType;
  String? selectedEndorsementType;
  String? selectedEndorsementSubType;
  TextEditingController agreementCodeController = TextEditingController();
  List<String> products = [];
  String? category;
  List<String> endorsementRequestType = [
    'Basic Information Endorsement',
    'Cancellation & Refund',
    'Financial Endorsement'
  ];
  List<String> endorsementType = [];
  List<String> paymentMode = [];
  List<String> refundReason = [];
  List<String> refundType = [];
  List<String> endorsementSubType = [];
  List productName = [];
  String retrivedNewValue = '';
  String? requestType;
  String? _inwardType;
  String? _modeOfSubmission1;
  bool isValid = false;
  bool view = false;
  bool viewDetails = false;
  bool isLoading = false;
  List customerTypeRejectionList = [
    'Group Loan Insurance',
    "Group Sampoorna Arogya",
    'Personal Accident',
    "Travel Group Insurance (Business and Holiday)",
    "GHI"
  ];
  String instrumentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  String proposedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  String policyIssueDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  String transactionDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  String requestReceivedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  String? _coInsurance;
  String? _PPHC;
  String? customerType;
  String? leadType;
  String? selectedRefundReason;
  String? selectedRefundType;
  String? selectedPaymentMode;
  String? selectedProduct;
  String? selectedProposal;
  String? selectedSPCode;
  String? selectedBranch;
  String? selectedSBIGBranch;
  String? selectedInstrumentType;
  String? salesID;
  Map? endorsementData;
  int instrumentAmount = 0;
  Dio dio = DioSingleton.dio;
  List? endorsementFields;
  var proposalData;
  var onChanged;
  var onChanged2;
  bool noPolicy = false;
  Widget dynamicForm = const SizedBox.shrink();
  var productType;
  var checkCustomerType;
  bool edit = false;
  bool mandatoryFields = false;
  bool verifyPolicy = false;
  bool checkPolicyNo = false;
  bool checkInstrumentNo = false;

  @override
  void initState() {
    super.initState();
    final appState = Provider.of<AppState>(context, listen: false);
    getProposalProductList();
    setState(() {
      mandatoryFields = false;
    });

    _inwardType = 'Endorsement';
    _modeOfSubmission1 = 'Digital';
    onChanged2 = (value) {
      setState(() {
        customerType = value!;
      });
    };
    onChanged = (value) {
      setState(() {
        _modeOfSubmission1 = value;
      });
    };
    if (widget.isView || widget.isEdit || edit) {
      instruments = [];
      getInwardDetails();
      setState(() {});
    }

    setState(() {
      endorsementData = {'endorsement': {}};
    });
  }

  getEndorsementFields() async {
    setState(() {
      isLoading = true;
    });
    try {
      SharedPreferences prefs = await _prefs;
      var token = prefs.getString('token') ?? '';
      final appState = Provider.of<AppState>(context, listen: false);
      Map<String, dynamic> postData = {"id": widget.proposalId};

      Map<String, String> headers = {
        'Content-Type': 'application/json; charset=UTF-8',
        "Accept": "application/json",
        "Authorization": appState.accessToken
      };

      final response = await dio.post(
          'https://uatcld.sbigeneral.in/SecureApp/endorsementDetails/endorsementFields',
          options: Options(headers: headers),
          data: {
            "subType": selectedEndorsementSubType,
            "requestorType": selectedEndorsementRequestType
          });
      // setState(() {
      //   endorsementFields = response.data['fields'];
      // });
      // return response.data['fields'];
      setState(() {
        dynamicForm = InsuranceForm(
            fillDetails: retrivedNewValue,
            getDetails: getEndorsementValues,
            subType: selectedEndorsementSubType,
            fields: jsonDecode(response.data)['fields'] as List,
            isView: widget.isView);
        // endorsementFields = jsonDecode(response.data)['fields'] as List;
        isLoading = false;
      });
    } catch (err) {
      print(err);
      setState(() {
        isLoading = false;
      });
    }
  }

  getInwardDetails() async {
    print('call');
    setState(() {
      isLoading = true;
    });
    try {
      SharedPreferences prefs = await _prefs;
      var token = prefs.getString('token') ?? '';
      Map<String, dynamic> postData = {"id": widget.proposalId};
      final appState = Provider.of<AppState>(context, listen: false);
      String result = aesGcmEncryptJson(jsonEncode(postData));
      Map<String, dynamic> encryptedData = {'encryptedData': result};
      print(encryptedData);
      // print(postData);

      Map<String, String> headers = {
        'Content-Type': 'application/json; charset=UTF-8',
        "Accept": "application/json",
        "Authorization": appState.accessToken
      };

      final response = await dio.post(
          'https://uatcld.sbigeneral.in/SecureApp/allProposalDetails',
          options: Options(headers: headers),
          data: encryptedData);
      String decryptedData = aesGcmDecryptJson(response.data);
      print(decryptedData);
      // String decryptedData2 =
      //     aesGcmDecryptJson(response.data['instruments'], key, base64iv);

      var resData = jsonDecode(decryptedData);
      var data = resData['proposalDetails'];
      var instrumentData = resData['instruments'];
      var data2 = resData['proposalDetails']['additional_proposal_details'];

      // var data = const JsonDecoder().convert(jsonMap1);
      // var instrumentData = List.from(const JsonDecoder().convert(jsonMap2));
      // print(data);
      print(data2);
      proposalName = data['product'];
      // final appState = Provider.of<AppState>(context, listen: false);
      appState.updateVariables(proposalId: data['id']);
      if (data['inward_type'] != 'Endorsement') {
        await getProposalProductList();
      }

      if (data['inward_type'] == 'Endorsement') {
        await getProposalProductList();
        // await getEndorsementProductList();
        await getEndorsementType(selectedEndorsementRequestType);
        await getEndorsementSubType();
      }
      setState(() {
        if (widget.isView) {
          onChanged = null;
          onChanged2 = null;
          view = true;
        }
        instruments = instrumentData;
        instrumentAmounts = [];
        instrumentNumbers = [];
        for (var i = 0; i < instrumentData.length; i++) {
          instrumentAmounts.add(TextEditingController(
              text: instrumentData[i]['instrumentAmount']));
          instrumentNumbers.add(TextEditingController(
              text: instrumentData[i]['instrumentNumber']));
        }
        _inwardType = data['inward_type'];
        customerNameController.text = data['customer_name'] ?? '';
        previousPolicyController.text = data['prev_policy_num'] ?? '';
        premiumAmountController.text = data['premium_amount'].toString();
        // instrumentNumberController.text = instrumentData['instrument_no'];
        // instrumentAmountController.text =
        //     instrumentData['instrument_amount'].toString();
        // salesEmailController.text = data['email'] ?? '';
        // salesMobileController.text = data['mobile'] ?? '';
        policyNumberController.text = data['policy_no'] ?? '';
        quoteNumberController.text = data['quote_no'] ?? '';

        selectedCode = data['agreement_code'];
        agreementCodeController.text = data['agreement_code'] ?? '';
        _modeOfSubmission1 = data['submission_mode'] == 'Digital' ||
                data['submission_mode'] == 'online'
            ? 'Digital'
            : 'Physical';
        // instrumentDate = instrumentData['instrument_date'];
        proposedDate = data['proposer_signed_date'] ?? '';
        _coInsurance = data['co_insurance'];
        _PPHC = data['pphc'];
        customerType =
            data['customer_type'] == 'Other' || data['customer_type'] == 'other'
                ? 'Other than Individual'
                : data['customer_type'] == 'Individual' ||
                        data['customer_type'] == 'individual'
                    ? 'Individual'
                    : null;

        leadType = data['leader_follower_type'];
        selectedProduct = data['product'];
        selectedProposal = data['inward_proposal_type'];
        selectedSPCode = '0';
        selectedBranch = data['branch'];
        selectedSBIGBranch = data['sbigi_branch'];
        policyNumberController.text = data['policy_no'] ?? '';
        quoteNumberController.text = data['quote_no'] ?? '';

        checkCustomerType =
            data['customer_type'] == 'Other' || data['customer_type'] == 'other'
                ? 'Other than Individual'
                : data['customer_type'] == 'Individual' ||
                        data['customer_type'] == 'individual'
                    ? 'Individual'
                    : null;
        portalPolicyNumberController.text = data2["portal_policy_no"] ?? '';
        policyIssueDate = data2["portal_policy_issue_date"] ?? '';
      });
      print(data['additional_proposal_details']);
      print('testing');
      print('customer type:   ${data['customer_type']}');

      if (_inwardType == 'Endorsement') {
        await getEndorsementDetails(data['id']);
        await getProposalProductDetail();
        await checkEndorsementType(data['product']);
        await getEndorsementType(requestType);
        await getEndorsementSubType();
      } else {
        await getProposalProductDetail();
      }

      setState(() {
        isLoading = false;
      });
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text("Technical Error!"),
          action: SnackBarAction(
            label: ' Cancel',
            onPressed: () {},
          )));
      print(error);
    }
  }

  getEndorsementDetails(proposalID) async {
    setState(() {
      isLoading = true;
    });
    print(proposalID);
    print('not happening');
    SharedPreferences prefs = await _prefs;
    var token = prefs.getString('token') ?? '';
    final appState = Provider.of<AppState>(context, listen: false);

    Map<String, String> headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      "Accept": "application/json",
      "Authorization": appState.accessToken
    };
    try {
      Map<String, dynamic> postData = {"proposal_id": proposalID};

      String result = aesGcmEncryptJson(jsonEncode(postData));
      Map<String, dynamic> encryptedData = {'encryptedData': result};
      final response = await dio.post(
          'https://uatcld.sbigeneral.in/SecureApp/allEndorsementDetails',
          options: Options(headers: headers),
          data: encryptedData);
      // var data = jsonDecode(response.data)['endorsementDetails'];
      String decryptedData1 = aesGcmDecryptJson((response.data));
      print('decrypt');
      print(decryptedData1);
      // String decryptedData2 =
      //     aesGcmDecryptJson(response.data['instruments'], key, base64iv);

      var data = jsonDecode(decryptedData1)['endorsementDetails'];
      // var jsonMap2 = jsonDecode(decryptedData2);

      // var data = const JsonDecoder().convert(jsonMap1);
      // var instrumentData = List.from(const JsonDecoder().convert(jsonMap2));

      setState(() {
        selectedEndorsementRequestType = data['form_type'];
        selectedEndorsementType = data['endorsement_type'];
        selectedEndorsementSubType = data['sub_type'];
        retrivedNewValue = data['new_value'];
        oldValueController.text = data["old_value"];
        policyNumberController.text = data['policy_number'];
        salesEmailController.text = data["email"] ?? '';
        salesMobileController.text = data["mobile"] ?? '';
        selectedPaymentMode = data["payment_mode"];
        selectedRefundReason = data["refund_reason"];
        selectedRefundType = data["refund_type"];
        accountHolderNameController.text = data["refund_holder_name"] ?? '';
        ifscController.text = data["refund_IFSC"] ?? '';
        accountNumberController.text = data["refund_account_no"] ?? '';
        accountTypeController.text = data["refund_account_type"] ?? '';
        requesterRemarkController.text = data["remark"] ?? '';
        requestReceivedDate = data["req_receive_date"];
        premiumCollectedController.text = data["premium_to_be_collected"];

        referenceNumberController.text =
            data["premium_reference_number"] ?? data["reference_no"] ?? '';
        sbigAccountNumberController.text =
            data["premium_SBIG_account_number"] ??
                data["sbig_account_no"] ??
                '';
        amountController.text = data["premium_amount"] ?? '';
        selectedPaymentMode =
            data["premium_payment_mode"] ?? data["payment_mode"];
        transactionDate =
            data["premium_transaction_date"] ?? data["transaction_date"];
        refundAmountController.text = data["refund_amount"] ?? '';
        requesterRemarkController.text = data['remark'] ?? '';
      });

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _addInstrument() {
    if (instruments.length == 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot add more than 5 instruments')),
      );
      return;
    }
    if (_validateInstruments()) {
      setState(() {
        instruments.add({
          'instrumentType': null,
          'instrumentNumber': '',
          'instrumentAmount': '',
          'instrumentDate': DateFormat('yyyy-MM-dd').format(DateTime.now()),
        });
        instrumentAmounts.add(TextEditingController());
        instrumentNumbers.add(TextEditingController());
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Please fill out all fields of current instrument before adding a new instrument.')),
      );
    }
  }

  bool _validateInstruments() {
    for (var i = 0; i < instruments.length; i++) {
      if (instruments[i]['instrumentType'] == null ||
          instrumentAmounts[i].text == '' ||
          instrumentNumbers[i].text == '' ||
          instruments[i]['instrumentDate'] == null) {
        return false;
      }
    }
    return true;
  }

  void _removeInstrument(int index) {
    setState(() {
      instruments.removeAt(index);
      instrumentAmounts.removeAt(index);
      instrumentNumbers.removeAt(index);
    });
  }

  Widget _buildInstrumentDetails(int index) {
    var instrument = instruments[index];
    var instrumentNumber = instrumentNumbers[index];
    var instrumentAmount = instrumentAmounts[index];
    return Column(
      children: [
        // _heightGap(),
        CustomInputContainer(children: [
          _heightGap(),
          const Text(
            "Instrument Details:",
            style: TextStyle(
              fontSize: 17,
              color: Color.fromRGBO(143, 19, 168, 1),
            ),
          ),
          Stack(
            children: [
              Wrap(
                spacing: 20,
                // runSpacing: 15,
                alignment: WrapAlignment.start,
                crossAxisAlignment: WrapCrossAlignment.start,
                children: [
                  DropdownWidget(
                    view: view,
                    label: 'Instrument Type',
                    items: list,
                    hintText: "Select your instrument type",
                    value: instrument['instrumentType'],
                    onChanged: (val) {
                      setState(() {
                        instrument['instrumentType'] = val;
                      });
                    },
                    mandatoryField: mandatoryFields,
                  ),
                  CustomInputField(
                    maxLines: 1,
                    view: view,
                    maxLength: 12,
                    title: 'Instrument Number',
                    hintText: "Enter Instrument Number",
                    controller: instrumentNumber,
                    onChanged: (val) {
                      setState(() {
                        instrumentNumber.text = val;
                      });
                    },
                    // mandatoryFields: checkInstrumentNo,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please Enter the Instrument Number';
                      } else if (int.parse(value) == 0) {
                        return 'Instrument Number cannot be zero';
                      }
                      return null;
                    },
                  ),
                  CustomInputField(
                    maxLines: 1,
                    view: view,
                    maxLength: 9,
                    title: 'Instrument Amount',
                    hintText: "Enter Instrument Amount",
                    controller: instrumentAmount,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onChanged: (val) {
                      setState(() {
                        instrumentAmount.text = val;
                      });
                    },
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please Enter the Instrument Amount';
                      } else if (int.parse(value) == 0) {
                        return 'Instrument amount cannot be zero';
                      }
                      return null;
                    },
                    // mandatoryFields: mandatoryFields,
                  ),
                  DatePickerFormField(
                    disabled: view,
                    labelText: 'Select Date',
                    onChanged: (DateTime? value) {
                      setState(() {
                        instrument['instrumentDate'] =
                            DateFormat('yyyy-MM-dd').format(value as DateTime);
                      });
                    },
                    date: instrument['instrumentDate'],
                    // mandatoryField: mandatoryFields,
                  ),
                ],
              ),
              index > 0
                  ? Positioned(
                      right: 20,
                      // bottom: -2,
                      child: Container(
                        padding: const EdgeInsets.all(1),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color.fromARGB(255, 196, 52, 42),
                        ),
                        child: IconButton(
                            onPressed: () => _removeInstrument(index),
                            icon: const Icon(Icons.delete_forever_rounded,
                                size: 18, color: Colors.white)),
                      ),
                    )
                  : const SizedBox.shrink(),
              widget.isView == false && index == 0
                  ? Positioned(
                      right: 20,
                      child: Container(
                        padding: const EdgeInsets.all(1),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color.fromRGBO(143, 19, 168, 1),
                        ),
                        child: IconButton(
                            onPressed: () {
                              _addInstrument();
                            },
                            icon: const Icon(Icons.add,
                                size: 16, color: Colors.white)),
                      ),
                    )
                  : const SizedBox.shrink(),
            ],
          ),
        ]),
      ],
    );
  }

  getProposalProductList() async {
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
          'https://uatcld.sbigeneral.in/SecureApp/inwardProducts',
          options: Options(headers: headers));
      var data = jsonDecode(response.data);

      setState(() {
        products = List.from(data);
      });
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print(e);
      print('not received');
    }
  }

  getProposalProductDetail() async {
    setState(() {
      isLoading = true;
    });
    SharedPreferences prefs = await _prefs;
    var token = prefs.getString('token') ?? '';
    final appState = Provider.of<AppState>(context, listen: false);
    Map<String, dynamic> postData = {"productName": selectedProduct};
    Map<String, String> headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      "Accept": "application/json",
      "Authorization": appState.accessToken
    };
    try {
      final response = await dio.post(
          'https://uatcld.sbigeneral.in/SecureApp/inwardProducts/productDetails',
          data: postData,
          options: Options(headers: headers));
      var data = jsonDecode(response.data);
      setState(() {
        productType = data['product_type'];
      });
      setState(() {
        isLoading = false;
      });
      print(data);
    } catch (e) {
      print(e);
      setState(() {
        isLoading = false;
      });
      print('not received');
    }
  }

  checkEndorsementType(product) async {
    setState(() {
      isLoading = true;
    });
    SharedPreferences prefs = await _prefs;
    var token = prefs.getString('token') ?? '';
    final appState = Provider.of<AppState>(context, listen: false);
    Map<String, dynamic> postData = {"productName": product};
    Map<String, String> headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      "Accept": "application/json",
      "Authorization": appState.accessToken
    };
    try {
      final response = await dio.post(
          'https://uatcld.sbigeneral.in/SecureApp/check-product',
          data: postData,
          options: Options(headers: headers));
      var data = jsonDecode(response.data);
      print(data);
      setState(() {
        requestType = data["requestorTypeAvailable"].toString();
        // salesEmailController.text = appState.email ?? '';
      });
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('not received');
    }
  }

  getEndorsementProductList() async {
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
          'https://uatcld.sbigeneral.in/SecureApp/endorsementProducts',
          options: Options(headers: headers));
      var data2 = jsonDecode(response.data);
      setState(() {
        products = List.from(data2);
      });
    } catch (e) {
      print('not received');
    }
  }

  // getEndorsementProductDetail() async {
  //   SharedPreferences prefs = await _prefs;
  //   var token = prefs.getString('token') ?? '';
  //   Map<String, dynamic> postData = {"productName": selectedProduct};
  //   Map<String, String> headers = {
  //     'Content-Type': 'application/json; charset=UTF-8',
  //     "Accept": "application/json",
  //     "Authorization": appState.accessToken
  //   };
  //   try {
  //     final response = await dio.post(
  //         'https://uatcld.sbigeneral.in/SecureApp/endorsementProducts/productDetails',
  //         data: postData,
  //         options: Options(headers: headers));
  //     var data = jsonDecode(response.data);
  //     print(data);
  //   } catch (e) {
  //     print(e);
  //     print('not received');
  //   }
  // }

  getEndorsementType(requestType) async {
    setState(() {
      isLoading = true;
    });
    SharedPreferences prefs = await _prefs;
    var token = prefs.getString('token') ?? '';
    final appState = Provider.of<AppState>(context, listen: false);
    Map<String, dynamic> postData = {
      "productName": selectedProduct,
      "requestorType": requestType
    };
    Map<String, String> headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      "Accept": "application/json",
      "Authorization": appState.accessToken
    };
    try {
      final response = await dio.post(
          'https://uatcld.sbigeneral.in/SecureApp/endorsementDetails/endorsementType',
          data: postData,
          options: Options(headers: headers));
      var data = jsonDecode(response.data);
      print(data['endtType']);
      setState(() {
        endorsementType = List.from(data['endtType']);
        paymentMode = List.from(data['paymentMode']);
        refundType = List.from(data['refundType']);
        if (selectedEndorsementRequestType == 'Cancellation & Refund') {
          refundReason = List.from(data['refundReason']);
        }
      });
      setState(() {
        isLoading = false;
      });
      print(data);
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print(e);
      print('not received');
    }
  }

  getEndorsementSubType() async {
    setState(() {
      isLoading = true;
    });
    SharedPreferences prefs = await _prefs;
    var token = prefs.getString('token') ?? '';
    Map<String, dynamic> postData = {
      "productName": selectedProduct,
      "endtType": selectedEndorsementType,
      "requestorType": selectedEndorsementRequestType
    };
    print(postData);
    final appState = Provider.of<AppState>(context, listen: false);
    Map<String, String> headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      "Accept": "application/json",
      "Authorization": appState.accessToken
    };
    try {
      final response = await dio.post(
          'https://uatcld.sbigeneral.in/SecureApp/endorsementDetails/endorsementSubType',
          data: postData,
          options: Options(headers: headers));
      var data = jsonDecode(response.data);
      setState(() {
        endorsementSubType = List.from(data);
      });
      setState(() {
        isLoading = false;
      });
      print(data);
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print(e);
      print('not received');
    }
  }

  // getPolicyDetails(policyNumber) async {
  //   // final appState = Provider.of<AppState>(context, listen: false);
  //   // Map<String, String> headers = {
  //   //   'Content-Type': 'application/json; charset=UTF-8',
  //   //   "Accept": "application/json",
  //   // };
  //   print("policy no: ${policyNumber}");
  //   try {
  //     final response = await dio.post(
  //       'http://172.18.115.105:7003/SECUREAPI/getPolicyInfo',
  //       data: policyNumber,
  //     );
  //     var data = jsonDecode(response.data);
  //     print(data);
  //     setState(() {
  //       verifyPolicy = true;
  //     });
  //   } catch (e) {
  //     print(e);
  //     print('not received');
  //     setState(() {
  //       verifyPolicy = false;
  //     });
  //     return showDialog<void>(
  //         context: context,
  //         builder: (BuildContext context) {
  //           return AlertDialog(
  //             title: Text(
  //               'Policy No.$policyNumber not found!',
  //               style: const TextStyle(fontSize: 15, color: Colors.black),
  //             ),
  //             content: Text(
  //               "No details found against Policy No.$policyNumber. Please enter correct policy number.",
  //               style: const TextStyle(fontSize: 12, color: Colors.black54),
  //             ),
  //             actions: <Widget>[
  //               TextButton(
  //                 child: const Text('Ok'),
  //                 onPressed: () {
  //                   Navigator.of(context).pop();
  //                 },
  //               ),
  //             ],
  //           );
  //         });
  //   }
  // }

  getPolicyDetails(policyNo) async {
    final appState = Provider.of<AppState>(context, listen: false);
    // Map<String, String> headers = {
    //   'Content-Type': 'application/json; charset=UTF-8',
    //   "Accept": "application/json",
    // };
    try {
      setState(() {
        isLoading = true;
      });
      final response = await dio.post(
          'https://ansappsuat.sbigen.in/SECUREAPI/getPolicyInfo',
          data: policyNo

          // options: Options(headers: headers)
          );
      print("Sameer");
      print(response);
      // var data = response;
      var data = jsonDecode(response.data);
      print(data);
      // String policyNumber = data['policyDetails'][0][''];

      // calling api to get SP Code based on agreement code

      // print("The policy number is " + policyNumber);/

      setState(() {
        //      data['policyDetails'][0][''];
        // customerNameController.text = data['policyDetails'][0]['policyHolderName'];
        // selectedProduct = data['policyDetails'][0]['productName'];
        // sbiBranchController.text=data['policyDetails'][0]['branchCode'];
        // // agreementCodeController.text = data[0]['AGREEMENT_CODE'];
        // productController.text = data[0]['PRODUCT_NAME'];
        // mobileNumberController.text = data['policyDetails'][0]['mobileNumber'];
        // emailIdController.text = data[0]['email'];
        // // salesEmailController.text=data[0][]
        // secondarySalesNameController.text =
        //     data[0]['SECONDARY_SALES_MANAGER_NAME'];
        // secondarySalesCodeController.text =
        //     data[0]['SECONDARY_SALES_MANAGER_CODE'];
        // // agreementCodeController.text=data[0]['AGREEMENT_CODE'];
        // // intermediaryNameController.text=data[0]['INTERMEDIARY_NAME'];
        // // intermediaryCodeController.text=data[0]['intermediary_CODE'];
        // // sbiBranchController.text=data[0]['sbi_BRANCH'];
        customerNameController.text = data[0]['CUSTOMER_NAME'] ?? '';
        selectedProduct = data[0]['PRODUCT_NAME'] ?? '';
        agreementCodeController.text = data[0]['AGREEMENT_CODE'] ?? '';
        productController.text = data[0]['PRODUCT_NAME'] ?? '';
        mobileNumberController.text = data[0]['Customer_MobileNumber'] ?? '';
        customerEmailController.text = data[0]['Customer_EmailId'] ?? '';
        salesEmailController.text = data[0]["sales_MANAGER_EMAIL_ID"] ?? '';
        secondarySalesNameController.text =
            data[0]['SECONDARY_SALES_MANAGER_NAME'] ?? '';
        secondarySalesCodeController.text =
            data[0]['SECONDARY_SALES_MANAGER_CODE'] ?? '';
        agreementCodeController.text = data[0]['AGREEMENT_CODE'] ?? '';
        intermediaryNameController.text = data[0]['INTERMEDIARY_NAME'] ?? '';
        intermediaryCodeController.text = data[0]['intermediary_CODE'] ?? '';
        sbiBranchController.text = data[0]['sbi_BRANCH'] ?? '';
      });

      setState(() {
        verifyPolicy = true;
      });

      setState(() {
        isLoading = false;
        viewDetails = true;
      });
      print("producttt" + data[0]['PRODUCT_NAME']);
      checkEndorsementType(data[0]['PRODUCT_NAME']);
    } catch (e) {
      print(e);
      setState(() {
        isLoading = false;
      });
      setState(() {
        verifyPolicy = false;
      });
      return showDialog<void>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(
                'Policy No.$policyNo not found!',
                style: const TextStyle(fontSize: 15, color: Colors.black),
              ),
              content: Text(
                "No details found against Policy No.$policyNo. Please enter correct policy number.",
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Ok'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          });
      print(e);
      print('not received');
    }
  }

  void mandatoryField() {
    if (policyNumberController.text.isEmpty ||
        instrumentAmountController.text.isEmpty ||
        instrumentNumberController.text.isEmpty ||
        // proposedDate.isEmpty &&
        // instrumentDate.isEmpty &&
        selectedInstrumentType == null) {
      setState(() {
        mandatoryFields = true;
      });
    } else {
      setState(() {
        mandatoryFields = false;
      });
      // if (widget.isView) {
      //   _viewForm();
      // } else {
      //   _submitForm();
      // }
    }
    ;
  }

  void resetVariables() {
    if (widget.isEdit == false) {
      setState(() {
        instruments = [
          {
            'instrumentType': null,
            'instrumentNumber': '',
            'instrumentAmount': '',
            'instrumentDate': DateFormat('yyyy-MM-dd').format(DateTime.now()),
          }
        ];
        instrumentAmounts = [TextEditingController()];
        instrumentNumbers = [TextEditingController()];
        customerNameController = TextEditingController();
        previousPolicyController = TextEditingController();
        premiumAmountController = TextEditingController();
        selectedCode = null;
        agreementCodeController = TextEditingController();
        _modeOfSubmission1 = 'Digital';
        instrumentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
        proposedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
        _coInsurance = null;
        _PPHC = null;
        customerType = null;
        leadType = null;
        selectedProduct = null;
        selectedProposal = null;
        selectedSPCode = null;
        selectedBranch = null;
        selectedSBIGBranch = null;
        selectedInstrumentType = null;
        selectedEndorsementRequestType = null;
        selectedEndorsementType = null;
        selectedEndorsementSubType = null;
        salesEmailController = TextEditingController();
        salesMobileController = TextEditingController();
        policyNumberController = TextEditingController();
        quoteNumberController = TextEditingController();
        portalPolicyNumberController = TextEditingController();
        premiumCollectedController = TextEditingController();
        referenceNumberController = TextEditingController();
        sbigAccountNumberController = TextEditingController();
        paymentModeController = TextEditingController();
        amountController = TextEditingController();
        accountHolderNameController = TextEditingController();
        accountNumberController = TextEditingController();
        ifscController = TextEditingController();
        accountTypeController = TextEditingController();
        refundAmountController = TextEditingController();
        customerAccountController = TextEditingController();
        requesterRemarkController = TextEditingController();
        oldValueController = TextEditingController();
        policyIssueDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
        transactionDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
        requestReceivedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
        selectedPaymentMode = null;
        selectedRefundReason = null;
        selectedRefundType = null;
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      if (customerType == null) {
        if (_inwardType == 'Endorsement' ||
            _inwardType == 'Miscellaneous' ||
            _inwardType == 'Replenishment') {
          if (widget.isEdit || propProposalId != null) {
            editProposal();
          } else {
            uploadProposal(context);
          }
        } else {
          if (_modeOfSubmission1 == 'Digital') {
            if (customerTypeRejectionList.contains(selectedProduct)) {
              if (widget.isEdit || propProposalId != null) {
                editProposal();
              } else {
                uploadProposal(context);
              }
            } else {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: const Text("Please select customer type"),
                  action: SnackBarAction(
                    label: ' Cancel',
                    onPressed: () {},
                  )));
            }
          } else {
            if (widget.isEdit || propProposalId != null) {
              editProposal();
            } else {
              uploadProposal(context);
            }
          }
        }
      } else {
        customerType == 'Individual'
            ? widget.isEdit || propProposalId != null
                ? editProposal()
                : uploadProposal(context)
            : widget.isEdit || propProposalId != null
                ? editProposal()
                : uploadProposal(context);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text("Please fill all the mandatory fields!"),
          action: SnackBarAction(
            label: ' Cancel',
            onPressed: () {},
          )));
    }
  }

  uploadProposal(context) async {
    print("uploaded proposal");
    print(propProposalId);
    List finalInstruments = [];
    var i = 0;
    finalInstruments = instruments.map((e) {
      var instrumentAmount = instrumentAmounts[i];
      var instrumentNumber = instrumentNumbers[i];
      i = i + 1;
      return {
        "instrumentType": e['instrumentType'],
        "instrumentAmount": instrumentAmount.text,
        "instrumentNumber": instrumentNumber.text,
        "instrumentDate": e['instrumentDate']
      };
    }).toList();
    Map inwardData = {
      "is_bulk": 0,
      "final_submitted": 0,
      "inward_type": _inwardType,
      "inward_proposal_type":
          _inwardType == 'Proposal' ? selectedProposal : null,
      "submission_mode": _modeOfSubmission1 == 'Digital' ? 'online' : 'offline',
      "product": selectedProduct,
      "agreement_code": selectedCode,
      "sp_code": selectedSPCode,
      "branch": selectedBranch,
      "sbigi_branch": selectedSBIGBranch,
      "simflo_id": '',
      "customer_name": customerNameController.text,
      "co_insurance": _coInsurance,
      "leader_follower_type": leadType,
      "pphc": _PPHC,
      "premium_amount": premiumAmountController.text,
      "assigned_branch": selectedSBIGBranch,
      "proposer_signed_date":
          _inwardType != 'Replenishment' ? proposedDate : null,
      'prev_policy_num': previousPolicyController.text,
      "portal_policy_no": _inwardType == 'Replenishment'
          ? portalPolicyNumberController.text
          : null,
      "portal_policy_issue_date":
          _inwardType == 'Replenishment' ? policyIssueDate : null,
      "assign_work_group": 4,
      "instruments": finalInstruments
    };
    Map financialDetails = {
      "premium_to_be_collected": premiumCollectedController.text,
      "premium_reference_number": referenceNumberController.text,
      "premium_SBIG_account_number": sbigAccountNumberController.text,
      "premium_amount": amountController.text,
      "premium_payment_mode": selectedPaymentMode,
      "premium_transaction_date": transactionDate,
    };
    Map refundDetails = {
      "reference_no": referenceNumberController.text,
      "transaction_date": transactionDate,
      "sbig_account_no": sbigAccountNumberController.text,
      "payment_mode": selectedPaymentMode,
      "refund_amount": refundAmountController.text,
    };
    Map details = {};
    if (selectedEndorsementRequestType == 'Financial Endorsement') {
      details = financialDetails;
    } else if (selectedEndorsementRequestType == 'Cancellation & Refund') {
      details = refundDetails;
    }

    Map endorsementData2 = {
      "product": selectedProduct,
      "proposalDetails": {
        "is_bulk": 0,
        "final_submitted": 0,
        "inward_type": _inwardType,
        "submission_mode":
            _modeOfSubmission1 == 'Digital' ? 'online' : 'offline',
        "product": selectedProduct,
        "agreement_code": selectedCode,
        "sp_code": selectedSPCode,
        "branch": selectedBranch,
        "sbigi_branch": selectedSBIGBranch,
        "simflo_id": '',
        "customer_name": customerNameController.text,
        "co_insurance": _coInsurance,
        "leader_follower_type": leadType,
        "pphc": _PPHC,
        "assigned_branch": selectedSBIGBranch,
        "premium_amount": premiumAmountController.text,
        "proposer_signed_date": proposedDate,
        "policy_no": policyNumberController.text,
        "quote_no": quoteNumberController.text,
        "policy_issue_date": policyIssueDate,
        "assign_work_group": 4,
        "instruments": finalInstruments
      },
      "endorsementDetails": {
        ...{
          "form_type": selectedEndorsementRequestType,
          "sub_type": selectedEndorsementSubType,
          "product": selectedProduct,
          "endorsement_type": selectedEndorsementType,
          "email": salesEmailController.text,
          "mobile": salesMobileController.text,
          "payment_mode": selectedPaymentMode,
          "refund_reason": selectedRefundReason,
          "refund_type": selectedRefundType,
          "refund_holder_name": accountHolderNameController.text,
          "refund_IFSC": ifscController.text,
          "refund_account_no": accountNumberController.text,
          "refund_account_type": accountTypeController.text,
          "branch_name": selectedBranch,
          "policy_number": policyNumberController.text,
          "remark": requesterRemarkController.text,
          "req_receive_date": requestReceivedDate,
          "old_value": oldValueController.text,
        },
        ...details,
        ...endorsementData!['endorsement'],
      },
    };
    // print(inwardData);
    print(endorsementData);
    print(endorsementData2);

    String resultEndorsement = aesGcmEncryptJson(jsonEncode(endorsementData2));
    String resultProposal = aesGcmEncryptJson(jsonEncode(inwardData));

    Map<String, dynamic> encryptedEndorsementData = {
      'encryptedData': resultEndorsement
    };
    Map<String, dynamic> encryptedProposalData = {
      'encryptedData': resultProposal
    };
    print(encryptedProposalData);
    SharedPreferences prefs = await _prefs;
    var token = prefs.getString('token') ?? '';
    final appState = Provider.of<AppState>(context, listen: false);
    Map<String, String> headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      "Accept": "application/json",
      "Authorization": appState.accessToken
    };
    String sendDetails = 'proposalDetails';
    if (_inwardType == 'Endorsement') {
      sendDetails = 'endorsementDetails';
    }
    try {
      print('api');
      final response = await dio.post(
          'https://uatcld.sbigeneral.in/SecureApp/$sendDetails',
          data: _inwardType == 'Endorsement'
              ? encryptedEndorsementData
              : encryptedProposalData,
          options: Options(headers: headers));
      print(response.data);
      String decryptedData = aesGcmDecryptJson(response.data);

      var data = jsonDecode(decryptedData);
      // var data = const JsonDecoder().convert(jsonMap);

      // final Map<String, dynamic> data = jsonDecode(response.data);

      final appState = Provider.of<AppState>(context, listen: false);
      appState.updateVariables(
        proposalId: data['proposal']['id'],
      );
      if ((customerTypeRejectionList.contains(selectedProduct) == true)) {
        customerType = null;
      }

      if (_formKey.currentState!.validate()) {
        setState(() {
          propProposalId = data['proposal']['id'];
        });
        print(propProposalId);
        if (customerType == null) {
          if (_inwardType == 'Endorsement' ||
              _inwardType == 'Miscellaneous' ||
              _inwardType == 'Replenishment') {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ProposalDocuments(
                          inwardData: _inwardType == 'Endorsement'
                              ? endorsementData2
                              : inwardData,
                          inwardType: _inwardType,
                          ckycData: null,
                          ckycDocuments: null,
                          isEdit: widget.isEdit,
                        )));
          } else {
            if (_modeOfSubmission1 == 'Digital') {
              if (customerTypeRejectionList.contains(selectedProduct)) {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ProposalDocuments(
                              inwardData: inwardData,
                              inwardType: _inwardType,
                              ckycData: null,
                              ckycDocuments: null,
                              isEdit: widget.isEdit,
                            )));
              } else {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: const Text("Please select customer type"),
                    action: SnackBarAction(
                      label: ' Cancel',
                      onPressed: () {},
                    )));
              }
            } else {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ProposalDocuments(
                            inwardData: inwardData,
                            inwardType: _inwardType,
                            ckycData: null,
                            ckycDocuments: null,
                            isEdit: widget.isEdit,
                          )));
            }
          }
        } else {
          customerType == 'Individual'
              ? Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => KYCIndividual(
                            inwardData: _inwardType == 'Endorsement'
                                ? endorsementData2
                                : inwardData,
                            inwardType: _inwardType,
                            isEdit: widget.isEdit,
                            // edit: false,
                          )))
              : Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => KYCForm(
                            inwardData: _inwardType == 'Endorsement'
                                ? endorsementData2
                                : inwardData,
                            inwardType: _inwardType,
                            isEdit: widget.isEdit,
                            // edit: false,
                          )));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: const Text("Please fill all the mandatory fields!"),
            action: SnackBarAction(
              label: ' Cancel',
              onPressed: () {},
            )));
      }
    } catch (e) {
      print(e);
    }
  }

  editProposal() async {
    print("edit proposal");
    List finalInstruments = [];
    var i = 0;
    final appState = Provider.of<AppState>(context, listen: false);
    var proposalId = appState.proposalId;
    finalInstruments = instruments.map((e) {
      var instrumentAmount = instrumentAmounts[i];
      var instrumentNumber = instrumentNumbers[i];
      i = i + 1;
      return {
        "instrumentType": e['instrumentType'],
        "instrumentAmount": instrumentAmount.text,
        "instrumentNumber": instrumentNumber.text,
        "instrumentDate": e['instrumentDate']
      };
    }).toList();
    Map inwardData = {
      "is_bulk": 0,
      "final_submitted": 0,
      "proposal_id": proposalId,
      "inward_type": _inwardType,
      "inward_proposal_type":
          _inwardType == 'Proposal' ? selectedProposal : null,
      "submission_mode": _modeOfSubmission1 == 'Digital' ? 'online' : 'offline',
      "product": selectedProduct,
      "agreement_code": selectedCode,
      "sp_code": '',
      "branch": selectedBranch,
      "sbigi_branch": selectedSBIGBranch,
      "simflo_id": '',
      "customer_name": customerNameController.text,
      "co_insurance": _coInsurance,
      "leader_follower_type": leadType,
      "pphc": _PPHC,
      "premium_amount": premiumAmountController.text,
      "assigned_branch": selectedSBIGBranch,
      'prev_policy_num':
          selectedProposal == 'Renewal' ? previousPolicyController.text : null,
      "proposer_signed_date":
          _inwardType != 'Replenishment' ? proposedDate : null,
      "portal_policy_no": _inwardType == 'Replenishment'
          ? portalPolicyNumberController.text
          : null,
      "portal_policy_issue_date":
          _inwardType == 'Replenishment' ? policyIssueDate : null,
      "assign_work_group": 4,
      "instruments": finalInstruments
    };
    Map financialDetails = {
      "premium_to_be_collected": premiumCollectedController.text,
      "premium_reference_number": referenceNumberController.text,
      "premium_SBIG_account_number": sbigAccountNumberController.text,
      "premium_amount": amountController.text,
      "premium_payment_mode": selectedPaymentMode,
      "premium_transaction_date": transactionDate,
    };
    Map refundDetails = {
      "reference_no": referenceNumberController.text,
      "transaction_date": transactionDate,
      "sbig_account_no": sbigAccountNumberController.text,
      "payment_mode": selectedPaymentMode,
      "refund_amount": refundAmountController.text,
    };
    Map details = {};
    if (selectedEndorsementRequestType == 'Financial Endorsement') {
      details = financialDetails;
    } else if (selectedEndorsementRequestType == 'Cancellation & Refund') {
      details = refundDetails;
    }
    Map endorsementData2 = {
      "product": selectedProduct,
      "proposal_id": proposalId,
      "proposalDetails": {
        "is_bulk": 0,
        "final_submitted": 0,
        "inward_type": _inwardType,
        "submission_mode":
            _modeOfSubmission1 == 'Digital' ? 'online' : 'offline',
        "product": selectedProduct,
        "agreement_code": selectedCode,
        "sp_code": selectedSPCode,
        "branch": selectedBranch,
        "sbigi_branch": selectedSBIGBranch,
        "simflo_id": '',
        "customer_name": customerNameController.text,
        "co_insurance": _coInsurance,
        "leader_follower_type": leadType,
        "pphc": _PPHC,
        "assigned_branch": selectedSBIGBranch,
        "premium_amount": premiumAmountController.text,
        "policy_no": policyNumberController.text,
        "quote_no": quoteNumberController.text,
        'prev_policy_num': selectedProposal == 'Renewal'
            ? previousPolicyController.text
            : null,
        "proposer_signed_date":
            _inwardType != 'Replenishment' ? proposedDate : null,
        "portal_policy_no": _inwardType == 'Replenishment'
            ? portalPolicyNumberController.text
            : null,
        "portal_policy_issue_date":
            _inwardType == 'Replenishment' ? policyIssueDate : null,
        "assign_work_group": 4,
        "instruments": finalInstruments
      },
      "endorsementDetails": {
        ...endorsementData!['endorsement'],
        ...{
          "form_type": selectedEndorsementRequestType,
          "sub_type": selectedEndorsementSubType,
          "product": selectedProduct,
          "endorsement_type": selectedEndorsementType,
          "email": salesEmailController.text,
          "mobile": salesMobileController.text,
          "payment_mode": selectedPaymentMode,
          "refund_reason": selectedRefundReason,
          "refund_type": selectedRefundType,
          "refund_holder_name": accountHolderNameController.text,
          "refund_IFSC": ifscController.text,
          "refund_account_no": accountNumberController.text,
          "refund_account_type": accountTypeController.text,
          "branch_name": selectedBranch,
          "policy_number": policyNumberController.text,
          "remark": requesterRemarkController.text,
          "req_receive_date": requestReceivedDate,
          "old_value": oldValueController.text,
        },
        ...details,
      },
    };

    print('editing');
    print(inwardData);
    print(endorsementData);
    print(endorsementData2);

    String resultEndorsement = aesGcmEncryptJson(
      jsonEncode({'proposal_id': proposalId, ...endorsementData2}),
    );
    String resultProposal = aesGcmEncryptJson(
        jsonEncode({'proposal_id': proposalId, ...inwardData}));

    Map<String, dynamic> encryptedEndorsementData = {
      'encryptedData': resultEndorsement
    };
    Map<String, dynamic> encryptedProposalData = {
      'encryptedData': resultProposal
    };
    setState(() {
      isLoading = true;
    });
    SharedPreferences prefs = await _prefs;
    var token = prefs.getString('token') ?? '';
    Map<String, String> headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      "Accept": "application/json",
      "Authorization": appState.accessToken
    };
    print('type');

    String sendDetails = 'proposalDetails/update';
    if (_inwardType == 'Endorsement') {
      sendDetails = 'updateEndorsementDetails';
    }
    try {
      final response = await dio.post(
          'https://uatcld.sbigeneral.in/SecureApp/$sendDetails',
          data: _inwardType == 'Endorsement'
              ? encryptedEndorsementData
              : encryptedProposalData,
          options: Options(headers: headers));
      print(response);
      String decryptedData = aesGcmDecryptJson(response.data);
      print(decryptedData);
      var data = jsonDecode(decryptedData);
      // var data = const JsonDecoder().convert(jsonMap);

      // final Map<String, dynamic> data = jsonDecode(response.data);

      if (data['proposal']['ckyc_exist'] == 'Y') {
        edit = true;
      } else if (data['proposal']['ckyc_exist'] == null) {
        edit = false;
      }
      if ((customerTypeRejectionList.contains(selectedProduct) == true)) {
        customerType = null;
      }
      setState(() {
        if (_formKey.currentState!.validate()) {
          if (customerType == null) {
            if (_inwardType == 'Endorsement' ||
                _inwardType == 'Miscellaneous' ||
                _inwardType == 'Replenishment') {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ProposalDocuments(
                            inwardData: _inwardType == 'Endorsement'
                                ? endorsementData2
                                : inwardData,
                            inwardType: _inwardType,
                            ckycData: null,
                            ckycDocuments: null,
                            isEdit: widget.isEdit,
                          )));
            } else {
              if (_modeOfSubmission1 == 'Digital') {
                if (customerTypeRejectionList.contains(selectedProduct)) {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ProposalDocuments(
                                inwardData: inwardData,
                                inwardType: _inwardType,
                                ckycData: null,
                                ckycDocuments: null,
                                isEdit: widget.isEdit,
                              )));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: const Text("Please select customer type"),
                      action: SnackBarAction(
                        label: ' Cancel',
                        onPressed: () {},
                      )));
                }
              } else {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ProposalDocuments(
                              inwardData: inwardData,
                              inwardType: _inwardType,
                              ckycData: null,
                              ckycDocuments: null,
                              isEdit: widget.isEdit,
                            )));
              }
            }
          } else {
            customerType == 'Individual'
                ? Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => KYCIndividual(
                              inwardData: _inwardType == 'Endorsement'
                                  ? endorsementData2
                                  : inwardData,
                              inwardType: _inwardType,
                              isEdit: widget.isEdit,
                              // edit: customerType == appState.typeOfCustomer
                              //     ? true
                              //     : false,
                            )))
                : Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => KYCForm(
                              inwardData: _inwardType == 'Endorsement'
                                  ? endorsementData2
                                  : inwardData,
                              inwardType: _inwardType,
                              isEdit: widget.isEdit,
                              // edit: customerType == appState.typeOfCustomer
                              //     ? true
                              //     : false,
                            )));
          }
          setState(() {
            propProposalId = data['proposal']['id'];
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: const Text("Please fill all the mandatory fields!"),
              action: SnackBarAction(
                label: ' Cancel',
                onPressed: () {},
              )));
        }
      });
      setState(() {
        isLoading = false;
      });
    } on DioException catch (error) {
      setState(() {
        isLoading = false;
      });
      print(error);
      print(error.message);
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text("Form not submitted. Try again!"),
          action: SnackBarAction(
            label: ' Cancel',
            onPressed: () {},
          )));
    }
  }

  _viewForm() {
    var viewInwardData = {"product": selectedProduct};
    if ((customerTypeRejectionList.contains(selectedProduct) == true)) {
      customerType = null;
    }
    if (customerType == null) {
      if (_inwardType == 'Endorsement' ||
          _inwardType == 'Miscellaneous' ||
          _inwardType == 'Replenishment') {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ProposalDocuments(
                      inwardData: viewInwardData,
                      inwardType: _inwardType,
                      ckycData: null,
                      ckycDocuments: null,
                      isView: true,
                    )));
      } else {
        if (_modeOfSubmission1 == 'Digital') {
          if (customerTypeRejectionList.contains(selectedProduct)) {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ProposalDocuments(
                          inwardData: viewInwardData,
                          inwardType: _inwardType,
                          ckycData: null,
                          ckycDocuments: null,
                          isView: true,
                        )));
          } else {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: const Text("Please select customer type"),
                action: SnackBarAction(
                  label: ' Cancel',
                  onPressed: () {},
                )));
          }
        } else {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ProposalDocuments(
                        inwardData: viewInwardData,
                        inwardType: _inwardType,
                        ckycData: null,
                        ckycDocuments: null,
                        isView: true,
                      )));
        }
      }
    } else {
      customerType == 'Individual'
          ? Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => KYCIndividual(
                        inwardData: viewInwardData,
                        inwardType: _inwardType,
                        isView: true,
                      )))
          : Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => KYCForm(
                        inwardData: viewInwardData,
                        inwardType: _inwardType,
                        isView: true,
                      )));
    }
  }

  @override
  void dispose() {
    agreementCodeController.dispose();
    super.dispose();
  }

  getEndorsementValues(Map endorsementDetails) {
    Map<String, dynamic> combinedMap = {
      ...endorsementData!['endorsement'],
      ...endorsementDetails
    };
    print(combinedMap);
    setState(() {
      endorsementData!['endorsement'] = combinedMap;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: GradientText(
                widget.isView || widget.isEdit
                    ? 'Inward No : ${widget.proposalId}'
                    : 'Create Endorsement',
                colors: const [
                  Color.fromRGBO(176, 34, 204, 1),
                  Color.fromRGBO(176, 34, 204, 1),
                  // Color.fromRGBO(13, 154, 189, 1),
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
          ),
          body: Stack(
            children: [
              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // _heightGap(),
                        // _heightGap(),
                        CustomInputContainer(children: [
                          _heightGap(),
                          Wrap(
                            spacing: 20,
                            // runSpacing: 5,
                            alignment: WrapAlignment.start,
                            crossAxisAlignment: WrapCrossAlignment.start,
                            children: [
                              // DropdownWidget(
                              //   view: view,
                              //   label: 'Inward Type',
                              //   items: inwardType,
                              //   hintText: "Please Select Inward Type",
                              //   value: _inwardType,
                              //   onChanged: (val) {
                              //     if (val != _inwardType) {
                              //       resetVariables();
                              //       dynamicForm = const SizedBox.shrink();
                              //     }
                              //     setState(() {
                              //       print(val);
                              //       _inwardType = val;
                              //     });
                              //     getProposalProductList();
                              //   },
                              // ),
                              SizedBox(
                                width: 250,
                                child: Column(
                                  children: [
                                    CustomInputField(
                                      view: viewDetails,
                                      inputFormatters: <TextInputFormatter>[
                                        FilteringTextInputFormatter.allow(
                                            RegExp("[a-zA-Z0-9-_]")),
                                      ],
                                      title: 'Policy Number',
                                      hintText: 'Please enter Policy Number',
                                      controller: policyNumberController,
                                      validator: Validators.formValidation,
                                      mandatoryFields: checkPolicyNo,
                                      verifyButton: verifyPolicy
                                          ? const SizedBox(
                                              height: 14,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                children: [
                                                  Text(
                                                    'Verified ',
                                                    style: TextStyle(
                                                        color: Colors.green,
                                                        fontSize: 12),
                                                  ),
                                                  Icon(
                                                    Icons.check_circle,
                                                    color: Colors.green,
                                                    size: 16,
                                                  )
                                                ],
                                              ),
                                            )
                                          : SizedBox(
                                              height: 14,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                children: [
                                                  TextButton(
                                                      onPressed: () {
                                                        getPolicyDetails(
                                                            policyNumberController
                                                                .text);
                                                      },
                                                      child: const Text(
                                                        'Verify Policy!',
                                                        style: TextStyle(
                                                            color: Colors.blue,
                                                            fontSize: 12),
                                                      )),
                                                ],
                                              ),
                                            ),
                                    ),
                                  ],
                                ),
                              ),
                              CustomInputField(
                                view: viewDetails,
                                maxLines: 1,
                                title: "Customer Name",
                                hintText: "Please enter customer name",
                                inputFormatters: <TextInputFormatter>[
                                  FilteringTextInputFormatter.allow(
                                      RegExp("[a-zA-Z ]")),
                                ],
                                controller: customerNameController,
                              ),
                              CustomInputField(
                                view: viewDetails,
                                maxLength: 9,
                                maxLines: 1,
                                title: "Mobile Number",
                                hintText: "Please enter mobile number",
                                controller: mobileNumberController,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly
                                ],
                              ),
                              CustomInputField(
                                view: viewDetails,
                                maxLines: 1,
                                title: "Email id",
                                hintText: "Please enter email id",
                                inputFormatters: <TextInputFormatter>[
                                  FilteringTextInputFormatter.allow(
                                      RegExp("[a-zA-Z ]")),
                                ],
                                controller: customerEmailController,
                              ),
                              CustomInputField(
                                view: viewDetails,
                                maxLines: 1,
                                title: "Product",
                                hintText: "Please select product ",
                                inputFormatters: <TextInputFormatter>[
                                  FilteringTextInputFormatter.allow(
                                      RegExp("[a-zA-Z ]")),
                                ],
                                controller: productController,
                              ),
                              CustomInputField(
                                view: viewDetails,
                                maxLines: 1,
                                title: "SM Name",
                                hintText: "Please enter SM Name",
                                inputFormatters: <TextInputFormatter>[
                                  FilteringTextInputFormatter.allow(
                                      RegExp("[a-zA-Z ]")),
                                ],
                                controller: secondarySalesNameController,
                              ),
                              CustomInputField(
                                view: viewDetails,
                                maxLines: 1,
                                title: "SM Code",
                                hintText: "Please enter SM Code",
                                inputFormatters: <TextInputFormatter>[
                                  FilteringTextInputFormatter.allow(
                                      RegExp("[a-zA-Z ]")),
                                ],
                                controller: secondarySalesCodeController,
                              ),
                              CustomInputField(
                                view: viewDetails,
                                maxLines: 1,
                                title: "SM Email Id",
                                hintText: "Please enter SM Email Id",
                                inputFormatters: <TextInputFormatter>[
                                  FilteringTextInputFormatter.allow(
                                      RegExp("[a-zA-Z ]")),
                                ],
                                controller: salesEmailController,
                              ),
                              // CustomInputField(
                              //   view: view,
                              //   maxLines: 1,
                              //   title: "SP Code",
                              //   hintText: "Please enter SP Code",
                              //   inputFormatters: <TextInputFormatter>[
                              //     FilteringTextInputFormatter.allow(
                              //         RegExp("[a-zA-Z ]")),
                              //   ],
                              //   controller: spCodeController,
                              // ),
                              CustomInputField(
                                view: viewDetails,
                                maxLines: 1,
                                title: "Transaction Branch",
                                hintText: "Please enter Transaction Branch",
                                inputFormatters: <TextInputFormatter>[
                                  FilteringTextInputFormatter.allow(
                                      RegExp("[a-zA-Z ]")),
                                ],
                                controller: sbiBranchController,
                              ),
                              CustomInputField(
                                view: viewDetails,
                                maxLines: 1,
                                title: "SBI Branch",
                                hintText: "Please enter SM Email Id",
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly
                                ],
                                controller: sbiBranchController,
                              ),
                              CustomInputField(
                                view: viewDetails,
                                maxLines: 1,
                                title: "Agreement Code",
                                hintText: "Please enter Agreement Code",
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly
                                ],
                                controller: agreementCodeController,
                              ),
                              CustomInputField(
                                view: viewDetails,
                                maxLines: 1,
                                title: "Intermediary Name",
                                hintText: "Please enter Intermediary Name",
                                inputFormatters: <TextInputFormatter>[
                                  FilteringTextInputFormatter.allow(
                                      RegExp("[a-zA-Z ]")),
                                ],
                                controller: intermediaryNameController,
                              ),
                              CustomInputField(
                                view: viewDetails,
                                maxLines: 1,
                                title: "Intermediary Code",
                                hintText: "Please enter Intermediary Code",
                                inputFormatters: <TextInputFormatter>[
                                  FilteringTextInputFormatter.allow(
                                      RegExp("[a-zA-Z ]")),
                                ],
                                controller: intermediaryCodeController,
                              ),
                              // CustomInputField(
                              //   view: view,
                              //   maxLines: 1,
                              //   title: "Premium Amount",
                              //   hintText: "Please enter Premium Amount",
                              //   inputFormatters: <TextInputFormatter>[
                              //     FilteringTextInputFormatter.allow(
                              //         RegExp("[a-zA-Z ]")),
                              //   ],
                              //   controller: premiumAmountController,
                              // ),
                              // DropdownWidget(
                              //   view: view,
                              //   label: 'Select Product',
                              //   items: products,
                              //   hintText: "Please select your",
                              //   value: selectedProduct,
                              //   onChanged: (val) {
                              //     setState(() {
                              //       selectedProduct = val;
                              //       dynamicForm = const SizedBox.shrink();
                              //       selectedEndorsementRequestType = null;
                              //       selectedEndorsementType = null;
                              //       selectedEndorsementSubType = null;
                              //       salesEmailController =
                              //           TextEditingController();
                              //       salesMobileController =
                              //           TextEditingController();
                              //       policyNumberController =
                              //           TextEditingController();
                              //       quoteNumberController =
                              //           TextEditingController();
                              //       ;
                              //       premiumCollectedController =
                              //           TextEditingController();
                              //       referenceNumberController =
                              //           TextEditingController();
                              //       sbigAccountNumberController =
                              //           TextEditingController();
                              //       paymentModeController =
                              //           TextEditingController();
                              //       amountController = TextEditingController();
                              //       accountHolderNameController =
                              //           TextEditingController();
                              //       accountNumberController =
                              //           TextEditingController();
                              //       ifscController = TextEditingController();
                              //       accountTypeController =
                              //           TextEditingController();
                              //       refundAmountController =
                              //           TextEditingController();
                              //       customerAccountController =
                              //           TextEditingController();
                              //       requesterRemarkController =
                              //           TextEditingController();
                              //       oldValueController =
                              //           TextEditingController();
                              //       if (widget.isEdit &&
                              //           _inwardType != 'Replenishment') {
                              //         portalPolicyNumberController =
                              //             TextEditingController();
                              //         policyIssueDate = DateFormat('yyyy-MM-dd')
                              //             .format(DateTime.now());
                              //       }

                              //       transactionDate = DateFormat('yyyy-MM-dd')
                              //           .format(DateTime.now());
                              //       requestReceivedDate =
                              //           DateFormat('yyyy-MM-dd')
                              //               .format(DateTime.now());
                              //       selectedPaymentMode = null;
                              //       selectedRefundReason = null;
                              //       selectedRefundType = null;
                              //     });

                              //     getProposalProductDetail();
                              //     checkEndorsementType();
                              //   },
                              // ),
                              // DropdownWidget(
                              //   view: view,
                              //   label: 'Mode of Submission',
                              //   items: mode,
                              //   hintText: "Please Select",
                              //   value: _modeOfSubmission1,
                              //   onChanged: (val) {
                              //     (value) {
                              //       setState(() {
                              //         _modeOfSubmission1 = val;
                              //       });
                              //     };
                              //   },
                              // ),

                              //     CommonFunction.agreementBlock(
                              //         context,
                              //         (value) {
                              //           setState(() {
                              //             selectedCode = value;
                              //           });
                              //         },
                              //         (value) {
                              //           setState(() {
                              //             selectedBranch = value;
                              //           });
                              //         },
                              //         (val) {
                              //           setState(() {
                              //             selectedSBIGBranch = val;
                              //           });
                              //         },
                              //         selectedCode,
                              //         selectedBranch,
                              //         selectedSBIGBranch,
                              //         agreementCodeController,
                              //         selectedSPCode,
                              //         (val) {
                              //           setState(() {
                              //             selectedSPCode = val;
                              //           });
                              //         },
                              //         view = view),
                            ],
                          ),
                          _heightGap(),
                        ]),

                        _heightGap(),
                        if (_inwardType == 'Endorsement' &&
                            selectedProduct != null &&
                            requestType == 'true')
                          CustomInputContainer(children: [
                            _heightGap(),
                            Wrap(
                              alignment: WrapAlignment.start,
                              crossAxisAlignment: WrapCrossAlignment.start,
                              spacing: 20,
                              // runSpacing: 15,
                              runAlignment: WrapAlignment.center,
                              children: [
                                DropdownWidget(
                                    view: view,
                                    label: 'Select Endorsement Request Type',
                                    items: endorsementRequestType,
                                    hintText:
                                        "Please select endorsement request type",
                                    value: selectedEndorsementRequestType,
                                    onChanged: (val) {
                                      setState(() {
                                        selectedEndorsementRequestType = val;
                                        if (requestType == 'true') {
                                          getEndorsementType(val);
                                        }
                                        dynamicForm = const SizedBox.shrink();
                                        selectedEndorsementType = null;
                                        selectedEndorsementSubType = null;
                                        // salesEmailController =
                                        //     TextEditingController();
                                        salesMobileController =
                                            TextEditingController();
                                        // policyNumberController =
                                        //     TextEditingController();
                                        quoteNumberController =
                                            TextEditingController();
                                        portalPolicyNumberController =
                                            TextEditingController();
                                        premiumCollectedController =
                                            TextEditingController();
                                        referenceNumberController =
                                            TextEditingController();
                                        sbigAccountNumberController =
                                            TextEditingController();
                                        paymentModeController =
                                            TextEditingController();
                                        amountController =
                                            TextEditingController();
                                        accountHolderNameController =
                                            TextEditingController();
                                        accountNumberController =
                                            TextEditingController();
                                        ifscController =
                                            TextEditingController();
                                        accountTypeController =
                                            TextEditingController();
                                        refundAmountController =
                                            TextEditingController();
                                        customerAccountController =
                                            TextEditingController();
                                        requesterRemarkController =
                                            TextEditingController();
                                        oldValueController =
                                            TextEditingController();
                                        policyIssueDate =
                                            DateFormat('yyyy-MM-dd')
                                                .format(DateTime.now());
                                        transactionDate =
                                            DateFormat('yyyy-MM-dd')
                                                .format(DateTime.now());
                                        requestReceivedDate =
                                            DateFormat('yyyy-MM-dd')
                                                .format(DateTime.now());
                                        selectedPaymentMode = null;
                                        selectedRefundReason = null;
                                        selectedRefundType = null;
                                      });
                                    }),
                                // CustomInputField(
                                //   view: view,
                                //   inputFormatters: <TextInputFormatter>[
                                //     FilteringTextInputFormatter.digitsOnly
                                //   ],
                                //   title: 'Policy Number',
                                //   hintText: 'Please enter Policy Number',
                                //   controller: policyNumberController,
                                //   validator: Validators.formValidation,
                                // ),
                                CustomInputField(
                                  view: view,
                                  maxLines: 1,
                                  // value: salesID,
                                  title: 'Sales Email ID',
                                  hintText: 'Please enter Sales Email ID',
                                  controller: salesEmailController,
                                  validator: Validators.emailValidator,
                                ),
                                CustomInputField(
                                  maxLines: 1,
                                  view: view,
                                  inputFormatters: <TextInputFormatter>[
                                    FilteringTextInputFormatter.digitsOnly
                                  ],
                                  maxLength: 10,
                                  title: 'Sales Mobile Number',
                                  hintText: 'Please enter Sales Mobile Number',
                                  controller: salesMobileController,
                                  validator: Validators.phoneNumberValidator,
                                ),
                                DatePickerFormField(
                                  disabled: view,
                                  labelText: 'Request Received Date',
                                  onChanged: (DateTime? value) {
                                    setState(() {
                                      requestReceivedDate =
                                          DateFormat('yyyy-MM-dd')
                                              .format(value as DateTime);
                                    });
                                  },
                                  date: requestReceivedDate,
                                ),
                                CustomInputField2(
                                  view: view,
                                  maxLines: 1,
                                  maxLength: 800,
                                  title: 'Requester Remarks',
                                  hintText: 'Please enter Requester Remarks',
                                  controller: requesterRemarkController,
                                  validator: Validators.formValidation,
                                ),
                                if (selectedEndorsementRequestType !=
                                        'Cancellation & Refund' &&
                                    selectedEndorsementRequestType != null)
                                  CustomInputField(
                                    view: view,
                                    inputFormatters: <TextInputFormatter>[
                                      FilteringTextInputFormatter.digitsOnly
                                    ],
                                    title: 'Quote Number',
                                    hintText: 'Please enter Quote Number',
                                    controller: quoteNumberController,
                                    validator: Validators.formValidation,
                                  ),
                                if (selectedEndorsementRequestType !=
                                        'Cancellation & Refund' &&
                                    selectedEndorsementRequestType != null)
                                  Wrap(
                                      spacing: 20,
                                      // runSpacing: 15,
                                      alignment: WrapAlignment.start,
                                      crossAxisAlignment:
                                          WrapCrossAlignment.start,
                                      children: [
                                        DropdownWidget(
                                            view: view,
                                            label: 'Select Endorsement Type',
                                            items: endorsementType,
                                            hintText:
                                                "Please select endorsement type",
                                            value: selectedEndorsementType,
                                            onChanged: (val) {
                                              setState(() {
                                                selectedEndorsementType = val;
                                                dynamicForm =
                                                    const SizedBox.shrink();
                                                selectedEndorsementSubType =
                                                    null;
                                                premiumCollectedController =
                                                    TextEditingController();
                                                referenceNumberController =
                                                    TextEditingController();
                                                sbigAccountNumberController =
                                                    TextEditingController();
                                                paymentModeController =
                                                    TextEditingController();
                                                amountController =
                                                    TextEditingController();
                                                accountHolderNameController =
                                                    TextEditingController();
                                                accountNumberController =
                                                    TextEditingController();
                                                ifscController =
                                                    TextEditingController();
                                                accountTypeController =
                                                    TextEditingController();
                                                refundAmountController =
                                                    TextEditingController();
                                                customerAccountController =
                                                    TextEditingController();

                                                oldValueController =
                                                    TextEditingController();
                                                policyIssueDate =
                                                    DateFormat('yyyy-MM-dd')
                                                        .format(DateTime.now());
                                                transactionDate =
                                                    DateFormat('yyyy-MM-dd')
                                                        .format(DateTime.now());

                                                selectedPaymentMode = null;
                                                selectedRefundReason = null;
                                                selectedRefundType = null;
                                              });
                                              getEndorsementSubType();
                                            }),
                                        DropdownWidget(
                                            view: view,
                                            label:
                                                'Select Endorsement Sub-Type',
                                            items: endorsementSubType,
                                            hintText:
                                                "Please select endorsement sub-type",
                                            value: selectedEndorsementSubType,
                                            onChanged: (val) {
                                              setState(() {
                                                selectedEndorsementSubType =
                                                    val;
                                                premiumCollectedController =
                                                    TextEditingController();
                                                referenceNumberController =
                                                    TextEditingController();
                                                sbigAccountNumberController =
                                                    TextEditingController();
                                                paymentModeController =
                                                    TextEditingController();
                                                amountController =
                                                    TextEditingController();
                                                accountHolderNameController =
                                                    TextEditingController();
                                                accountNumberController =
                                                    TextEditingController();
                                                ifscController =
                                                    TextEditingController();
                                                accountTypeController =
                                                    TextEditingController();
                                                refundAmountController =
                                                    TextEditingController();
                                                customerAccountController =
                                                    TextEditingController();

                                                oldValueController =
                                                    TextEditingController();
                                                policyIssueDate =
                                                    DateFormat('yyyy-MM-dd')
                                                        .format(DateTime.now());
                                                transactionDate =
                                                    DateFormat('yyyy-MM-dd')
                                                        .format(DateTime.now());

                                                selectedPaymentMode = null;
                                                selectedRefundReason = null;
                                                selectedRefundType = null;
                                              });
                                              getEndorsementFields();
                                            }),
                                        if (selectedEndorsementSubType != null)
                                          CustomInputField2(
                                            view: view,
                                            title: 'Old Value',
                                            hintText: 'Please enter Old Value',
                                            controller: oldValueController,
                                            validator:
                                                Validators.formValidation,
                                          ),
                                        dynamicForm
                                      ]),
                                if (selectedEndorsementRequestType ==
                                        'Cancellation & Refund' &&
                                    selectedEndorsementRequestType != null)
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Refund to be Made to :',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color:
                                              Color.fromRGBO(143, 19, 168, 1),
                                        ),
                                      ),
                                      _heightGap(),
                                      Wrap(
                                        spacing: 20,
                                        // runSpacing: 15,
                                        alignment: WrapAlignment.start,
                                        crossAxisAlignment:
                                            WrapCrossAlignment.start,
                                        children: [
                                          CustomInputField(
                                            view: view,
                                            maxLines: 1,
                                            title: 'Account Holder Name',
                                            hintText:
                                                'Please enter Account Holder Name',
                                            controller:
                                                accountHolderNameController,
                                            validator:
                                                Validators.formValidation,
                                          ),
                                          CustomInputField(
                                            view: view,
                                            maxLines: 1,
                                            title: 'Account Number',
                                            hintText:
                                                'Please enter Account Number',
                                            controller: accountNumberController,
                                            validator:
                                                Validators.formValidation,
                                          ),
                                          CustomInputField(
                                            view: view,
                                            maxLines: 1,
                                            title: 'IFSC',
                                            hintText: 'Please enter IFSC',
                                            controller: ifscController,
                                            validator:
                                                Validators.formValidation,
                                          ),
                                          CustomInputField(
                                            view: view,
                                            maxLines: 1,
                                            title: 'Account Type',
                                            hintText:
                                                'Please enter Account Type',
                                            controller: accountTypeController,
                                            validator:
                                                Validators.formValidation,
                                          ),
                                          DropdownWidget(
                                              view: view,
                                              label: 'Refund Reason',
                                              items: refundReason,
                                              hintText:
                                                  "Please select Refund Reason",
                                              value: selectedRefundReason,
                                              onChanged: (val) {
                                                setState(() {
                                                  selectedRefundReason = val;
                                                });
                                              }),
                                          DropdownWidget(
                                              view: view,
                                              label: 'Refund Type',
                                              items: refundType,
                                              hintText:
                                                  "Please select Refund Type",
                                              value: selectedRefundType,
                                              onChanged: (val) {
                                                setState(() {
                                                  selectedRefundType = val;
                                                });
                                              }),
                                          CustomInputField(
                                            view: view,
                                            maxLines: 1,
                                            title: 'Refund Amount',
                                            hintText:
                                                'Please enter Refund Amount',
                                            controller: refundAmountController,
                                            validator:
                                                Validators.formValidation,
                                          ),
                                          // TextButton(
                                          //     onPressed: () {
                                          //       setState(() {
                                          //         noPolicy = true;
                                          //       });
                                          //     },
                                          //     child: const Text(
                                          //       'If policy not generated\nclick here',
                                          //       style: TextStyle(
                                          //         decoration:
                                          //             TextDecoration.underline,
                                          //         decorationColor:
                                          //             Color.fromRGBO(
                                          //                 143, 19, 168, 1),
                                          //         fontSize: 14,
                                          //         color: Color.fromRGBO(
                                          //             143, 19, 168, 1),
                                          //       ),
                                          //     ))
                                        ],
                                      ),
                                    ],
                                  ),
                                if (selectedEndorsementRequestType ==
                                        'Financial Endorsement' &&
                                    selectedEndorsementRequestType != null)
                                  Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Premium Collection Details :',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color:
                                                Color.fromRGBO(143, 19, 168, 1),
                                          ),
                                        ),
                                        _heightGap(),
                                        Wrap(
                                            spacing: 20,
                                            // runSpacing: 15,
                                            alignment: WrapAlignment.start,
                                            crossAxisAlignment:
                                                WrapCrossAlignment.start,
                                            children: [
                                              CustomInputField(
                                                maxLines: 1,
                                                view: view,
                                                title:
                                                    'Premium to be Collected',
                                                hintText:
                                                    'Please enter Premium to be Collected',
                                                controller:
                                                    premiumCollectedController,
                                                validator:
                                                    Validators.formValidation,
                                              ),
                                              CustomInputField(
                                                view: view,
                                                maxLines: 1,
                                                title: 'Reference Number',
                                                hintText:
                                                    'Please enter Reference Number',
                                                controller:
                                                    referenceNumberController,
                                              ),
                                              DatePickerFormField(
                                                disabled: view,
                                                labelText: 'Transaction Date',
                                                onChanged: (DateTime? value) {
                                                  setState(() {
                                                    transactionDate =
                                                        DateFormat('yyyy-MM-dd')
                                                            .format(value
                                                                as DateTime);
                                                  });
                                                },
                                                date: transactionDate,
                                              ),
                                              CustomInputField(
                                                view: view,
                                                maxLines: 1,
                                                title: 'SBIG Account Number',
                                                hintText:
                                                    'Please enter SBIG Account Number',
                                                controller:
                                                    sbigAccountNumberController,
                                              ),
                                              DropdownWidget(
                                                  view: view,
                                                  label: 'Payment Mode',
                                                  items: paymentMode,
                                                  hintText:
                                                      "Please select Payment Mode",
                                                  value: selectedPaymentMode,
                                                  onChanged: (val) {
                                                    setState(() {
                                                      selectedPaymentMode = val;
                                                    });
                                                  }),
                                              CustomInputField(
                                                view: view,
                                                maxLines: 1,
                                                title: 'Amount',
                                                hintText: 'Please enter Amount',
                                                controller: amountController,
                                              ),
                                            ])
                                      ]),
                              ],
                            ),
                            _heightGap()
                          ]),
                        _heightGap(),
                        CustomInputContainer(
                          children: [
                            _heightGap(),
                            Wrap(
                              spacing: 20,
                              // runSpacing: 15,
                              alignment: WrapAlignment.start,
                              crossAxisAlignment: WrapCrossAlignment.start,
                              children: [
                                // CustomInputField(
                                //   view: view,
                                //   maxLines: 1,
                                //   title: "Customer Name",
                                //   hintText: "Please enter customer name",
                                //   inputFormatters: <TextInputFormatter>[
                                //     FilteringTextInputFormatter.allow(
                                //         RegExp("[a-zA-Z ]")),
                                //   ],
                                //   controller: customerNameController,
                                //   validator: (value) {
                                //     if (value!.isEmpty) {
                                //       return 'Please Enter Customer Name';
                                //     } else if (value.trim() != value) {
                                //       return 'Please Enter Valid Name';
                                //     }
                                //     return null;
                                //   },
                                // ),
                                CustomInputField(
                                  view: view,
                                  maxLength: 9,
                                  maxLines: 1,
                                  title: "Premium Amount",
                                  hintText: "Please enter premium amount",
                                  controller: premiumAmountController,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly
                                  ],
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return 'Please Enter the Premium Amount';
                                    } else if (int.parse(value) == 0) {
                                      return 'Premium amount cannot be zero';
                                    }
                                    for (var instrument in instrumentAmounts) {
                                      if (instrument.text != '') {
                                        if (int.parse(value) >
                                            int.parse(instrument.text)) {
                                          return 'Premium Amount cannot be more than \nInstrument Amount';
                                        }
                                      }
                                    }
                                    return null;
                                  },
                                ),
                                DatePickerFormField(
                                  disabled: view,
                                  labelText: 'Proposer Signed Date',
                                  onChanged: (DateTime? value) {
                                    setState(() {
                                      proposedDate = DateFormat('yyyy-MM-dd')
                                          .format(value as DateTime);
                                    });
                                    print('Selected date: $value');
                                  },
                                  date: proposedDate,
                                ),
                                (customerTypeRejectionList
                                            .contains(selectedProduct) ==
                                        false)
                                    ? DropdownWidget(
                                        view: view,
                                        label: 'Customer Type',
                                        items: individualOther,
                                        hintText: "Please Select",
                                        value: customerType,
                                        onChanged: (dat) {
                                          setState(() {
                                            customerType = dat;
                                          });
                                        },
                                      )
                                    : const SizedBox.shrink(),
                                DropdownWidget(
                                  view: view,
                                  label: "Co-Insurance",
                                  items: yesNo,
                                  hintText: "Please Select",
                                  value: _coInsurance,
                                  onChanged: (dat) {
                                    if (dat != _coInsurance) {
                                      leadType = null;
                                    }
                                    setState(() {
                                      _coInsurance = dat;
                                    });
                                  },
                                ),
                                productType == 'Health'
                                    ? DropdownWidget(
                                        view: view,
                                        label: 'PPHC',
                                        items: yesNo,
                                        hintText: "Please Select",
                                        value: _PPHC,
                                        onChanged: (dat) {
                                          setState(() {
                                            _PPHC = dat;
                                          });
                                        },
                                      )
                                    : const SizedBox.shrink(),
                                _coInsurance == 'Yes'
                                    ? DropdownWidget(
                                        view: view,
                                        label: 'Lead Type',
                                        items: leaderFollower,
                                        hintText: "Please Select",
                                        value: leadType,
                                        onChanged: (dat) {
                                          setState(() {
                                            leadType = dat;
                                          });
                                        },
                                      )
                                    : const SizedBox.shrink(),
                              ],
                            ),
                          ],
                        ),
                        _heightGap(),
                        Column(
                          children: instruments
                              .asMap()
                              .entries
                              .map(
                                  (entry) => _buildInstrumentDetails(entry.key))
                              .toList(),
                        ),
                        // _heightGap(),
                        // Stack(
                        //   children: [
                        //     ElevatedButton(
                        //       style: ElevatedButton.styleFrom(
                        //         backgroundColor:
                        //             const Color.fromRGBO(13, 154, 189, 1),
                        //         elevation: 10, // Elevation
                        //         shadowColor:
                        //             const Color.fromRGBO(15, 5, 158, 0.3),
                        //       ),
                        //       onPressed: () {},
                        //       child: const SizedBox(
                        //         width: double.infinity,
                        //         child: Align(
                        //           alignment: Alignment.centerLeft,
                        //           child: Padding(
                        //             padding: EdgeInsets.fromLTRB(16, 12, 0, 12),
                        //             child: Text(
                        //               'Add More Instrument Type',
                        //               style: TextStyle(
                        //                 color: Colors.white,
                        //               ),
                        //             ),
                        //           ),
                        //         ),
                        //       ),
                        //     ),
                        //     Positioned(
                        //       right: 5,
                        //       bottom: 0,
                        //       top: 0,
                        //       child: Material(
                        //         color: Colors.white,
                        //         shape: const CircleBorder(),
                        //         child: IconButton(
                        //           onPressed: () {},
                        //           icon: const Icon(
                        //             Icons.add,
                        //             color: Colors.black,
                        //           ),
                        //         ),
                        //       ),
                        //     ),
                        //   ],
                        // ),
                        // const SizedBox(height: 18.0),

                        // const SizedBox(height: 18.0),
                        // _heightGap(),
                        // _heightGap(),

                        // const SizedBox(height: 60.0),
                        _heightGap(),
                        _heightGap(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(right: 20),
                              padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  gradient: const LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Color.fromRGBO(130, 25, 151, 1),
                                        Color.fromRGBO(14, 64, 139, 1),
                                      ])),
                              child: TextButton(
                                onPressed: () {
                                  print('done');
                                  _submitForm();
                                  setState(() {
                                    checkPolicyNo = policyNumber(
                                      policyNumberController.text,
                                    );
                                  });

                                  // mandatoryField();
                                },
                                child: const Text(
                                  "Next",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // noPolicy
              //     ? Positioned(
              //         top: 0,
              //         right: 0,
              //         left: 0,
              //         bottom: 0,
              //         child: Container(
              //             width: MediaQuery.of(context).size.width,
              //             height: MediaQuery.of(context).size.height,
              //             decoration: BoxDecoration(
              //               color: Colors.black.withOpacity(0.5),
              //             ),
              //             child: Container(
              //               //   width: MediaQuery.of(context).size.width * 0.2,
              //               //   height: MediaQuery.of(context).size.height * 0.6,
              //               margin: EdgeInsets.fromLTRB(
              //                   MediaQuery.of(context).size.width * 0.05,
              //                   MediaQuery.of(context).size.height * 0.11,
              //                   MediaQuery.of(context).size.width * 0.05,
              //                   MediaQuery.of(context).size.height * 0.11),
              //               // padding: const EdgeInsets.all(15),
              //               decoration: const BoxDecoration(
              //                   color: Colors.white,
              //                   borderRadius:
              //                       BorderRadius.all(Radius.circular(10))),
              //               child: Center(
              //                 child: Stack(
              //                   children: [
              //                     SingleChildScrollView(
              //                       child: Container(
              //                           margin: const EdgeInsets.all(10),
              //                           padding: const EdgeInsets.all(15),
              //                           decoration: const BoxDecoration(
              //                               color: Color.fromRGBO(
              //                                   13, 154, 189, 0.15),
              //                               borderRadius: BorderRadius.all(
              //                                   Radius.circular(10))),
              //                           child: Form(
              //                             key: _formKey2,
              //                             child: Column(
              //                                 crossAxisAlignment:
              //                                     CrossAxisAlignment.center,
              //                                 mainAxisAlignment:
              //                                     MainAxisAlignment.center,
              //                                 children: [
              //                                   _heightGap(),
              //                                   CustomInputField(
              //                                     view: view,
              //                                     maxLines: 1,
              //                                     title: 'Customer Account',
              //                                     hintText:
              //                                         'Please enter Customer Account',
              //                                     controller:
              //                                         customerAccountController,
              //                                     validator:
              //                                         Validators.formValidation,
              //                                   ),
              //                                   _heightGap(),
              //                                   CustomInputField(
              //                                     view: view,
              //                                     maxLines: 1,
              //                                     title: 'Reference Number',
              //                                     hintText:
              //                                         'Please enter Reference Number',
              //                                     controller:
              //                                         referenceNumberController,
              //                                     validator:
              //                                         Validators.formValidation,
              //                                   ),
              //                                   _heightGap(),
              //                                   DatePickerFormField(
              //                                     disabled: view,
              //                                     labelText: 'Transaction Date',
              //                                     onChanged: (DateTime? value) {
              //                                       setState(() {
              //                                         transactionDate =
              //                                             DateFormat(
              //                                                     'yyyy-MM-dd')
              //                                                 .format(value
              //                                                     as DateTime);
              //                                       });
              //                                     },
              //                                     date: transactionDate,
              //                                   ),
              //                                   _heightGap(),
              //                                   CustomInputField(
              //                                     view: view,
              //                                     maxLines: 1,
              //                                     inputFormatters: [
              //                                       FilteringTextInputFormatter
              //                                           .digitsOnly
              //                                     ],
              //                                     title: 'SBIG Account Number',
              //                                     hintText:
              //                                         'Please enter SBIG Account Number',
              //                                     controller:
              //                                         sbigAccountNumberController,
              //                                     validator:
              //                                         Validators.formValidation,
              //                                   ),
              //                                   _heightGap(),
              //                                   DropdownWidget(
              //                                       view: view,
              //                                       label: 'Payment Mode',
              //                                       items: paymentMode,
              //                                       hintText:
              //                                           "Please select Payment Mode",
              //                                       value: selectedPaymentMode,
              //                                       onChanged: (val) {
              //                                         setState(() {
              //                                           selectedPaymentMode =
              //                                               val;
              //                                         });
              //                                       }),
              //                                   _heightGap(),
              //                                   _heightGap(),
              //                                   Container(
              //                                     margin: const EdgeInsets.only(
              //                                         left: 5, right: 5),
              //                                     decoration:
              //                                         const BoxDecoration(
              //                                       borderRadius:
              //                                           BorderRadius.all(
              //                                               Radius.circular(
              //                                                   10)),
              //                                       color: Color.fromRGBO(
              //                                           11, 133, 163, 1),
              //                                     ),
              //                                     child: TextButton(
              //                                         onPressed: () {
              //                                           if (_formKey2
              //                                               .currentState!
              //                                               .validate()) {
              //                                             setState(() {
              //                                               noPolicy = false;
              //                                             });
              //                                           } else {
              //                                             ScaffoldMessenger.of(
              //                                                     context)
              //                                                 .showSnackBar(
              //                                                     SnackBar(
              //                                                         content:
              //                                                             const Text(
              //                                                                 "Please enter all details!"),
              //                                                         action:
              //                                                             SnackBarAction(
              //                                                           label:
              //                                                               ' Cancel',
              //                                                           onPressed:
              //                                                               () {},
              //                                                         )));
              //                                           }
              //                                         },
              //                                         child: const Text(
              //                                           'Submit',
              //                                           style: TextStyle(
              //                                               color: Colors.white,
              //                                               fontSize: 18),
              //                                         )),
              //                                   )
              //                                 ]),
              //                           )),
              //                     ),
              //                     Positioned(
              //                       right: -2,
              //                       top: 12,
              //                       child: Row(
              //                         mainAxisAlignment: MainAxisAlignment.end,
              //                         children: [
              //                           TextButton(
              //                               onPressed: () {
              //                                 setState(() {
              //                                   noPolicy = false;
              //                                   transactionDate =
              //                                       DateFormat('yyyy-MM-dd')
              //                                           .format(DateTime.now());
              //                                   refundAmountController =
              //                                       TextEditingController();
              //                                   customerAccountController =
              //                                       TextEditingController();
              //                                   referenceNumberController =
              //                                       TextEditingController();
              //                                   sbigAccountNumberController =
              //                                       TextEditingController();
              //                                   selectedPaymentMode = null;
              //                                 });
              //                               },
              //                               child: const Text(
              //                                 'X',
              //                                 style: TextStyle(
              //                                     color: Color.fromRGBO(
              //                                         11, 133, 163, 1),
              //                                     fontSize: 22),
              //                               )),
              //                         ],
              //                       ),
              //                     ),
              //                   ],
              //                 ),
              //               ),
              //             )),
              //       )
              //     : const SizedBox.shrink(),
            ],
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
            : const SizedBox.shrink()
      ],
    );
  }

  static policyNumber(value1) {
    if (value1.isEmpty) {
      return true;
    } else {
      return false;
    }
  }

  _heightGap() {
    return const SizedBox(
      height: 12,
    );
  }

  void _showAlertDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("No SP Code"),
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

// ignore: must_be_immutable
class CustomInputField extends StatelessWidget {
  final String? title;
  final String? hintText;
  final TextEditingController? controller;
  final List<TextInputFormatter>? inputFormatters;
  final FormFieldValidator? validator;
  final onChanged;
  final maxLength;
  final value;
  final view;
  final maxLines;
  var mandatoryFields;
  var verifyButton;

  CustomInputField(
      {super.key,
      this.title,
      this.hintText,
      this.controller,
      this.inputFormatters,
      this.validator,
      this.onChanged,
      this.maxLength,
      this.value,
      this.view = false,
      this.maxLines,
      this.mandatoryFields,
      this.verifyButton});

  @override
  Widget build(BuildContext context) {
    FocusNode focusNode1 = FocusNode();
    return Column(
      children: [
        const SizedBox(
          height: 10,
        ),
        SizedBox(
          width: 250,
          // height: 40,
          child: TextFormField(
            // textCapitalization: TextCapitalization.words,

            // scrollPadding: EdgeInsets.all(5),
            // inputFormatters: [
            //   UpperCaseTextFormatter(),
            // ],

            // initialValue: value,

            readOnly: view,
            maxLines: maxLines,
            maxLength: maxLength,
            controller: controller,
            onChanged: onChanged,
            expands: false,
            // showCursor: false,

            style: view == true
                ? const TextStyle(
                    color: Colors.grey,
                    fontSize: 13,
                  )
                : const TextStyle(color: Colors.black, fontSize: 13),
            decoration: InputDecoration(
                floatingLabelBehavior: FloatingLabelBehavior.always,
                floatingLabelStyle: const TextStyle(
                    fontSize: 14,
                    color: Color.fromRGBO(143, 19, 168, 1),
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1),
                isCollapsed: false,
                isDense: true,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 5.0, vertical: 10),
                counterText: "",
                enabledBorder: OutlineInputBorder(
                    borderSide:
                        const BorderSide(color: Colors.black12, width: 2),
                    borderRadius: BorderRadius.circular(6)),
                focusedBorder: OutlineInputBorder(
                  borderSide: view == true
                      ? const BorderSide(
                          color: Color.fromARGB(255, 209, 209, 209), width: 2)
                      : const BorderSide(
                          color: Color.fromRGBO(143, 19, 168, 1), width: 2),
                  borderRadius: BorderRadius.circular(6),
                ),
                prefixIconColor:
                    MaterialStateColor.resolveWith((Set<MaterialState> states) {
                  if (states.contains(MaterialState.focused)) {
                    return const Color.fromRGBO(143, 19, 168, 1);
                  }
                  return Colors.grey;
                }),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                labelText: title,
                labelStyle: const TextStyle(
                    fontSize: 14,
                    color: Color.fromRGBO(143, 19, 168, 1),
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1),
                // labelStyle: TextStyle(
                //   color: focusNode1.hasFocus
                //       ? const Color.fromRGBO(143, 19, 168, 1)
                //       : Colors.grey,
                //   fontSize: 14,
                //   letterSpacing: 1,
                // ),
                hintText: hintText,
                hintStyle: const TextStyle(color: Colors.black, fontSize: 12)),
            validator: validator,

            autovalidateMode: AutovalidateMode.onUserInteraction,
            inputFormatters: inputFormatters,
          ),
        ),
        title == 'Policy Number'
            ? verifyButton
            : const SizedBox(
                height: 14,
              ),
        // mandatoryFields == true
        //     ? SizedBox(
        //         width: 250,
        //         child: Text(
        //           'Please enter $title',
        //           style: const TextStyle(
        //               color: Color.fromARGB(255, 172, 32, 22), fontSize: 10),
        //         ),
        //       )
        //     : const SizedBox.shrink()
      ],
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
  final value;
  final view;
  final maxLines;
  var mandatoryFields;
  var verifyButton;

  CustomInputField2(
      {super.key,
      this.title,
      this.hintText,
      this.controller,
      this.inputFormatters,
      this.validator,
      this.onChanged,
      this.maxLength,
      this.value,
      this.view = false,
      this.maxLines,
      this.mandatoryFields,
      this.verifyButton});

  @override
  Widget build(BuildContext context) {
    FocusNode focusNode1 = FocusNode();
    return Column(
      children: [
        const SizedBox(
          height: 10,
        ),
        SizedBox(
          width: 520,
          // height: 40,
          child: TextFormField(
            // textCapitalization: TextCapitalization.words,

            // scrollPadding: EdgeInsets.all(5),
            // inputFormatters: [
            //   UpperCaseTextFormatter(),
            // ],

            // initialValue: value,

            readOnly: view,
            maxLines: maxLines,
            maxLength: maxLength,
            controller: controller,
            onChanged: onChanged,
            expands: false,
            // showCursor: false,

            style: view == true
                ? const TextStyle(
                    color: Colors.grey,
                    fontSize: 13,
                  )
                : const TextStyle(color: Colors.black, fontSize: 13),
            decoration: InputDecoration(
                floatingLabelBehavior: FloatingLabelBehavior.always,
                floatingLabelStyle: const TextStyle(
                    fontSize: 14,
                    color: Color.fromRGBO(143, 19, 168, 1),
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1),
                isCollapsed: false,
                isDense: true,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 5.0, vertical: 10),
                counterText: "",
                enabledBorder: OutlineInputBorder(
                    borderSide:
                        const BorderSide(color: Colors.black12, width: 2),
                    borderRadius: BorderRadius.circular(6)),
                focusedBorder: OutlineInputBorder(
                  borderSide: view == true
                      ? const BorderSide(
                          color: Color.fromARGB(255, 209, 209, 209), width: 2)
                      : const BorderSide(
                          color: Color.fromRGBO(143, 19, 168, 1), width: 2),
                  borderRadius: BorderRadius.circular(6),
                ),
                prefixIconColor:
                    MaterialStateColor.resolveWith((Set<MaterialState> states) {
                  if (states.contains(MaterialState.focused)) {
                    return const Color.fromRGBO(143, 19, 168, 1);
                  }
                  return Colors.grey;
                }),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                labelText: title,
                labelStyle: const TextStyle(
                    fontSize: 14,
                    color: Color.fromRGBO(143, 19, 168, 1),
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1),
                // labelStyle: TextStyle(
                //   color: focusNode1.hasFocus
                //       ? const Color.fromRGBO(143, 19, 168, 1)
                //       : Colors.grey,
                //   fontSize: 14,
                //   letterSpacing: 1,
                // ),
                hintText: hintText,
                hintStyle: const TextStyle(color: Colors.black, fontSize: 12)),
            validator: validator,

            autovalidateMode: AutovalidateMode.onUserInteraction,
            inputFormatters: inputFormatters,
          ),
        ),
        title == 'Policy Number'
            ? verifyButton
            : const SizedBox(
                height: 14,
              ),
        // mandatoryFields == true
        //     ? SizedBox(
        //         width: 250,
        //         child: Text(
        //           'Please enter $title',
        //           style: const TextStyle(
        //               color: Color.fromARGB(255, 172, 32, 22), fontSize: 10),
        //         ),
        //       )
        //     : const SizedBox.shrink()
      ],
    );
  }
}
