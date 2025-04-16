import 'package:games/widget/AppBar.dart';
import 'package:games/widget/MyButton.dart';

import '../controller/SettingController.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import '../helper/helpers.dart';
import '../model/Ticket.dart';
import '../page/chat_ticket.dart';

import '../controller/AnimationController.dart';
import '../controller/TicketController.dart';
import '../controller/UserController.dart';
import '../helper/styles.dart';
import '../helper/variables.dart';
import '../widget/MyTextField.dart';
import '../widget/loader.dart';

class ContactUsPage extends StatelessWidget {
  late Style style;
  late SettingController setting;
  late TicketController ticketController;

  TextEditingController textNameCtrl = TextEditingController();
  TextEditingController textPhoneCtrl = TextEditingController();
  TextEditingController textSubjectCtrl = TextEditingController();
  TextEditingController textMessageCtrl = TextEditingController();
  MyAnimationController animationController = Get.find<MyAnimationController>();
  UserController userController = Get.find<UserController>();
  Helper helper = Get.find<Helper>();
  RxBool loading = RxBool(false);

  ContactUsPage() {
    style = Get.find<Style>();
    setting = Get.find<SettingController>();
    ticketController = Get.find<TicketController>();

    textNameCtrl.text = userController.user?.fullName ?? '';
    textPhoneCtrl.text =
        userController.user?.phone ?? userController.user?.phone ?? '';


    SchedulerBinding.instance.addPostFrameCallback((timeStamp) async {
      // await ticketController.getTickets();
      // showCreateTicket();
      // Get.to(
      //     ChatPage(ticket: ticketController.tickets.firstWhere((e) => true)));
    });
  }

