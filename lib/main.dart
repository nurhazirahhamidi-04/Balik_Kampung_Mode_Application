import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

void main() => runApp(const BalikKampungApp());

const navy = Color(0xFF12233F);
const green = Color(0xFF16A579);
const pageBg = Color(0xFFF4F7FB);
const muted = Color(0xFF718096);
const guards = ['Aiman Rahman', 'Nurul Hakim', 'Farah Nadia', 'Daniel Lim'];
const zones = ['Zone A – Taman Bayu','Zone B – Seri Sungai','Zone C – Seri Murni','Zone North – Common area','Main entrance'];
const occasions = ['Hari Raya Aidilfitri','Chinese New Year','Deepavali','Christmas','School holidays','Other'];

class AlertItem {
  AlertItem(this.id,this.time,this.property,this.zone,this.type,this.severity,this.explanation,this.status,{this.source='sample',this.action='' });
  int id; String time,property,zone,type,severity,explanation,status,source,action;
}
class TaskItem {
  TaskItem(this.id,this.title,this.zone,this.priority,this.status,this.assigned,this.instruction,{this.alertId,this.accepted=false});
  int id; String title,zone,priority,status,assigned,instruction; int? alertId; bool accepted;
}
class HouseItem {
  HouseItem(this.id,this.zone,this.water,this.electric,this.status,{this.mine=false,this.away=false});
  String id,zone,status; double water,electric; bool mine,away;
}

class BalikKampungApp extends StatelessWidget {
  const BalikKampungApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Balik Kampung Mode',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      useMaterial3:true,
      scaffoldBackgroundColor:const Color(0xFFF3F7F5),
      fontFamily:'Arial',
      colorScheme: ColorScheme.fromSeed(seedColor:green, primary:green, surface:Colors.white),
      appBarTheme: const AppBarTheme(backgroundColor:Color(0xFFF2F7F4), foregroundColor:navy, elevation:0, scrolledUnderElevation:0, surfaceTintColor:Colors.transparent),
      inputDecorationTheme: InputDecorationTheme(filled:true,fillColor:const Color(0xFFF8FBF9),contentPadding:const EdgeInsets.symmetric(horizontal:14,vertical:16),border:OutlineInputBorder(borderRadius:BorderRadius.circular(14),borderSide:const BorderSide(color:Color(0xFFE4ECE7))),enabledBorder:OutlineInputBorder(borderRadius:BorderRadius.circular(14),borderSide:const BorderSide(color:Color(0xFFE4ECE7)))),
    ),
    home: const AppShell(),
  );
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});
  @override State<AppShell> createState()=>_AppShellState();
}
class _AppShellState extends State<AppShell> {
  bool showSplash=true;
  bool signedIn=false, signup=false, away=false, notificationsOpen=false;
  String role='management', authRole='management', guardName=guards[0], email='manager@example.com', password='welcome123', page='overview';
  String name='', accountType='management', occasion='Hari Raya Aidilfitri', chartMode='both';
  DateTime startDate=DateTime(2026,10,20), endDate=DateTime(2026,10,27);
  final settings=<String,bool>{'door':true,'water':true,'electric':true,'notifyManagement':true};
  final checklist=<bool>[false,false,false,false];
  double waterToday=18,electricToday=2.1;
  String homeStatus='Normal';
  int nextAlert=6,nextTask=4;
  final water=[31.0,27.0,30.0,28.0,33.0,36.0,18.0];
  final electric=[3.8,4.1,3.6,4.3,4.0,4.8,2.1];
  final houses=<HouseItem>[
    HouseItem('BK-A-014','Zone A – Taman Bayu',18,2.1,'Normal',mine:true,away:true),
    HouseItem('BK-A-017','Zone A – Taman Bayu',68,8.4,'Water alert',away:true),
    HouseItem('BK-B-052','Zone B – Seri Sungai',24,5.2,'Normal'),
    HouseItem('BK-C-031','Zone C – Seri Murni',13,1.8,'Normal',away:true),
  ];
  final alerts=<AlertItem>[
    AlertItem(1,'16/10/2026, 23:02:43','BK-A-014','Zone A – Taman Bayu','electricity','high','Electricity draw is 5.7× the illustrative expected level. Holiday Mode is active. This does not confirm a fault or break-in.','Open'),
    AlertItem(2,'16/10/2026, 23:02:36','BK-A-014','Zone A – Taman Bayu','water','low','Water flow is 8.7× the illustrative expected level. Holiday Mode is inactive, so priority is lowered. This does not confirm a leak or wrongdoing.','Open'),
    AlertItem(3,'16/10/2026, 23:02:30','BK-A-014','Zone A – Taman Bayu','water','high','Water flow is 9.9× the illustrative expected level and appears sustained. Holiday Mode is active. This does not confirm a leak or wrongdoing.','Open'),
    AlertItem(4,'16 Oct 2026, 08:10','BK-A-017','Zone A – Taman Bayu','water','medium','Water flow 3.5× expected.','Resolved'),
    AlertItem(5,'16 Oct 2026, 09:42','BK-B-052','Zone B – Seri Sungai','electricity','high','Electricity draw 5× expected.','Reviewing'),
  ];
  final tasks=<TaskItem>[
    TaskItem(1,'Verify possible water anomaly','Zone A – Taman Bayu','High','Pending',guards[0],'Check assigned operational area and record verification outcome.',alertId:2),
    TaskItem(2,'Scheduled common-area patrol','Zone North','Medium','In progress',guards[1],'Complete the common-area patrol and record the checkpoint.'),
    TaskItem(3,'Review possible forced-entry event','Zone B – Seri Sungai','High','Pending',guards[0],'Verify the reported sensor event safely; do not assume a crime occurred.',alertId:1),
  ];

  @override
  void initState(){super.initState();Future.delayed(const Duration(milliseconds:2200),(){if(mounted)setState(()=>showSplash=false);});}
  bool get isManagement=>role=='management';
  bool get isResident=>role=='resident';
  bool get isGuard=>role=='guard';
  String get roleName=>isManagement?'Township Manager':isResident?'Resident':guardName;
  List<AlertItem> get visibleAlerts {
    if(isGuard) return <AlertItem>[];
    if(isResident) return alerts.where((a)=>a.property=='BK-A-014'||a.property=='Your home').toList(growable:false);
    return List<AlertItem>.unmodifiable(alerts);
  }
  List<TaskItem> get visibleTasks=>isGuard?tasks.where((t)=>t.assigned==guardName).toList():tasks;
  int get openAlerts=>visibleAlerts.where((a)=>!['Closed','Resolved','Completed'].contains(a.status)).length;
  String get nowText=>DateTime.now().toString().substring(0,19);

  void toast(String msg)=>ScaffoldMessenger.of(context)..hideCurrentSnackBar()..showSnackBar(SnackBar(content:Text(msg),behavior:SnackBarBehavior.floating));
  void login() {
    if(email.trim().isEmpty||password.isEmpty){toast('Please enter an email and password.');return;}
    setState(()=>{role=authRole,signedIn=true,page='overview'});
    toast('Signed in to ${roleName} view.');
  }
  void signOut()=>setState(()=>{signedIn=false,signup=false,page='overview'});
  void go(String p) {
    final allowed={'overview':['management','resident','guard'],'away':['resident'],'sensors':['management','resident'],'security':['management','guard'],'alerts':['management','resident'],'reports':['management'],'profile':['management','resident','guard']};
    if(!(allowed[p]?.contains(role)??false)){toast('This section is not available for your role.');return;}
    setState(()=>page=p);
    if(p=='away') holidayDialog();
    if(p=='reports') reportDialog();
  }
  String get pageTitle=>({'overview':'Township overview','away':'Holiday Mode','sensors':'Water & electricity','security':'Security tasks','alerts':'Alerts & incidents','reports':'Reports & activity'}[page] ?? 'Balik Kampung Mode');
  String get pageSubtitle=>({'overview':'A calmer, safer way to leave home during the holidays.','away':'Manage your departure dates and home monitoring preferences.','sensors':'Review household usage and unusual readings.','security':'Named guard assignments and incident verification workflow.','alerts':'Review water, electricity and possible forced-entry events.','reports':'Aggregated township statistics and task activity.'}[page] ?? 'Smart township home monitoring.');

