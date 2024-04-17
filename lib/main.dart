import 'dart:io';
import 'dart:typed_data';

import 'package:feedback/feedback.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'custom_feedback.dart';
import 'feedback_functions.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

bool _useCustomFeedback = false;

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return BetterFeedback(
      feedbackBuilder: _useCustomFeedback
          ? (context, onSubmit, scrollController) => CustomFeedbackForm(
                onSubmit: onSubmit,
                scrollController: scrollController,
              )
          : null,
      theme: FeedbackThemeData(
        background: Colors.grey,
        feedbackSheetColor: Colors.grey[50]!,
        drawColors: [
          Colors.red,
          Colors.green,
          Colors.blue,
          Colors.yellow,
        ],
      ),
      darkTheme: FeedbackThemeData.dark(),
      localizationsDelegates: [
        GlobalFeedbackLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      localeOverride: const Locale('en'),
      mode: FeedbackMode.draw,
      pixelRatio: 1,
      child: MaterialApp(
        title: 'Feedback Demo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: _useCustomFeedback ? Colors.green : Colors.blue,
        ),
        home: MyHomePage(_toggleCustomizedFeedback),
      ),
    );
  }

  void _toggleCustomizedFeedback() =>
      setState(() => _useCustomFeedback = !_useCustomFeedback);
}

class MyHomePage extends StatelessWidget {
  const MyHomePage(this.toggleCustomizedFeedback, {super.key});

  final VoidCallback toggleCustomizedFeedback;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurpleAccent,
        centerTitle: true,
        title: Text(_useCustomFeedback
            ? '(Custom) Feedback Example'
            : 'Feedback Example', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const SizedBox(height: 50),
              ClipRRect(borderRadius: BorderRadius.circular(30), child: const Image(height: 300, image: AssetImage("assets/images/cars.png"), fit: BoxFit.fill,)),
              const SizedBox(height: 50),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    child: const Text('Simple Feedback', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),),
                    onPressed: () {
                      BetterFeedback.of(context).show(
                        (feedback) async {
                          alertFeedbackFunction(
                            context,
                            feedback,
                          );
                        },
                      );
                    },
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    child: const Text('Share Feedback', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),),
                    onPressed: () {
                      BetterFeedback.of(context).show(
                            (feedback) async {
                          final screenshotFilePath =
                          await writeImageToStorage(feedback.screenshot);
                          // ignore: deprecated_member_use
                          await Share.shareFiles(
                            [screenshotFilePath],
                            text: feedback.text,
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20,),

            ],
          ),
        ),
      ),
      floatingActionButton: MaterialButton(
        color: Theme.of(context).primaryColor,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20))),
        child: const Text('toggle feedback mode',
            style: TextStyle(color: Colors.white)),
        onPressed: () {
          // don't toggle the feedback mode if it's currently visible
          if (!BetterFeedback.of(context).isVisible) {
            toggleCustomizedFeedback();
          }
        },
      ),
    );
  }

}



Future<String> writeImageToStorage(Uint8List feedbackScreenshot) async {
  final Directory output = await getTemporaryDirectory();
  final String screenshotFilePath = '${output.path}/feedback.png';
  final File screenshotFile = File(screenshotFilePath);
  await screenshotFile.writeAsBytes(feedbackScreenshot);
  return screenshotFilePath;
}
