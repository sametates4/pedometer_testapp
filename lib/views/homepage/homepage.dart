import 'package:flutter/material.dart';
import 'package:pedometer/pedometer.dart';
import 'package:pedometer_testapp/service/provider/stepmodel.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Stream<StepCount> _stepCountStream;
  late String day = "${DateTime.now().day}";
  late String step = "0";

  @override
  void initState() {
    super.initState();
    initPlatformState();
    stepReset();
  }

  void stepReset()async{
    final prefs = await SharedPreferences.getInstance();
    if(prefs.getInt("day") == null){
      prefs.setInt("day", int.parse(day));
      prefs.setInt("step", int.parse(step));
      late int steps = prefs.getInt("step")! - int.parse(step);
      context.read<StepModel>().valChange(steps);
    }
    if(prefs.getInt("day")! < int.parse(day)){
      prefs.setInt("day", int.parse(day));
      prefs.setInt("step", int.parse(step));
      late int steps = int.parse(step) - prefs.getInt("step")!;
      context.read<StepModel>().valChange(steps);
    }
    if(prefs.getInt("day")! == int.parse(day)){
      late int steps = int.parse(step) - prefs.getInt("step")!;
      context.read<StepModel>().valChange(steps);
    }
  }



  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Pedometer example app'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                'Steps taken:',
                style: TextStyle(fontSize: 30),
              ),
              Text(context.watch<StepModel>().valRead().toString(),style: const TextStyle(fontSize: 60),),
            ],
          ),
        ),
      ),
    );
  }

  void onStepCount(StepCount event) {
    print(event);
    setState((){
      step = event.steps.toString();
    });
  }

  void onStepCountError(error) {
    print('onStepCountError: $error');
  }

  void initPlatformState() {
    _stepCountStream = Pedometer.stepCountStream;
    _stepCountStream.listen(onStepCount).onError(onStepCountError);

    if (!mounted) return;
  }
}