  Map<String,dynamic> analyze(String type,double value,double expected,{bool sustained=false,bool force=false}) {
    final ratio=value/(expected<0.1?0.1:expected);
    bool anomaly=false; String severity='low',explanation='',action='Continue monitoring.';
    if(type=='water'){
      anomaly=ratio>=3||(sustained&&ratio>=1.8);
      severity=anomaly&&away&&(ratio>=5||sustained)?'high':anomaly?'medium':'low';
      explanation=anomaly?'Water flow is ${ratio.toStringAsFixed(1)}× the illustrative expected level${sustained?' and appears sustained':''}. Holiday Mode is ${away?'active':'inactive'}. This does not confirm a leak or wrongdoing.':'Water flow is within the illustrative expected range (${ratio.toStringAsFixed(1)}× baseline).';
      if(anomaly) action='Notify the resident and authorised management; verify sensor health and consider a safe inspection.';
    } else if(type=='electricity'){
      anomaly=ratio>=3.5; severity=anomaly&&away?'high':anomaly?'medium':'low';
      explanation=anomaly?'Electricity draw is ${ratio.toStringAsFixed(1)}× the illustrative expected level. Holiday Mode is ${away?'active':'inactive'}. This does not prove a fault or break-in.':'Electricity usage is within the illustrative expected range (${ratio.toStringAsFixed(1)}× baseline).';
      if(anomaly) action='Notify the resident and authorised management; review appliance and meter context.';
    } else {
      anomaly=force; severity=anomaly?'high':'low';
      explanation=anomaly?'A door/window force-entry signal was received. This is an unverified sensor event and does not establish that a break-in occurred.':'No force-entry signal detected.';
      if(anomaly) action='Notify the resident and authorised management; create a guard verification task with minimum necessary location details.';
    }
    return {'anomaly':anomaly,'severity':severity,'explanation':explanation,'action':action,'ratio':ratio};
  }
  void addAnomaly(String type) {
    final result=type=='water'?analyze(type,216.31,25,sustained:true):type=='electricity'?analyze(type,.85,.15):analyze('intruder',1,1,force:true);
    if(result['anomaly'] != true){toast('No strong anomaly detected. ${result['explanation']}');return;}
    setState((){
      if(type=='water'){waterToday=216.31;homeStatus='Water alert';water[6]=216.31;houses.firstWhere((h)=>h.mine).water=216.31;houses.firstWhere((h)=>h.mine).status='Water alert';}
      if(type=='electricity'){electricToday=.85;homeStatus='Energy alert';electric[6]=.85;houses.firstWhere((h)=>h.mine).electric=.85;houses.firstWhere((h)=>h.mine).status='Energy alert';}
      final a=AlertItem(nextAlert++,nowText,isResident?'Your home':'BK-A-014','Zone A – Taman Bayu',type,result['severity'],result['explanation'],'Open',source:'simulated',action:result['action']);
      alerts.insert(0,a); if(alerts.length>20)alerts.removeLast();
      if(type=='intruder')tasks.insert(0,TaskItem(nextTask++,'Verify possible forced-entry event',a.zone,'High','Pending',guards[0],'Verify sensor event safely. Do not assume a break-in occurred.',alertId:a.id));
    });
    toast('${typeName(type)} anomaly/incident created. Notifications updated.');
  }
  String typeName(String t) {
    switch (t.toLowerCase().trim()) {
      case 'intruder':
      case 'forced entry':
      case 'possible forced entry':
        return 'Possible forced entry';
      case 'water':
        return 'Water';
      case 'electricity':
        return 'Electricity';
      default:
        return t.trim().isEmpty ? 'Unknown alert' : t[0].toUpperCase() + t.substring(1);
    }
  }
  void normalScenario(){
    setState(()=>{waterToday=18,electricToday=2.1,homeStatus='Normal',water[6]=18,electric[6]=2.1,houses.firstWhere((h)=>h.mine).water=18,houses.firstWhere((h)=>h.mine).electric=2.1,houses.firstWhere((h)=>h.mine).status='Normal'});
    final w=analyze('water',18,25),e=analyze('electricity',2.1,3.5);
    toast('Normal scenario. ${w['explanation']} ${e['explanation']}');
  }

  Future<void> holidayDialog() async {
    if(isGuard)return;
    DateTime s=startDate,e=endDate; String occ=occasion;
    final result=await showDialog<bool>(context:context,builder:(ctx)=>StatefulBuilder(builder:(ctx,setD)=>AlertDialog(
      title:const Text('Manage Holiday Mode'),content:SingleChildScrollView(child:Column(mainAxisSize:MainAxisSize.min,crossAxisAlignment:CrossAxisAlignment.start,children:[
        const Text('Choose your festive occasion, dates and monitoring preferences.'),
        const SizedBox(height:14),DropdownButtonFormField<String>(value:occ,decoration:const InputDecoration(labelText:'Festive occasion'),items:occasions.map((x)=>DropdownMenuItem(value:x,child:Text(x))).toList(),onChanged:(v){if(v!=null)setD(()=>occ=v);}),
        const SizedBox(height:12),ListTile(contentPadding:EdgeInsets.zero,title:const Text('Departure date'),subtitle:Text('${s.day}/${s.month}/${s.year}'),trailing:const Icon(Icons.calendar_month),onTap:()async{final d=await showDatePicker(context:ctx,firstDate:DateTime(2020),lastDate:DateTime(2040),initialDate:s);if(d!=null)setD(()=>s=d);}),
        ListTile(contentPadding:EdgeInsets.zero,title:const Text('Expected return date'),subtitle:Text('${e.day}/${e.month}/${e.year}'),trailing:const Icon(Icons.calendar_month),onTap:()async{final d=await showDatePicker(context:ctx,firstDate:DateTime(2020),lastDate:DateTime(2040),initialDate:e);if(d!=null)setD(()=>e=d);}),
        const Divider(),...[
          ['door','Door / force-entry alerts'],['water','Water anomaly alerts'],['electric','Electricity anomaly alerts'],['notifyManagement','Notify township management about critical anomalies']
        ].map((x)=>SwitchListTile(contentPadding:EdgeInsets.zero,title:Text(x[1],style:const TextStyle(fontSize:13)),value:settings[x[0]] ?? false,onChanged:(v)=>setD(()=>settings[x[0]]=v))).toList(),
        const Text('Only opt-in status and necessary alert details are shared with management. Guards do not receive your travel dates or utility readings.',style:TextStyle(fontSize:12,color:muted))
      ])),actions:[TextButton(onPressed:()=>Navigator.pop(ctx,false),child:const Text('Cancel')),FilledButton(onPressed:()=>Navigator.pop(ctx,true),child:const Text('Update Holiday Mode'))])));
    if(result==true){
      if(e.isBefore(s)){toast('Please select valid departure and return dates.');return;}
      setState(()=>{startDate=s,endDate=e,occasion=occ,away=true,houses.firstWhere((h)=>h.mine).away=true});
      toast('Holiday Mode settings updated.');
    }
  }

  Future<void> taskDialog({TaskItem? edit}) async {
    if(!isManagement)return;
    final title=TextEditingController(text:edit?.title??'');
    final instruction=TextEditingController(text:edit?.instruction??'');
    String zone=edit?.zone??zones[0],priority=edit?.priority??'High',assigned=edit?.assigned??guards[0];
    final ok=await showDialog<bool>(context:context,builder:(ctx)=>StatefulBuilder(builder:(ctx,setD)=>AlertDialog(
      title:Text(edit==null?'Create a security task':'Assign security guard'),
      content:SingleChildScrollView(child:Column(mainAxisSize:MainAxisSize.min,children:[
        if(edit==null)TextField(controller:title,decoration:const InputDecoration(labelText:'Task title',hintText:'e.g. Verify sensor incident')),
        DropdownButtonFormField(value:zone,decoration:const InputDecoration(labelText:'Operational zone'),items:zones.map((x)=>DropdownMenuItem(value:x,child:Text(x))).toList(),onChanged:(v){if(v!=null)setD(()=>zone=v);}),
        if(edit==null)DropdownButtonFormField(value:priority,decoration:const InputDecoration(labelText:'Priority'),items:['High','Medium','Low'].map((x)=>DropdownMenuItem(value:x,child:Text(x))).toList(),onChanged:(v){if(v!=null)setD(()=>priority=v);}),
        DropdownButtonFormField(value:assigned,decoration:const InputDecoration(labelText:'Assigned guard'),items:guards.map((x)=>DropdownMenuItem(value:x,child:Text(x))).toList(),onChanged:(v){if(v!=null)setD(()=>assigned=v);}),
        if(edit==null)TextField(controller:instruction,decoration:const InputDecoration(labelText:'Instructions',hintText:'Operational instruction only')),
      ])),actions:[TextButton(onPressed:()=>Navigator.pop(ctx,false),child:const Text('Cancel')),FilledButton(onPressed:()=>Navigator.pop(ctx,true),child:Text(edit==null?'Create task':'Save assignment'))])));
    if(ok==true){
      setState((){
        if(edit!=null){edit.assigned=assigned;edit.zone=zone;}
        else if(title.text.trim().isNotEmpty)tasks.insert(0,TaskItem(nextTask++,title.text.trim(),zone,priority,'Pending',assigned,instruction.text.trim().isEmpty?'Follow standard safety procedures.':instruction.text.trim()));
      });
      toast(edit==null?'Task assigned to $assigned.':'Task assigned to $assigned.');
    }
  }

  Future<void> reviewAlert(AlertItem a) async {
    if(!isResident)setState(()=>a.status='Reviewing');
    await showDialog(context:context,builder:(ctx)=>AlertDialog(title:const Text('Review incident'),content:Column(mainAxisSize:MainAxisSize.min,crossAxisAlignment:CrossAxisAlignment.start,children:[
      Text(a.explanation),const SizedBox(height:12),Text('Type: ${typeName(a.type)}'),Text('Zone: ${a.zone}'),Text('Severity: ${a.severity.toUpperCase()}'),if(a.action.isNotEmpty)Text('Recommended action: ${a.action}')
    ]),actions:[TextButton(onPressed:()=>Navigator.pop(ctx),child:const Text('Close')),if(!isResident)FilledButton(onPressed:(){setState(()=>a.status='Completed');Navigator.pop(ctx);toast('Alert status updated to Completed.');},child:const Text('Resolve alert'))]));
    setState((){});
  }