  @override
  Widget build(BuildContext context) {
    if (setting.appInfo == null) {
      Get.offNamed('/');
      return Center();
    }
    return Scaffold(
      body: MyAppBar(
        child: Padding(
          padding: EdgeInsets.all(style.cardMargin),
          child: Obx(() {
            loading.value = loading.value;
            return ListView(
              shrinkWrap: true,
              physics: BouncingScrollPhysics(),
              children: [
                if(false && (setting.appInfo?.questions.length??0)>0)
                Container(
                  padding: EdgeInsets.all(
                    style.cardMargin * 2,
                  ),
                  margin: EdgeInsets.all(
                    style.cardMargin,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(style.cardMargin),
                    color: style.primaryColor,
                    border: Border.all(
                      color: Colors.transparent,
                      // Make the border itself transparent
                      width: 4.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.yellow.shade700.withOpacity(0.8),
                        blurRadius: 8.0,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Text(
                    'read_before_send'.tr,
                    style: style.textMediumLightStyle,
                  ),
                ),
                ...(setting.appInfo?.questions ?? <Widget>[])
                    .map<Widget>((e) => Padding(
                          padding: EdgeInsets.all(style.cardMargin / 4),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextButton.icon(
                                icon: Icon(
                                  Icons.circle,
                                  color: style.primaryColor,
                                ),
                                label: Text(
                                  e['q'],
                                  style: style.textMediumLightStyle
                                      .copyWith(color: style.primaryColor),
                                ),
                                onPressed: () {
                                  e['visible'].value = !e['visible'].value;
                                },
                                style: style.buttonStyle(
                                    backgroundColor: style.secondaryColor,
                                    radius: BorderRadius.vertical(
                                        bottom:
                                            Radius.circular(style.cardMargin),
                                        top: Radius.circular(style.cardMargin)),
                                    splashColor:
                                        style.primaryColor.withOpacity(.5)),
                              ),
                              Visibility(
                                visible: e['visible'].value,
                                child: Container(
                                  padding: EdgeInsets.all(style.cardMargin),
                                  decoration: BoxDecoration(
                                      color: style.secondaryColor,
                                      borderRadius: BorderRadius.vertical(
                                          top:
                                              Radius.circular(style.cardMargin),
                                          bottom: Radius.circular(
                                              style.cardMargin))),
                                  child: Text(
                                    e['a'],
                                    style: style.textMediumStyle,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ))
                    .toList(),

                // contact form
                //                   Container(
                //                     padding: EdgeInsets.symmetric(
                //                       horizontal: style.cardMargin,
                //                       vertical: style.cardMargin * 3,
                //                     ),
                //                     child: TextButton.icon(
                //                       style: style.buttonStyle(
                //                           padding: EdgeInsets.symmetric(
                //                               vertical: style.cardMargin * 2),
                //                           backgroundColor: Colors.teal,
                //                           radius: BorderRadius.circular(style.cardMargin)),
                //                       onPressed: () async {
                //                         showCreateTicket();
                //                       },
                //                       icon: Icon(Icons.add_box, color: Colors.white),
                //                       label: Text(
                //                         'new_ticket'.tr,
                //                         style: style.textMediumStyle.copyWith(
                //                             color: Colors.white, fontWeight: FontWeight.bold),
                //                       ),
                //                     ),
                //                   ),
                //                   Padding(
                //                     padding: EdgeInsets.all(style.cardMargin),
                //                     child: TextButton(
                //                       style: style.buttonStyle(
                //                         padding: EdgeInsets.all(style.cardMargin),
                //                         radius: BorderRadius.all(
                //                           Radius.circular(style.cardMargin),
                //                         ),
                //                         backgroundColor: style.primaryMaterial[50],
                //                       ),
                //                       onPressed: () => ticketController.getTickets(),
                //                       child: Row(
                //                           mainAxisAlignment: MainAxisAlignment.spaceAround,
                //                           children: [
                //                             IntrinsicHeight(
                //                                 child: Row(children: [
                //                               Icon(
                //                                 Icons.refresh,
                //                                 color: style.primaryMaterial[600],
                //                               ),
                //                               VerticalDivider(
                //                                 color: style.primaryColor,
                //                               ),
                //                               BlinkAnimation(
                //                                 child: Container(
                //                                   padding: EdgeInsets.symmetric(
                //                                       horizontal: style.cardMargin / 2),
                //                                   decoration: BoxDecoration(
                //                                       borderRadius: BorderRadius.all(
                //                                           Radius.circular(style.cardMargin))),
                //                                   child: Text("${'ticket_list'.tr}",
                //                                       style: style.textMediumStyle),
                //                                 ),
                //                               ),
                //                             ])),
                //                           ]),
                //                     ),
                //                   ),
                //                   Divider(),
                // //tickets list
                //                   ticketController.obx((tickets) {
                //                     if (tickets == null) return Center();
                //                     if (!(tickets is List<Ticket>))
                //                       tickets = ticketController.tickets;
                //                     return Column(
                //                       mainAxisSize: MainAxisSize.min,
                //                       children: [
                //                         ...[
                //                           for (Ticket ticket in tickets)
                //                             Card(
                //                               color: Colors.white,
                //                               elevation: 2,
                //                               margin: EdgeInsets.all(style.cardMargin),
                //                               shape: RoundedRectangleBorder(
                //                                   borderRadius: BorderRadius.circular(
                //                                       style.cardBorderRadius / 2)),
                //                               child: TextButton(
                //                                 style: ButtonStyle(
                //                                     backgroundColor: MaterialStateProperty.all(
                //                                         style.secondaryColor.withOpacity(.2)),
                //                                     overlayColor:
                //                                         MaterialStateProperty.resolveWith(
                //                                       (states) {
                //                                         return states
                //                                                 .contains(MaterialState.pressed)
                //                                             ? style.secondaryColor
                //                                             : null;
                //                                       },
                //                                     ),
                //                                     shape: MaterialStateProperty.all(
                //                                         RoundedRectangleBorder(
                //                                       borderRadius: BorderRadius.all(
                //                                           Radius.circular(style.cardMargin)),
                //                                     ))),
                //                                 onPressed: () {
                //                                   // ticket.status.value =
                //                                   //     setting.ticketStatuses[1];
                //                                   ticket.notifyMe.value = false;
                //                                   Get.dialog(ChatPage(ticket: ticket));
                //                                 },
                //                                 child: Padding(
                //                                   padding: EdgeInsets.all(style.cardMargin),
                //                                   child: Stack(
                //                                     children: [
                //                                       Column(
                //                                         crossAxisAlignment:
                //                                             CrossAxisAlignment.stretch,
                //                                         children: [
                //                                           Padding(
                //                                             padding: EdgeInsets.all(
                //                                                 style.cardMargin),
                //                                             child: Row(
                //                                                 mainAxisAlignment:
                //                                                     MainAxisAlignment
                //                                                         .spaceAround,
                //                                                 children: [
                //                                                   Text(
                //                                                     "${"id".tr} ${ticket.id}",
                //                                                     style:
                //                                                         style.textMediumStyle,
                //                                                   ),
                //                                                   Text(
                //                                                       ticket.updatedAt
                //                                                           .toShamsi(),
                //                                                       style: style
                //                                                           .textMediumStyle
                //                                                           .copyWith(
                //                                                               color: style
                //                                                                   .primaryColor
                //                                                                   .withOpacity(
                //                                                                       .5)))
                //                                                 ]),
                //                                           ),
                //                                           Divider(
                //                                             height: 1,
                //                                             thickness: 3,
                //                                             indent: style.cardMargin,
                //                                             endIndent: style.cardMargin,
                //                                             color: style.primaryMaterial[100],
                //                                           ),
                //                                           Container(
                //                                             padding: EdgeInsets.symmetric(
                //                                               horizontal: style.cardMargin * 2,
                //                                               vertical: style.cardMargin,
                //                                             ),
                //                                             child: Text(
                //                                               ticket.subject,
                //                                               textAlign: TextAlign.start,
                //                                               maxLines: 1,
                //                                               softWrap: false,
                //                                               overflow: TextOverflow.fade,
                //                                               style: style.textMediumStyle
                //                                                   .copyWith(
                //                                                       color:
                //                                                           style.primaryMaterial[
                //                                                               900]),
                //                                             ),
                //                                           ),
                //                                           Container(
                //                                             padding: EdgeInsets.symmetric(
                //                                               horizontal: style.cardMargin * 2,
                //                                             ),
                //                                             child: Text(
                //                                               "${ticket.status}".tr,
                //                                               overflow: TextOverflow.fade,
                //                                               maxLines: 1,
                //                                               softWrap: false,
                //                                               style: style.textSmallStyle
                //                                                   .copyWith(
                //                                                       color: style.primaryColor
                //                                                           .withOpacity(.7)),
                //                                             ),
                //                                           ),
                //                                         ],
                //                                       ),
                //                                       if (ticket.notifyMe.value)
                //                                         Positioned(
                //                                           top: 0,
                //                                           left: 0,
                //                                           child: BlinkAnimation(
                //                                             repeat: true,
                //                                             child: Container(
                //                                               decoration: BoxDecoration(
                //                                                 shape: BoxShape.circle,
                //                                                 color: Colors.red,
                //                                               ),
                //                                               padding: EdgeInsets.all(
                //                                                   style.cardMargin),
                //                                             ),
                //                                           ),
                //                                         ),
                //                                     ],
                //                                   ),
                //                                 ),
                //                               ),
                //                             ),
                //                         ]
                //                       ],
                //                     );
                //                   },
                //                       onLoading: Loader(
                //                         color: style.primaryColor,
                //                       ),
                //                       onError: (e) => Center(),
                //                       onEmpty: Center()),
                Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: style.cardMargin * 3,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (dynamic link in setting.appInfo!.supportLinks)
                          MyButton(
                            label: '${link['name']}',
                            onPressed: () => setting.goTo(link['url']),
                          ),
                      ],
                    ),
                  ),
                )
              ],
            );
          }),
        ),
      ),
    );
  }

  void showCreateTicket() {
    Get.dialog(
        Obx(
          () => Scaffold(
            body: Center(
              child: Container(
                margin: EdgeInsets.all(style.cardMargin / 4),
                padding: EdgeInsets.symmetric(
                  horizontal: style.cardMargin,
                  vertical: style.cardMargin * 2,
                ),
                decoration: BoxDecoration(
                  color: style.primaryMaterial[50],
                  borderRadius:
                      BorderRadius.all(Radius.circular(style.cardMargin)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    //name field
                    MyTextField(
                        margin: EdgeInsets.symmetric(
                            vertical: style.cardMargin / 4),
                        textController: textSubjectCtrl,
                        labelText: 'subject'.tr,
                        icon: Icon(
                          Icons.announcement_rounded,
                          color: style.primaryColor,
                        ),
                        textInputType: TextInputType.text),

                    //message field
                    MyTextField(
                        margin: EdgeInsets.symmetric(
                            vertical: style.cardMargin / 4),
                        textController: textMessageCtrl,
                        minLines: 3,
                        labelText: 'message'.tr,
                        icon: Icon(
                          Icons.message,
                          color: style.primaryColor,
                        ),
                        textInputAction: TextInputAction.newline,
                        textInputType: TextInputType.multiline),
                    if (!loading.value)
                      Padding(
                        padding: EdgeInsets.all(style.cardMargin / 2),
                        child: TextButton.icon(
                          icon: Icon(
                            Icons.arrow_forward_ios,
                            textDirection: TextDirection.ltr,
                            color: style.secondaryColor,
                          ),
                          label: Center(
                            child: ticketController.loading
                                ? Loader(color: Colors.white)
                                : Text(
                                    'send'.tr,
                                    style: style.textBigStyle
                                        .copyWith(color: Colors.white),
                                  ),
                          ),
                          onPressed: () async {
                            if (loading.value) return;
                            loading.value = true;
                            var res = await ticketController.create(
                              subject: textSubjectCtrl.text,
                              message: textMessageCtrl.text,
                            );
                            loading.value = false;
                            if (res['status'] != null &&
                                res['status'] == 'success') {
                              textSubjectCtrl.clear();
                              textMessageCtrl.clear();
                              Get.back();
                              ticketController.getTickets();

                              // Future.delayed(Duration(seconds: 3));
                            }
                            helper.showToast(
                                msg: res['message'], status: res['status']);
                          },
                          style: style.buttonStyle(
                              radius: BorderRadius.all(
                                Radius.circular(style.cardMargin),
                              ),
                              backgroundColor: style.primaryColor,
                              splashColor: style.secondaryColor),
                        ),
                      ),
                    if (loading.value)
                      Loader(
                        color: style.primaryColor,
                      )
                  ],
                ),
              ),
            ),
          ),
        ),
        barrierDismissible: true);
  }
}
