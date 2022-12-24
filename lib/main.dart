import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Column(
          children: [
            Builder(builder: (context) {
              return Center(
                child: TextButton(
                  child: const Text('Copy Text'),
                  onPressed: () async {
                    bool runInShell = Platform.isWindows;

                    final clipboardData =
                        await Clipboard.getData(Clipboard.kTextPlain);
                    final text = clipboardData?.text;

                    final indentedText2 =
                        text?.split('\n').asMap().entries.map((entry) {
                      final index = entry.key;
                      final line = entry.value;
                      if (index % 2 == 0) {
                        return '   \n\n$line';
                      }
                      return line;
                    }).join('');

                    final useful = ClipboardData(text: indentedText2);

                    // Copy the indented text to the clipboard
                    await Clipboard.setData(useful).then((value) =>
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Content set'))));

                    // await Shell().run('start calc.exe');
                    // await Shell().run('calculator');

                    // await run('open -a iTunes',
                    //     workingDirectory: '~/', runInShell: runInShell);
                    // await run('open -a TextEdit', runInShell: runInShell);
                    // await run('studio ', runInShell: runInShell);
                  },
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