  Future<void> reportDialog() async {
    final done=tasks.where((t)=>t.status=='Done'||t.status=='Completed').length;
    final open=alerts.where((a)=>a.status!='Closed'&&a.status!='Resolved'&&a.status!='Completed').length;
    final closed=alerts.where((a)=>a.status=='Closed'||a.status=='Resolved'||a.status=='Completed').length;
    await showDialog(context:context,builder:(ctx)=>AlertDialog(title:const Text('Township activity report'),content:Column(mainAxisSize:MainAxisSize.min,crossAxisAlignment:CrossAxisAlignment.start,children:[
      Text('Report generated: $nowText'),const Divider(),reportLine('Open alerts','Water, electricity and possible forced-entry',open),reportLine('Closed alerts','Incident records',closed),reportLine('Completed tasks','Guard completion records',done),reportLine('Holiday Mode homes','Illustrative opt-in count',houses.where((h)=>h.away).length),const SizedBox(height:12),const Text('Report generated from current application data. Verify records before operational use.',style:TextStyle(fontSize:12,color:muted))
    ]),actions:[TextButton(onPressed:()=>Navigator.pop(ctx),child:const Text('Close')),FilledButton.icon(onPressed:exportPdf,icon:const Icon(Icons.picture_as_pdf),label:const Text('Export PDF'))]));
  }
  Widget reportLine(String title,String sub,int value)=>Padding(padding:const EdgeInsets.symmetric(vertical:7),child:Row(children:[Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(title,style:const TextStyle(fontWeight:FontWeight.bold)),Text(sub,style:const TextStyle(fontSize:11,color:muted))])),Text('$value',style:const TextStyle(fontSize:20,fontWeight:FontWeight.bold))]));
  Future<void> exportPdf() async {
    final doc=pw.Document();
    final done=tasks.where((t)=>t.status=='Done'||t.status=='Completed').length;
    final open=alerts.where((a)=>!['Closed','Resolved','Completed'].contains(a.status)).length;
    final closed=alerts.length-open;
    doc.addPage(pw.Page(build:(ctx)=>pw.Column(crossAxisAlignment:pw.CrossAxisAlignment.start,children:[
      pw.Text('Balik Kampung Mode',style:pw.TextStyle(fontSize:24,fontWeight:pw.FontWeight.bold)),
      pw.Text('Township Activity Report',style:const pw.TextStyle(fontSize:18)),
      pw.SizedBox(height:12),pw.Text('Generated: $nowText'),pw.Divider(),
      for(final row in [['Open alerts','$open'],['Closed alerts','$closed'],['Completed tasks','$done'],['Holiday Mode homes','${houses.where((h)=>h.away).length}']])
        pw.Padding(padding:const pw.EdgeInsets.symmetric(vertical:10),child:pw.Row(mainAxisAlignment:pw.MainAxisAlignment.spaceBetween,children:[pw.Text(row[0]),pw.Text(row[1],style:pw.TextStyle(fontSize:18,fontWeight:pw.FontWeight.bold))])),
      pw.SizedBox(height:20),pw.Text('Report generated from the current application data. Verify records before operational use.')
    ])));
    await Printing.layoutPdf(onLayout:(format)=>doc.save());
  }

  void showNotifications() {
    if (isGuard) return;
    final items=visibleAlerts.where((a)=>!['Closed','Resolved','Completed'].contains(a.status)).toList();
    showModalBottomSheet(
      context:context,
      isScrollControlled:true,
      backgroundColor:Colors.transparent,
      builder:(ctx)=>SafeArea(child:Container(
        constraints:BoxConstraints(maxHeight:MediaQuery.of(ctx).size.height*.78),
        decoration:const BoxDecoration(color:Color(0xFFF5F8F6),borderRadius:BorderRadius.vertical(top:Radius.circular(26))),
        child:Column(mainAxisSize:MainAxisSize.min,children:[
          const SizedBox(height:10),Container(width:42,height:4,decoration:BoxDecoration(color:Color(0xFFC9D8D0),borderRadius:BorderRadius.circular(5))),
          Padding(padding:const EdgeInsets.fromLTRB(20,18,20,12),child:Row(children:[
            Container(width:42,height:42,decoration:BoxDecoration(color:const Color(0xFFDDF3E9),borderRadius:BorderRadius.circular(14)),child:const Icon(Icons.notifications_active_rounded,color:green)),
            const SizedBox(width:12),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
              const Text('Notifications',style:TextStyle(fontSize:18,fontWeight:FontWeight.w800,color:navy)),
              Text('${items.length} open item${items.length==1?'':'s'} need attention',style:const TextStyle(fontSize:11,color:muted)),
            ])),
            IconButton(onPressed:()=>Navigator.pop(ctx),icon:const Icon(Icons.close_rounded)),
          ])),
          const Divider(height:1),
          if(items.isEmpty) const Expanded(child:Center(child:Padding(padding:EdgeInsets.all(28),child:Column(mainAxisSize:MainAxisSize.min,children:[Icon(Icons.notifications_off_outlined,size:42,color:green),SizedBox(height:10),Text('You are all caught up',style:TextStyle(fontWeight:FontWeight.w800,color:navy)),SizedBox(height:4),Text('There are no open alerts right now.',style:TextStyle(color:muted,fontSize:12))]))))
          else Expanded(child:ListView.separated(padding:const EdgeInsets.all(16),itemCount:items.length,itemBuilder:(ctx,i){final a=items[i];final high=a.severity.toLowerCase()=='high';final c=high?const Color(0xFFD93645):a.severity.toLowerCase()=='medium'?const Color(0xFFC18424):const Color(0xFF3977C8);return Container(padding:const EdgeInsets.all(14),decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(17),border:Border.all(color:c.withValues(alpha:.22))),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
            Row(children:[Icon(a.type=='water'?Icons.water_drop_rounded:a.type=='electricity'?Icons.bolt_rounded:Icons.door_front_door_outlined,color:c),const SizedBox(width:9),Expanded(child:Text('${typeName(a.type)} anomaly',style:const TextStyle(fontWeight:FontWeight.w800,color:navy))),Container(padding:const EdgeInsets.symmetric(horizontal:9,vertical:5),decoration:BoxDecoration(color:c.withValues(alpha:.1),borderRadius:BorderRadius.circular(20)),child:Text(a.severity.toUpperCase(),style:TextStyle(color:c,fontSize:9,fontWeight:FontWeight.w800)))]),
            const SizedBox(height:7),Text(a.explanation,style:const TextStyle(fontSize:12,height:1.4,color:Color(0xFF40534A))),
            const SizedBox(height:8),Row(children:[const Icon(Icons.access_time_rounded,size:13,color:muted),const SizedBox(width:5),Expanded(child:Text(a.time,style:const TextStyle(fontSize:10,color:muted))),TextButton(onPressed:(){Navigator.pop(ctx);reviewAlert(a);},child:const Text('Review'))])
          ]));},separatorBuilder:(ctx,i)=>const SizedBox(height:10))),
        ]),
      )),
    );
  }

  Future<void> editProfile() async {
    final nameController=TextEditingController(text:name.trim().isEmpty?roleName:name);
    final emailController=TextEditingController(text:email);
    final passwordController=TextEditingController(text:password);
    final ok=await showDialog<bool>(context:context,builder:(ctx)=>AlertDialog(
      title:const Text('Edit profile'),
      content:SingleChildScrollView(child:Column(mainAxisSize:MainAxisSize.min,children:[
        TextField(controller:nameController,decoration:const InputDecoration(labelText:'Display name',prefixIcon:Icon(Icons.person_outline))),
        const SizedBox(height:10),TextField(controller:emailController,keyboardType:TextInputType.emailAddress,decoration:const InputDecoration(labelText:'Email address',prefixIcon:Icon(Icons.email_outlined))),
        const SizedBox(height:10),TextField(controller:passwordController,obscureText:true,decoration:const InputDecoration(labelText:'Password (session only)',prefixIcon:Icon(Icons.lock_outline))),
      ])),
      actions:[TextButton(onPressed:()=>Navigator.pop(ctx,false),child:const Text('Cancel')),FilledButton(onPressed:()=>Navigator.pop(ctx,true),child:const Text('Save changes'))],
    ));
    if(ok==true){
      final newEmail=emailController.text.trim();
      if(nameController.text.trim().isEmpty||!newEmail.contains('@')||passwordController.text.isEmpty){toast('Enter a name, valid email address and password.');return;}
      setState(()=>{name=nameController.text.trim(),email=newEmail,password=passwordController.text});
      toast('Profile updated for this session.');
    }
    nameController.dispose();emailController.dispose();passwordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if(showSplash)return splashScreen();
    if(!signedIn)return authScreen();
    final destinations=<({String id,String label,IconData icon,Color color})>[
      (id:'overview',label:'Overview',icon:Icons.dashboard_rounded,color:const Color(0xFF168B68)),
      if(isResident)(id:'away',label:'Holiday Mode',icon:Icons.beach_access_rounded,color:const Color(0xFF8A62C7)),
      if(!isGuard)(id:'sensors',label:'Water & Energy',icon:Icons.water_drop_rounded,color:const Color(0xFF2687D8)),
      if(!isResident)(id:'security',label:'Security Tasks',icon:Icons.shield_rounded,color:const Color(0xFFE09A25)),
      if(!isGuard)(id:'alerts',label:'Alerts',icon:Icons.notifications_active_rounded,color:const Color(0xFFD94A55)),
      if(isManagement)(id:'reports',label:'Reports',icon:Icons.assessment_rounded,color:const Color(0xFF3478C8)),
      (id:'profile',label:'Profile',icon:Icons.person_rounded,color:const Color(0xFF159B82)),
    ];
    return Scaffold(
      appBar:AppBar(
        toolbarHeight:82,
        titleSpacing:16,
        centerTitle:false,
        title:Row(children:[
          Container(width:42,height:42,decoration:BoxDecoration(gradient:const LinearGradient(colors:[green,Color(0xFF0D8768)]),borderRadius:BorderRadius.circular(14)),child:const Icon(Icons.home_work_rounded,color:Colors.white,size:23)),
          const SizedBox(width:11),
          Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
            Text(pageTitle,style:const TextStyle(fontWeight:FontWeight.w800,fontSize:18,color:navy,letterSpacing:-.35)),
            const SizedBox(height:3),
            Text(pageSubtitle,maxLines:1,overflow:TextOverflow.ellipsis,style:const TextStyle(fontSize:10,color:Color(0xFF75877E))),
          ])),
        ]),
        actions:[
          IconButton(
            tooltip:'Notifications',
            onPressed:showNotifications,
            icon:Stack(clipBehavior:Clip.none,children:[
              const Icon(Icons.notifications_none_rounded,size:25),
              if(openAlerts>0)Positioned(right:-2,top:-2,child:Container(width:9,height:9,decoration:const BoxDecoration(color:Color(0xFFE35B63),shape:BoxShape.circle))),
            ]),
          ),
          Padding(padding:const EdgeInsets.only(right:14,left:2),child:PopupMenuButton<String>(tooltip:roleName,onSelected:(v){if(v=='profile')go('profile');if(v=='privacy')privacyDialog();if(v=='help')helpDialog();if(v=='logout')signOut();},itemBuilder:(ctx)=>const [PopupMenuItem(value:'profile',child:Text('My profile')),PopupMenuItem(value:'privacy',child:Text('Privacy & access')),PopupMenuItem(value:'help',child:Text('How it works')),PopupMenuItem(value:'logout',child:Text('Sign out'))],child:CircleAvatar(radius:18,backgroundColor:const Color(0xFFDDF3E9),child:Text(isManagement?'TM':isResident?'RS':'SG',style:const TextStyle(color:Color(0xFF087B5C),fontSize:11,fontWeight:FontWeight.w800))))),
        ],
      ),
      body:LayoutBuilder(builder:(ctx,c)=>Center(child:ConstrainedBox(constraints:const BoxConstraints(maxWidth:1100),child:ListView(padding:const EdgeInsets.fromLTRB(16,10,16,38),children:[
        if(page=='overview') ...overviewWidgets(),
        if(page=='profile') ...profileWidgets(),
        if(page=='away') ...awayWidgets(),
        if(page=='sensors') ...sensorWidgets(),
        if(page=='security') ...taskWidgets(),
        if(page=='alerts') ...alertWidgets(),
        if(page=='reports') ...reportWidgets(),
      ])))),
      bottomNavigationBar:Container(
        decoration:BoxDecoration(color:Colors.white,boxShadow:[BoxShadow(color:const Color(0xFF173B2D).withValues(alpha:.10),blurRadius:14,offset:const Offset(0,-4))]),
        child:SafeArea(top:false,child:SizedBox(height:76,child:Row(
          crossAxisAlignment:CrossAxisAlignment.stretch,
          children:destinations.map((d){
            final selected=page==d.id;
            return Expanded(child:InkWell(
              onTap:()=>go(d.id),
              child:Padding(padding:const EdgeInsets.symmetric(vertical:6,horizontal:2),child:Column(
                mainAxisAlignment:MainAxisAlignment.center,
                mainAxisSize:MainAxisSize.max,
                children:[
                  AnimatedContainer(duration:const Duration(milliseconds:180),padding:const EdgeInsets.symmetric(horizontal:13,vertical:4),decoration:BoxDecoration(color:selected?d.color.withValues(alpha:.16):Colors.transparent,borderRadius:BorderRadius.circular(16)),child:Icon(d.icon,size:23,color:d.color)),
                  const SizedBox(height:3),
                  Text(d.label,textAlign:TextAlign.center,maxLines:2,overflow:TextOverflow.ellipsis,style:TextStyle(fontSize:10,fontWeight:selected?FontWeight.w900:FontWeight.w600,height:1.05,color:selected?d.color:const Color(0xFF52615A))),
                ],
              )),
            ));
          }).toList(),
        ))),
      ),
    );
  }

  Widget splashScreen()=>Scaffold(body:Container(width:double.infinity,decoration:const BoxDecoration(gradient:LinearGradient(begin:Alignment.topLeft,end:Alignment.bottomRight,colors:[Color(0xFF092D35),Color(0xFF087B68),Color(0xFF19A47C)])),child:Stack(children:[Positioned(top:-70,right:-55,child:Container(width:240,height:240,decoration:BoxDecoration(shape:BoxShape.circle,color:Colors.white.withOpacity(.06)))),Positioned(bottom:-90,left:-60,child:Container(width:260,height:260,decoration:BoxDecoration(shape:BoxShape.circle,border:Border.all(color:Colors.white.withOpacity(.08),width:35)))),Center(child:Column(mainAxisSize:MainAxisSize.min,children:[Container(width:112,height:112,decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(34),boxShadow:[BoxShadow(color:Colors.black.withOpacity(.18),blurRadius:35,offset:const Offset(0,15))]),child:const Icon(Icons.home_work_rounded,size:62,color:Color(0xFF0C9671))),const SizedBox(height:26),const Text('BALIK KAMPUNG',style:TextStyle(color:Colors.white,fontSize:25,fontWeight:FontWeight.w900,letterSpacing:1.4)),const Text('MODE',style:TextStyle(color:Color(0xFFB9F2D7),fontSize:15,fontWeight:FontWeight.w800,letterSpacing:5)),const SizedBox(height:14),Text('Your home. Your peace of mind.',style:TextStyle(color:Colors.white.withOpacity(.82),fontSize:13)),const SizedBox(height:34),const SizedBox(width:28,height:28,child:CircularProgressIndicator(strokeWidth:2.5,color:Colors.white))]))])));

  List<Widget> profileWidgets()=>[
    Container(width:double.infinity,padding:const EdgeInsets.all(22),decoration:BoxDecoration(borderRadius:BorderRadius.circular(25),gradient:const LinearGradient(colors:[Color(0xFF103849),Color(0xFF087F69)])),child:Column(children:[
      Stack(clipBehavior:Clip.none,children:[
        CircleAvatar(radius:38,backgroundColor:Colors.white.withValues(alpha:.18),child:Icon(isManagement?Icons.admin_panel_settings_rounded:isResident?Icons.person_rounded:Icons.shield_rounded,size:42,color:Colors.white)),
        Positioned(right:-2,bottom:-2,child:Material(color:const Color(0xFFDDF3E9),shape:const CircleBorder(),child:InkWell(customBorder:const CircleBorder(),onTap:editProfile,child:const Padding(padding:EdgeInsets.all(8),child:Icon(Icons.edit_rounded,size:16,color:Color(0xFF087B5C))))))
      ]),
      const SizedBox(height:12),Text(name.trim().isEmpty?roleName:name,style:const TextStyle(color:Colors.white,fontSize:21,fontWeight:FontWeight.w800)),const SizedBox(height:5),Text(email,style:TextStyle(color:Colors.white.withValues(alpha:.82),fontSize:12)),const SizedBox(height:10),Container(padding:const EdgeInsets.symmetric(horizontal:13,vertical:6),decoration:BoxDecoration(color:Colors.white.withValues(alpha:.16),borderRadius:BorderRadius.circular(30)),child:Text(isManagement?'TOWNSHIP MANAGEMENT':isResident?'RESIDENT ACCOUNT':'SECURITY GUARD',style:const TextStyle(color:Colors.white,fontSize:10,fontWeight:FontWeight.w800,letterSpacing:.8)))
    ])),
    const SizedBox(height:16),
    panel('Account information','Your current application profile',[
      profileLine(Icons.person_outline,'Display name',name.trim().isEmpty?roleName:name),profileLine(Icons.email_outlined,'Email address',email),profileLine(Icons.verified_user_outlined,'Access role',isManagement?'Township Manager':isResident?'Resident':'Security Guard'),if(isGuard)profileLine(Icons.badge_outlined,'Assigned guard',guardName),
    ]),const SizedBox(height:14),
    panel('Preferences & support','Manage your experience and understand your privacy',[
      ListTile(contentPadding:EdgeInsets.zero,leading:const Icon(Icons.privacy_tip_outlined,color:green),title:const Text('Privacy & role access'),subtitle:const Text('Understand what each role can view',style:TextStyle(fontSize:11)),trailing:const Icon(Icons.chevron_right),onTap:privacyDialog),
      ListTile(contentPadding:EdgeInsets.zero,leading:const Icon(Icons.help_outline_rounded,color:green),title:const Text('How the app works'),subtitle:const Text('Read guidance about alerts and monitoring',style:TextStyle(fontSize:11)),trailing:const Icon(Icons.chevron_right),onTap:helpDialog),
      ListTile(contentPadding:EdgeInsets.zero,leading:const Icon(Icons.logout_rounded,color:Color(0xFFC34D58)),title:const Text('Sign out'),subtitle:const Text('Return to the sign-in screen',style:TextStyle(fontSize:11)),trailing:const Icon(Icons.chevron_right),onTap:signOut),
    ]),const SizedBox(height:12),const Text('Account changes are kept during this session.',style:TextStyle(fontSize:11,color:muted),textAlign:TextAlign.center)
  ];
  Widget profileLine(IconData icon,String label,String value)=>Padding(padding:const EdgeInsets.symmetric(vertical:9),child:Row(children:[Icon(icon,color:green,size:20),const SizedBox(width:12),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(label,style:const TextStyle(fontSize:10,color:muted)),const SizedBox(height:3),Text(value,style:const TextStyle(fontSize:13,fontWeight:FontWeight.w700,color:navy))]))]));

  Widget authScreen() {
    final gradient = const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF092D35), Color(0xFF087B68), Color(0xFF19A47C)],
    );

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: gradient),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: Column(
                  children: [
                    Container(
                      width: 76,
                      height: 76,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(.16),
                            blurRadius: 24,
                            offset: const Offset(0, 9),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.home_work_rounded,
                        size: 43,
                        color: Color(0xFF0C9671),
                      ),
                    ),
                    const SizedBox(height: 13),
                    const Text(
                      'BALIK KAMPUNG MODE',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Smart home monitoring. Peace of mind while you are away.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withOpacity(.82),
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Card(
                      elevation: 18,
                      shadowColor: const Color(0xFF052F2B).withValues(alpha:.20),
                      color: const Color(0xFFFBFEFC),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                        side: const BorderSide(color: Color(0xFFDCEDE5),width:1),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Align(alignment:Alignment.centerLeft,child:Container(padding:const EdgeInsets.symmetric(horizontal:11,vertical:7),decoration:BoxDecoration(color:const Color(0xFFE4F5ED),borderRadius:BorderRadius.circular(30)),child:Row(mainAxisSize:MainAxisSize.min,children:[const Icon(Icons.verified_user_rounded,size:14,color:Color(0xFF087F68)),const SizedBox(width:6),Text(signup?'ACCOUNT SETUP':'SMART TOWNSHIP ACCESS',style:const TextStyle(fontSize:9,fontWeight:FontWeight.w900,letterSpacing:1,color:Color(0xFF087F68)))]))),
                            const SizedBox(height:13),
                            Text(
                              signup ? 'Create your account' : 'Welcome home',
                              style: const TextStyle(
                                fontSize: 27,
                                letterSpacing: -.5,
                                fontWeight: FontWeight.w900,
                                color: navy,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              signup
                                  ? 'Set up your profile to get started.'
                                  : 'Sign in to access your personalised home and township services.',
                              style: const TextStyle(
                                color: muted,
                                fontSize: 12,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 18),
                            SegmentedButton<bool>(
                              showSelectedIcon: false,
                              segments: const [
                                ButtonSegment(
                                  value: false,
                                  label: Text('Sign in'),
                                  icon: Icon(Icons.login_rounded),
                                ),
                                ButtonSegment(
                                  value: true,
                                  label: Text('Register'),
                                  icon: Icon(Icons.person_add_alt_1_rounded),
                                ),
                              ],
                              selected: {signup},
                              onSelectionChanged: (values) {
                                setState(() => signup = values.first);
                              },
                            ),
                            const SizedBox(height: 17),
                            const Text(
                              'CHOOSE YOUR ACCESS',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: muted,
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(height: 9),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                for (final role in [
                                  'management',
                                  'resident',
                                  if (!signup) 'guard',
                                ])
                                  ChoiceChip(
                                    avatar: Icon(
                                      role == 'management'
                                          ? Icons.apartment_rounded
                                          : role == 'resident'
                                              ? Icons.home_rounded
                                              : Icons.shield_rounded,
                                      size: 17,
                                    ),
                                    label: Text(
                                      role == 'management'
                                          ? 'Management'
                                          : role == 'resident'
                                              ? 'Resident'
                                              : 'Security guard',
                                    ),
                                    selected: authRole == role,
                                    onSelected: (_) {
                                      setState(() => authRole = role);
                                    },
                                  ),
                              ],
                            ),
                            if (signup)
                              Padding(
                                padding: const EdgeInsets.only(top: 13),
                                child: TextField(
                                  decoration: const InputDecoration(
                                    prefixIcon: Icon(Icons.person_outline),
                                    labelText: 'Full name',
                                  ),
                                  onChanged: (value) => name = value,
                                ),
                              ),
                            if (!signup && authRole == 'guard')
                              Padding(
                                padding: const EdgeInsets.only(top: 13),
                                child: DropdownButtonFormField<String>(
                                  value: guardName,
                                  decoration: const InputDecoration(
                                    prefixIcon: Icon(Icons.badge_outlined),
                                    labelText: 'Security guard account',
                                  ),
                                  items: guards
                                      .map((guard) => DropdownMenuItem(
                                            value: guard,
                                            child: Text(guard),
                                          ))
                                      .toList(),
                                  onChanged: (value) {
                                    if (value != null) {
                                      setState(() => guardName = value);
                                    }
                                  },
                                ),
                              ),
                            if (signup && authRole == 'management')
                              Padding(
                                padding: const EdgeInsets.only(top: 13),
                                child: DropdownButtonFormField<String>(
                                  value: accountType,
                                  decoration: const InputDecoration(
                                    prefixIcon: Icon(Icons.manage_accounts_outlined),
                                    labelText: 'Account to create',
                                  ),
                                  items: const [
                                    DropdownMenuItem(
                                      value: 'management',
                                      child: Text('Township management account'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'guard',
                                      child: Text('Security guard account'),
                                    ),
                                  ],
                                  onChanged: (value) {
                                    if (value != null) {
                                      setState(() => accountType = value);
                                    }
                                  },
                                ),
                              ),
                            const SizedBox(height: 13),
                            TextField(
                              key: const ValueKey('auth-email'),
                              controller: TextEditingController(text: email)
                                ..selection = TextSelection.collapsed(offset: email.length),
                              decoration: const InputDecoration(
                                prefixIcon: Icon(Icons.email_outlined),
                                labelText: 'Email address',
                                hintText: 'name@example.com',
                              ),
                              keyboardType: TextInputType.emailAddress,
                              onChanged: (value) => email = value,
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              key: const ValueKey('auth-password'),
                              controller: TextEditingController(text: password)
                                ..selection = TextSelection.collapsed(offset: password.length),
                              decoration: const InputDecoration(
                                prefixIcon: Icon(Icons.lock_outline_rounded),
                                labelText: 'Password',
                              ),
                              obscureText: true,
                              onChanged: (value) => password = value,
                            ),
                            const SizedBox(height: 13),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEFF8F3),
                                borderRadius: BorderRadius.circular(13),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(
                                    Icons.info_outline_rounded,
                                    color: green,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 9),
                                  Expanded(
                                    child: Text(
                                      signup
                                          ? 'Residents can register. Management can create management or guard accounts.'
                                          : 'Choose the correct role. Your dashboard and available information depend on your access.',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Color(0xFF41695B),
                                        height: 1.4,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 17),
                            SizedBox(
                              height: 56,
                              child: FilledButton.icon(
                                style: FilledButton.styleFrom(
                                  backgroundColor: const Color(0xFF087F68),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(17),
                                  ),
                                ),
                                onPressed: () {
                                  if (signup) {
                                    if (name.trim().isEmpty ||
                                        email.trim().isEmpty ||
                                        password.isEmpty) {
                                      toast('Please complete name, email and password.');
                                      return;
                                    }
                                    if (authRole == 'guard') {
                                      toast('Security guards cannot create their own accounts.');
                                      return;
                                    }
                                    final target = authRole == 'management'
                                        ? accountType
                                        : 'resident';
                                    toast(target == 'guard'
                                        ? 'Security guard account created by management.'
                                        : 'Account created. You can now sign in.');
                                    setState(() {
                                      signup = false;
                                      authRole = target;
                                    });
                                  } else {
                                    login();
                                  }
                                },
                                icon: Icon(signup
                                    ? Icons.person_add_alt_1
                                    : Icons.lock_open_rounded),
                                label: Text(
                                  signup ? 'Create account' : 'Sign In',
                                  style: const TextStyle(fontWeight: FontWeight.w800),
                                ),
                              ),
                            ),
                            if (!signup)
                              TextButton.icon(
                                onPressed: () {
                                  setState(() {
                                    email = 'manager@example.com';
                                    password = 'welcome123';
                                    authRole = 'management';
                                  });
                                  login();
                                },
                                icon: const Icon(Icons.flash_on_rounded, size: 16),
                                label: const Text('Continue as management'),
                              ),
                            const SizedBox(height: 4),
                            const Text(
                              'Use your authorised account to access your household or township view.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: muted, fontSize: 9),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'A safer way to enjoy your journey home.',
                      style: TextStyle(
                        color: Colors.white.withOpacity(.78),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> overviewWidgets()=>[
    Container(
      padding:const EdgeInsets.all(21),
      decoration:BoxDecoration(
        borderRadius:BorderRadius.circular(26),
        gradient:const LinearGradient(begin:Alignment.topLeft,end:Alignment.bottomRight,colors:[Color(0xFF102F49),Color(0xFF126B61),Color(0xFF159B78)]),
        boxShadow:[BoxShadow(color:const Color(0xFF0D6554).withOpacity(.18),blurRadius:22,offset:const Offset(0,10))],
      ),
      child:Stack(children:[
        Positioned(right:-18,top:-32,child:Container(width:130,height:130,decoration:BoxDecoration(shape:BoxShape.circle,color:Colors.white.withOpacity(.055)))),
        Positioned(right:22,bottom:-52,child:Container(width:100,height:100,decoration:BoxDecoration(shape:BoxShape.circle,border:Border.all(color:Colors.white.withOpacity(.10),width:18)))),
        Positioned(right:4,top:48,child:Container(width:66,height:66,decoration:BoxDecoration(color:Colors.white.withOpacity(.09),shape:BoxShape.circle,border:Border.all(color:Colors.white.withOpacity(.12))),child:Icon(Icons.home_work_rounded,size:32,color:Colors.white.withOpacity(.48)))),
        Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
          Row(children:[
            Container(
              padding:const EdgeInsets.symmetric(horizontal:10,vertical:6),
              decoration:BoxDecoration(color:Colors.white.withOpacity(.14),borderRadius:BorderRadius.circular(30)),
              child:Row(mainAxisSize:MainAxisSize.min,children:[
                const Icon(Icons.auto_awesome_rounded,color:Color(0xFFB9F2D7),size:13),
                const SizedBox(width:6),
                Text(isGuard?'SECURITY OPERATIONS':isResident?'YOUR HOME, CONNECTED':'SMART TOWNSHIP CONTROL',style:const TextStyle(color:Colors.white,fontSize:9,fontWeight:FontWeight.w800,letterSpacing:1)),
              ]),
            ),
          ]),
          const SizedBox(height:17),
          Text(isManagement?'Peace of mind,\neven when you’re away.':isResident?'Your home.\nYour peace of mind.':'Stay alert.\nKeep the township safe.',style:const TextStyle(color:Colors.white,fontSize:25,height:1.13,fontWeight:FontWeight.w800,letterSpacing:-.5)),
          const SizedBox(height:9),
          Text(isManagement?'One clear view of home activity, alerts and security response.':isResident?'Keep an eye on your home and prepare it before your next journey.':'See your assigned work and verify incidents responsibly.',style:TextStyle(color:Colors.white.withOpacity(.82),fontSize:12,height:1.45)),
          const SizedBox(height:18),
          Wrap(spacing:9,runSpacing:9,children:[
            if(!isGuard)FilledButton.icon(style:FilledButton.styleFrom(backgroundColor:const Color(0xFFE3F6EC),foregroundColor:const Color(0xFF075D49),padding:const EdgeInsets.symmetric(horizontal:14,vertical:11)),onPressed:()=>addAnomaly('water'),icon:const Icon(Icons.water_drop_outlined,size:16),label:const Text('Try water alert',style:TextStyle(fontWeight:FontWeight.w700,fontSize:11))),
            if(isGuard)FilledButton.icon(style:FilledButton.styleFrom(backgroundColor:const Color(0xFFE3F6EC),foregroundColor:const Color(0xFF075D49),padding:const EdgeInsets.symmetric(horizontal:14,vertical:11)),onPressed:recordCheckpoint,icon:const Icon(Icons.location_on_outlined,size:16),label:const Text('Record checkpoint',style:TextStyle(fontWeight:FontWeight.w700,fontSize:11))),
            if(isResident)OutlinedButton.icon(style:OutlinedButton.styleFrom(foregroundColor:Colors.white,side:BorderSide(color:Colors.white.withOpacity(.5)),padding:const EdgeInsets.symmetric(horizontal:13,vertical:11)),onPressed:holidayDialog,icon:const Icon(Icons.beach_access_outlined,size:16),label:const Text('Holiday Mode',style:TextStyle(fontSize:11))),
            if(isManagement)OutlinedButton.icon(style:OutlinedButton.styleFrom(foregroundColor:Colors.white,side:BorderSide(color:Colors.white.withOpacity(.5)),padding:const EdgeInsets.symmetric(horizontal:13,vertical:11)),onPressed:()=>go('security'),icon:const Icon(Icons.shield_outlined,size:16),label:const Text('Security tasks',style:TextStyle(fontSize:11))),
          ]),
        ]),
      ]),
    ),
    const SizedBox(height:15),
    Container(padding:const EdgeInsets.all(13),decoration:BoxDecoration(color:const Color(0xFFEAF6F0),borderRadius:BorderRadius.circular(16),border:Border.all(color:const Color(0xFFD6EDE0))),child:Row(crossAxisAlignment:CrossAxisAlignment.start,children:[const Icon(Icons.lightbulb_outline_rounded,color:Color(0xFF087B5C),size:20),const SizedBox(width:10),Expanded(child:Text(isManagement?'Quick guide: review priority alerts first, then assign a guard task when an incident needs on-site verification.':isResident?'Quick guide: set your travel dates, complete the safety checklist and review alerts for your own home.':'Quick guide: review your assigned instructions, accept a task before starting and record completion after verification.',style:const TextStyle(color:Color(0xFF315F4F),fontSize:11,height:1.4)))])),
    const SizedBox(height:18),
    Row(children:[const Expanded(child:Text('Township at a glance',style:TextStyle(fontSize:17,fontWeight:FontWeight.w800,color:navy))),Container(padding:const EdgeInsets.symmetric(horizontal:9,vertical:5),decoration:BoxDecoration(color:const Color(0xFFE5F4EC),borderRadius:BorderRadius.circular(20)),child:const Text('LIVE OVERVIEW',style:TextStyle(fontSize:8,letterSpacing:.8,color:Color(0xFF087B5C),fontWeight:FontWeight.w800)))]),
    const SizedBox(height:11),
    Wrap(spacing:10,runSpacing:10,children:statCards()),
    if(!isGuard) ...[const SizedBox(height:20),...alertPanel(limit:4),const SizedBox(height:14),...sensorPanel(),const SizedBox(height:14),...housePanel()],
    if(isGuard) ...[const SizedBox(height:18),...taskPanel()],
    if(isResident) ...[const SizedBox(height:14),...awayPanel(),const SizedBox(height:12),...checkPanel()],
    if(isManagement) ...[const SizedBox(height:14),...taskPanel()],
    const SizedBox(height:18),
    const Text('BALIK KAMPUNG MODE  ·  SMART TOWNSHIP',textAlign:TextAlign.center,style:TextStyle(color:muted,fontSize:9,fontWeight:FontWeight.w700,letterSpacing:1.1))
  ];

  List<Widget> statCards(){
    final List<(String,String,IconData,String)> cards;
    if(isGuard) cards=[('Assigned tasks','${visibleTasks.where((t)=>t.status!='Done'&&t.status!='Completed').length}',Icons.assignment_outlined,'For your shift'),('Pending verification','${tasks.where((t)=>t.status=='Pending').length}',Icons.schedule_rounded,'Needs action'),('Completed tasks','${tasks.where((t)=>t.status=='Done'||t.status=='Completed').length}',Icons.check_circle_outline_rounded,'Completed records'),('Open incidents','$openAlerts',Icons.warning_amber_rounded,'Requires attention')];
    else if(isResident) cards=[('Holiday Mode',away?'Active':'Inactive',Icons.beach_access_rounded,away?'Monitoring is enabled':'Activate before travel'),('Water today','${waterToday.toStringAsFixed(0)} L',Icons.water_drop_rounded,'Today’s meter reading'),('Electricity today','${electricToday.toStringAsFixed(2)} kWh',Icons.bolt_rounded,'Today’s meter reading'),('Open alerts','$openAlerts',Icons.notifications_active_outlined,'Your home only')];
    else cards=[('Holiday Mode homes','${houses.where((h)=>h.away).length}',Icons.home_work_rounded,'Homes with monitoring enabled'),('Open alerts','$openAlerts',Icons.notifications_active_outlined,'Across all incident types'),('Water anomalies','${alerts.where((a)=>a.type=='water'&&!['Closed','Completed','Resolved'].contains(a.status)).length}',Icons.water_drop_rounded,'Needs review'),('Tasks outstanding','${tasks.where((t)=>t.status!='Done'&&t.status!='Completed').length}',Icons.assignment_rounded,'Guard assignments')];
    const iconBgs=[Color(0xFFE0F4EA),Color(0xFFE5F0FF),Color(0xFFFFF1DE),Color(0xFFF0EAFE)];
    const iconColors=[Color(0xFF0B916B),Color(0xFF3478D4),Color(0xFFD18A25),Color(0xFF8061C8)];
    return [for(int i=0;i<cards.length;i++)SizedBox(
      width:MediaQuery.of(context).size.width>700?240:(MediaQuery.of(context).size.width-42)/2,
      child:Container(padding:const EdgeInsets.all(14),decoration:BoxDecoration(gradient:const LinearGradient(begin:Alignment.topLeft,end:Alignment.bottomRight,colors:[Colors.white,Color(0xFFFAFCFB)]),borderRadius:BorderRadius.circular(20),border:Border.all(color:const Color(0xFFE3ECE6)),boxShadow:[BoxShadow(color:const Color(0xFF183B2F).withOpacity(.055),blurRadius:16,offset:const Offset(0,6))]),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
        Row(children:[Expanded(child:Text(cards[i].$1,style:const TextStyle(color:Color(0xFF63766D),fontSize:10,fontWeight:FontWeight.w700))),Container(width:34,height:34,decoration:BoxDecoration(color:iconBgs[i],borderRadius:BorderRadius.circular(12)),child:Icon(cards[i].$3,color:iconColors[i],size:18))]),
        const SizedBox(height:9),Text(cards[i].$2,style:const TextStyle(fontSize:25,fontWeight:FontWeight.w800,color:navy,letterSpacing:-.5)),
        const SizedBox(height:3),Text(cards[i].$4,maxLines:2,overflow:TextOverflow.ellipsis,style:const TextStyle(fontSize:9,height:1.3,color:muted)),
      ])),
    )];
  }

  Widget panel(String title,String subtitle,List<Widget> children,{Widget? action})=>Card(color:Colors.white,elevation:1,shadowColor:const Color(0xFF183B2F).withOpacity(.055),shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(21),side:const BorderSide(color:Color(0xFFE5EDE8))),child:Padding(padding:const EdgeInsets.all(16),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
    Row(crossAxisAlignment:CrossAxisAlignment.start,children:[Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(title,style:const TextStyle(fontSize:15,fontWeight:FontWeight.w800,color:navy)),const SizedBox(height:4),Text(subtitle,style:const TextStyle(fontSize:10,height:1.35,color:muted))])),if(action!=null)action]),
    const SizedBox(height:14),...children
  ])));
  List<Widget> alertPanel({int? limit})=>[
    panel(
      'Priority alerts',
      isResident
          ? 'Alerts related to your registered home.'
          : 'All water, electricity and possible forced-entry incidents across the township.',
      [
        if (visibleAlerts.isEmpty)
          Container(
            width:double.infinity,
            padding:const EdgeInsets.symmetric(vertical:28,horizontal:16),
            decoration:BoxDecoration(color:const Color(0xFFF7FAF8),borderRadius:BorderRadius.circular(16)),
            child:Column(children:[
              const Icon(Icons.notifications_off_outlined,size:34,color:muted),
              const SizedBox(height:8),
              const Text('No alerts to review',style:TextStyle(fontWeight:FontWeight.w700,color:navy)),
              const SizedBox(height:4),
              Text(isResident?'Your home has no recorded alerts.':'No incidents have been recorded yet.',textAlign:TextAlign.center,style:const TextStyle(fontSize:11,color:muted)),
            ]),
          )
        else ...[
          Container(
            width:double.infinity,
            padding:const EdgeInsets.symmetric(horizontal:13,vertical:11),
            margin:const EdgeInsets.only(bottom:12),
            decoration:BoxDecoration(color:const Color(0xFFF1F6F3),borderRadius:BorderRadius.circular(14)),
            child:Row(children:[
              const Icon(Icons.notifications_active_outlined,color:green,size:20),
              const SizedBox(width:9),
              const Expanded(child:Text('Open alerts',style:TextStyle(fontWeight:FontWeight.w700,color:Color(0xFF53665D),fontSize:12))),
              Text('$openAlerts',style:TextStyle(fontSize:20,fontWeight:FontWeight.w800,color:openAlerts>0?const Color(0xFFD93645):green)),
            ]),
          ),
          for(final a in (limit==null?visibleAlerts:visibleAlerts.take(limit))) alertTile(a),
          if(limit!=null&&visibleAlerts.length>limit)
            Align(alignment:Alignment.centerRight,child:TextButton(onPressed:()=>go('alerts'),child:const Text('View all alerts'))),
        ],
      ],
      action:Text('$openAlerts open',style:TextStyle(color:openAlerts>0?const Color(0xFFD93645):green,fontWeight:FontWeight.w800)),
    )
  ];

  Widget alertTile(AlertItem a){
    final high=a.severity.toLowerCase()=='high';
    final medium=a.severity.toLowerCase()=='medium';
    final severityColor=high?const Color(0xFFD93645):medium?const Color(0xFFD18A25):const Color(0xFF3977C8);
    final closed=['Closed','Resolved','Completed'].contains(a.status);
    final icon=a.type=='water'?Icons.water_drop_rounded:a.type=='electricity'?Icons.bolt_rounded:Icons.door_front_door_outlined;
    final iconBg=a.type=='water'?const Color(0xFFE8F2FF):a.type=='electricity'?const Color(0xFFFFF2DC):const Color(0xFFFFE9E9);
    return Container(
      width:double.infinity,
      margin:const EdgeInsets.only(bottom:11),
      padding:const EdgeInsets.all(13),
      decoration:BoxDecoration(color:Colors.white,border:Border.all(color:const Color(0xFFE3ECE6)),borderRadius:BorderRadius.circular(18),boxShadow:[BoxShadow(color:const Color(0xFF183B2F).withValues(alpha:.035),blurRadius:10,offset:const Offset(0,3))]),
      child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
        Row(crossAxisAlignment:CrossAxisAlignment.start,children:[
          Container(width:42,height:42,decoration:BoxDecoration(color:iconBg,borderRadius:BorderRadius.circular(13)),child:Icon(icon,color:severityColor,size:22)),
          const SizedBox(width:10),
          Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
            Text(typeName(a.type),style:const TextStyle(fontSize:15,fontWeight:FontWeight.w800,color:navy)),
            const SizedBox(height:2),
            Text(a.property,style:const TextStyle(fontSize:11,fontWeight:FontWeight.w600,color:muted)),
          ])),
          Container(padding:const EdgeInsets.symmetric(horizontal:10,vertical:6),decoration:BoxDecoration(color:severityColor.withValues(alpha:.11),borderRadius:BorderRadius.circular(20)),child:Text(a.severity[0].toUpperCase()+a.severity.substring(1).toLowerCase(),style:TextStyle(color:severityColor,fontSize:10,fontWeight:FontWeight.w800))),
        ]),
        const SizedBox(height:10),
        Row(children:[
          const Icon(Icons.location_on_outlined,size:14,color:muted),const SizedBox(width:4),
          Expanded(child:Text(a.zone,style:const TextStyle(fontSize:10,color:muted))),
          const Icon(Icons.access_time_rounded,size:14,color:muted),const SizedBox(width:4),
          Flexible(child:Text(a.time,overflow:TextOverflow.ellipsis,style:const TextStyle(fontSize:10,color:muted))),
        ]),
        const SizedBox(height:10),
        Text(a.explanation,style:const TextStyle(fontSize:12,height:1.4,color:Color(0xFF34483F))),
        const SizedBox(height:11),
        Row(children:[
          statusChip(a.status),
          const Spacer(),
          if(!closed) OutlinedButton(onPressed:()=>reviewAlert(a),style:OutlinedButton.styleFrom(foregroundColor:high?const Color(0xFFD93645):green,side:BorderSide(color:high?const Color(0xFFD93645):green),visualDensity:VisualDensity.compact,padding:const EdgeInsets.symmetric(horizontal:14,vertical:9)),child:Text(isResident?'Details':'Review')),
          if(!isResident&&!closed) const SizedBox(width:7),
          if(!isResident&&!closed) FilledButton(onPressed:()=>setState(()=>a.status='Resolved'),style:FilledButton.styleFrom(backgroundColor:high?const Color(0xFFD93645):green,foregroundColor:Colors.white,visualDensity:VisualDensity.compact,padding:const EdgeInsets.symmetric(horizontal:14,vertical:9)),child:const Text('Resolve')),
          if(!isResident&&closed) IconButton(tooltip:'Delete resolved record',onPressed:()=>confirmDeleteAlert(a),style:IconButton.styleFrom(backgroundColor:const Color(0xFFFFEEEE),foregroundColor:const Color(0xFFD93645)),icon:const Icon(Icons.delete_outline_rounded)),
        ]),
      ]),
    );
  }
  Future<void> confirmDeleteAlert(AlertItem alert) async {
    final ok=await showDialog<bool>(context:context,builder:(ctx)=>AlertDialog(
      title:const Text('Delete resolved alert?'),
      content:Text('This removes the ${typeName(alert.type).toLowerCase()} record for ${alert.property} from this session. This action cannot be undone.'),
      actions:[TextButton(onPressed:()=>Navigator.pop(ctx,false),child:const Text('Cancel')),FilledButton(style:FilledButton.styleFrom(backgroundColor:const Color(0xFFD93645)),onPressed:()=>Navigator.pop(ctx,true),child:const Text('Delete'))],
    ));
    if(ok==true){setState(()=>alerts.removeWhere((a)=>a.id==alert.id));toast('Resolved alert deleted.');}
  }

  Widget statusChip(String s){
    final value=s.toLowerCase();
    final color=value=='high'||value=='open'?const Color(0xFFD93645):value=='medium'||value=='reviewing'?const Color(0xFFC18424):value=='low'?const Color(0xFF3977C8):green;
    return Container(padding:const EdgeInsets.symmetric(horizontal:8,vertical:4),decoration:BoxDecoration(color:color.withValues(alpha:.10),borderRadius:BorderRadius.circular(20)),child:Text(s,style:TextStyle(color:color,fontSize:9,fontWeight:FontWeight.bold)));
  }
  List<Widget> sensorPanel()=>[
    panel('Water & electricity usage','Illustrative sensor readings · weekly readings',[
      DropdownButtonFormField<String>(value:chartMode,decoration:const InputDecoration(labelText:'Chart display'),items:const [DropdownMenuItem(value:'both',child:Text('Water + electricity')),DropdownMenuItem(value:'water',child:Text('Water only')),DropdownMenuItem(value:'electric',child:Text('Electricity only'))],onChanged:(v){if(v!=null)setState(()=>chartMode=v);}),
      const SizedBox(height:14),
      SizedBox(
        height:220,
        child:BarChart(
          BarChartData(
            // The chart is informational; disabling pointer tooltips avoids a
            // Flutter web mouse-tracker assertion seen with fl_chart 0.70.x.
            barTouchData: BarTouchData(enabled:false),
            minY:0,
            maxY:45,
            barGroups:List.generate(7,(i)=>BarChartGroupData(
              x:i,
              barRods:[
                if(chartMode!='electric') BarChartRodData(
                  toY:water[i].clamp(0,45).toDouble(),
                  color:const Color(0xFF3687E8),
                  width:chartMode=='both'?9:18,
                  borderRadius:BorderRadius.circular(3),
                ),
                if(chartMode!='water') BarChartRodData(
                  toY:(electric[i]*5).clamp(0,45).toDouble(),
                  color:green,
                  width:chartMode=='both'?9:18,
                  borderRadius:BorderRadius.circular(3),
                ),
              ],
            )),
            titlesData:FlTitlesData(
              leftTitles:const AxisTitles(sideTitles:SideTitles(showTitles:true,reservedSize:30)),
              rightTitles:const AxisTitles(sideTitles:SideTitles(showTitles:false)),
              topTitles:const AxisTitles(sideTitles:SideTitles(showTitles:false)),
              bottomTitles:AxisTitles(sideTitles:SideTitles(
                showTitles:true,
                getTitlesWidget:(v,m)=>Padding(
                  padding:const EdgeInsets.only(top:6),
                  child:Text(['M','T','W','T','F','S','S'][v.toInt().clamp(0,6)],style:const TextStyle(fontSize:10)),
                ),
              )),
            ),
            gridData:const FlGridData(show:true),
            borderData:FlBorderData(show:false),
          ),
        ),
      ),
      const SizedBox(height:8),Wrap(spacing:8,runSpacing:8,children:[
        OutlinedButton(onPressed:normalScenario,child:const Text('Test normal usage')),
        OutlinedButton(onPressed:()=>addAnomaly('water'),child:const Text('Test water anomaly')),
        OutlinedButton(onPressed:()=>addAnomaly('electricity'),child:const Text('Test electricity anomaly')),
        OutlinedButton(onPressed:()=>addAnomaly('intruder'),child:const Text('Test possible forced entry')),
      ]),
      const SizedBox(height:8),const Text('Anomaly detection — rule-based analysis. Usage is compared with illustrative expected values. An anomaly is a signal for review, not proof of a leak or crime.',style:TextStyle(fontSize:11,color:muted))
    ])
  ];
  List<Widget> housePanel()=>[
    panel(
      isResident?'Your household':'Township household monitoring',
      isResident?'Only your own home readings are shown.':'Management view of opted-in household monitoring data.',
      [
        for(final h in (isResident?houses.where((h)=>h.mine):houses))
          Container(
            width:double.infinity,
            margin:const EdgeInsets.only(bottom:10),
            padding:const EdgeInsets.all(13),
            decoration:BoxDecoration(
              color:const Color(0xFFFAFCFB),
              border:Border.all(color:const Color(0xFFE5EDE8)),
              borderRadius:BorderRadius.circular(16),
            ),
            child:Column(
              crossAxisAlignment:CrossAxisAlignment.start,
              children:[
                Row(
                  crossAxisAlignment:CrossAxisAlignment.start,
                  children:[
                    Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
                      Text(h.id,style:const TextStyle(fontSize:15,fontWeight:FontWeight.w800,color:navy)),
                      const SizedBox(height:3),
                      Text(isResident?'Your home':h.zone,style:const TextStyle(fontSize:11,color:muted)),
                    ])),
                    statusChip(h.status),
                  ],
                ),
                const SizedBox(height:12),
                Row(children:[
                  Expanded(child:_houseMetric(Icons.water_drop_outlined,'${h.water.toStringAsFixed(0)} L','Water usage',const Color(0xFF3687E8))),
                  const SizedBox(width:9),
                  Expanded(child:_houseMetric(Icons.bolt_rounded,'${h.electric.toStringAsFixed(1)} kWh','Electricity',green)),
                ]),
              ],
            ),
          ),
        if((isResident?houses.where((h)=>h.mine):houses).isEmpty)
          const Padding(padding:EdgeInsets.symmetric(vertical:12),child:Text('No household readings are available yet.',style:TextStyle(color:muted,fontSize:12))),
      ],
    )
  ];

  Widget _houseMetric(IconData icon,String value,String label,Color color)=>Container(
    padding:const EdgeInsets.symmetric(horizontal:10,vertical:10),
    decoration:BoxDecoration(color:color.withValues(alpha:.08),borderRadius:BorderRadius.circular(12)),
    child:Row(children:[
      Icon(icon,color:color,size:18),
      const SizedBox(width:7),
      Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
        Text(value,maxLines:1,overflow:TextOverflow.ellipsis,style:const TextStyle(fontSize:12,fontWeight:FontWeight.w800,color:navy)),
        const SizedBox(height:2),
        Text(label,maxLines:1,overflow:TextOverflow.ellipsis,style:const TextStyle(fontSize:9,color:muted)),
      ])),
    ]),
  );
  List<Widget> awayPanel()=>[
    panel('Resident Holiday Mode','OPT-IN · Home monitoring preferences',[
      ListTile(contentPadding:EdgeInsets.zero,leading:const Icon(Icons.beach_access,color:green),title:Text(away?'Holiday Mode is active':'Holiday Mode is inactive'),subtitle:Text(away?'$occasion · ${startDate.toString().substring(0,10)} to ${endDate.toString().substring(0,10)}':'No holiday dates saved yet')),
      SizedBox(width:double.infinity,child:FilledButton.tonal(onPressed:holidayDialog,child:Text(away?'Manage Holiday Mode':'Set up Holiday Mode')))
    ])
  ];
  List<Widget> checkPanel()=>[
    panel('Before you leave','A quick home-safety checklist',[
      ...['Lock doors and windows','Turn off unused appliances','Check taps and water valves','Set Holiday Mode dates'].asMap().entries.map((e)=>CheckboxListTile(contentPadding:EdgeInsets.zero,value:checklist[e.key],onChanged:(v){if(v!=null)setState(()=>checklist[e.key]=v);},title:Text(e.value,style:const TextStyle(fontSize:12)),subtitle:Text(['Check every entry point.','Keep essential devices powered.','Reduce leak risk while away.','Make sure return date is correct.'][e.key],style:const TextStyle(fontSize:10,color:muted)))),
      LinearProgressIndicator(value:checklist.where((x)=>x).length/4,color:green,backgroundColor:const Color(0xFFE7EDF5)),
      Align(alignment:Alignment.centerRight,child:Text('${checklist.where((x)=>x).length}/4 completed',style:const TextStyle(fontSize:11,color:muted)))
    ])
  ];
  List<Widget> taskPanel()=>[
    panel(isGuard?'My assigned tasks':'Security task queue',isGuard?'Only your assigned operational tasks are shown.':'Management assigns tasks to named guards; completion is reviewable.',[
      if(isManagement)Align(alignment:Alignment.centerRight,child:FilledButton.icon(onPressed:()=>taskDialog(),icon:const Icon(Icons.add),label:const Text('New task'))),
      if(visibleTasks.isEmpty)const Text('No tasks assigned to you.',style:TextStyle(color:muted)),
      for(final t in visibleTasks)Container(margin:const EdgeInsets.only(bottom:10),padding:const EdgeInsets.all(13),decoration:BoxDecoration(border:Border.all(color:const Color(0xFFE7EDF5)),borderRadius:BorderRadius.circular(13)),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
        Row(children:[Expanded(child:Text(t.title,style:const TextStyle(fontWeight:FontWeight.bold))),statusChip(t.priority)]),
        Text(t.zone,style:const TextStyle(fontSize:11,color:muted)),const SizedBox(height:5),Text(t.instruction,style:const TextStyle(fontSize:11)),
        const SizedBox(height:8),Wrap(spacing:6,children:[
          statusChip(t.status=='Done'?'Done':t.accepted&&isGuard?'In progress':t.status),
          if(isManagement)Text('Assigned: ${t.assigned}',style:const TextStyle(fontSize:11,color:muted)),
          if(isManagement&&t.status!='Done'&&t.status!='Completed')FilledButton.icon(onPressed:()=>taskDialog(edit:t),icon:const Icon(Icons.manage_accounts_rounded,size:17),label:const Text('Assign / edit guard',style:TextStyle(fontWeight:FontWeight.w800)),style:FilledButton.styleFrom(backgroundColor:const Color(0xFFEDF1FF),foregroundColor:const Color(0xFF3563D9),elevation:0,padding:const EdgeInsets.symmetric(horizontal:16,vertical:12),shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(14)))),
          if(isGuard&&!t.accepted&&t.status!='Done'&&t.status!='Completed')FilledButton.tonal(style:FilledButton.styleFrom(backgroundColor:t.priority.toLowerCase()=='high'?const Color(0xFFFFE7E7):const Color(0xFFE5F4EC),foregroundColor:t.priority.toLowerCase()=='high'?const Color(0xFFC62838):const Color(0xFF087B5C)),onPressed:()=>setState(()=>t.accepted=true),child:const Text('Accept')), 
          if(isGuard&&t.accepted&&t.status!='Done'&&t.status!='Completed')FilledButton(style:FilledButton.styleFrom(backgroundColor:t.priority.toLowerCase()=='high'?const Color(0xFFD93645):green,foregroundColor:Colors.white),onPressed:(){setState(()=>{t.status='Done',t.accepted=true});if(t.alertId!=null){for(final a in alerts.where((a)=>a.id==t.alertId))a.status='Completed';}toast('Task completed. Management sees Done.');},child:const Text('Complete')),
        ])
      ]))
    ],action:isManagement?null:Text('${visibleTasks.length} assigned'))
  ];
  List<Widget> reportWidgets()=>[
    panel('Township activity report','Aggregated township statistics and task activity',[
      reportLine('Open alerts','Water, electricity and possible forced-entry',alerts.where((a)=>!['Closed','Resolved','Completed'].contains(a.status)).length),
      reportLine('Closed alerts','Incident records',alerts.where((a)=>['Closed','Resolved','Completed'].contains(a.status)).length),
      reportLine('Completed tasks','Guard completion records',tasks.where((t)=>t.status=='Done'||t.status=='Completed').length),
      reportLine('Holiday Mode homes','Illustrative opt-in count',houses.where((h)=>h.away).length),
      const SizedBox(height:10),FilledButton.icon(onPressed:exportPdf,icon:const Icon(Icons.picture_as_pdf),label:const Text('Export report to PDF'))
    ])
  ];
  List<Widget> awayWidgets()=>[...awayPanel(),...checkPanel()];
  List<Widget> sensorWidgets()=>[...sensorPanel(),...housePanel()];
  List<Widget> taskWidgets()=>[...taskPanel()];
  List<Widget> alertWidgets()=>isGuard?<Widget>[]:[...alertPanel()];
  void recordCheckpoint(){final stamp=nowText;setState(()=>tasks.insert(0,TaskItem(nextTask++,'Patrol checkpoint · $stamp','Zone North – Common area','Medium','Pending',guardName,'Guard check-in recorded in the app at $stamp. This is a manual activity record, not GPS proof of physical presence. Supervisor review is required.')));toast('Checkpoint saved. It records a manual patrol check-in for supervisor review.');}
  Future<void> privacyDialog()=>showDialog(context:context,builder:(ctx)=>AlertDialog(title:const Text('Privacy & role access'),content:const Column(mainAxisSize:MainAxisSize.min,crossAxisAlignment:CrossAxisAlignment.start,children:[
    Text('Township management',style:TextStyle(fontWeight:FontWeight.bold)),Text('Review alerts, household-level operational readings, assign named guards and access reports.'),SizedBox(height:10),
    Text('Resident',style:TextStyle(fontWeight:FontWeight.bold)),Text('Access own home, Holiday Mode settings and own notifications.'),SizedBox(height:10),
    Text('Security guard',style:TextStyle(fontWeight:FontWeight.bold)),Text('Assigned tasks and incident instructions only. No utility page, vacant-house list, resident identity or travel dates.'),SizedBox(height:10),
    Text('Production warning: a role selector is not authentication. Real deployments must enforce access control on the server.')
  ]),actions:[TextButton(onPressed:()=>Navigator.pop(ctx),child:const Text('Got it'))]));
  Future<void> helpDialog()=>showDialog(context:context,builder:(ctx)=>AlertDialog(title:const Text('System guide'),content:const SingleChildScrollView(child:Text('1. Sign in and choose one of the three role previews.\n\n2. Use test buttons to generate normal, water, electricity or possible forced-entry scenarios.\n\n3. New incidents appear in Alerts and Notifications.\n\n4. Management can create tasks and assign named guards.\n\n5. Guards can accept and complete assigned tasks, but cannot view utility usage or reports.\n\n6. Residents can configure Holiday Mode and the home-safety checklist.\n\nRule-based anomaly detection is not a trained AI model and does not prove a leak or crime.')),actions:[TextButton(onPressed:()=>Navigator.pop(ctx),child:const Text('Got it'))]));
}
