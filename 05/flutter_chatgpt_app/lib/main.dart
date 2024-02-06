import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_chatgpt_app/model/open_ai_model.dart';
import 'package:http/http.dart' as http;
import 'package:rxdart/rxdart.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  TextEditingController messageTextController = TextEditingController();
  final List<Messages> _historyList = List.empty(growable: true);
  // String apiKey = "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";
  String apiKey = "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";
  String streamText = "";
  static const String _kStrings = "Flutter ChatGPT";
  String get _currentString => _kStrings;
  ScrollController scrollController = ScrollController();
  late Animation<int> _characterCount;
  late AnimationController animationController;

  void _scrollDown() {
    scrollController.animateTo(
      scrollController.position.maxScrollExtent,
      duration: Duration(milliseconds: 350),
      curve: Curves.fastOutSlowIn,
    );
  }

  setupAnimations() {
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );
    _characterCount = StepTween(begin: 0, end: _currentString.length).animate(
      CurvedAnimation(
        parent: animationController,
        curve: Curves.easeIn,
      ),
    );
    animationController.addListener(() {
      setState(() {});
    });
    animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(const Duration(seconds: 1)).then((value) {
          animationController.reverse();
        });
      } else if (status == AnimationStatus.dismissed) {
        Future.delayed(const Duration(seconds: 1)).then((value) {
          animationController.forward();
        });
      }
    });
    animationController.forward();
  }

  Future requestChat(String text) async {
    ChatCompletionModel openAiModel = ChatCompletionModel(
      model: "gpt-3.5-turbo",
      messages: [
        Messages(
          role: "system",
          content: "You are a helpful assistant",
        ),
        ..._historyList,
      ],
      stream: false,
    );
    final url = Uri.https("api.openai.com", "/v1/chat/completions");
    final resp = await http.post(
      url,
      headers: {
        "Authorization": "Bearer $apiKey",
        "Content-Type": "application/json",
      },
      body: jsonEncode(openAiModel.toJson()),
    );
    print(resp.body);
    if (resp.statusCode == 200) {
      final jsonData = jsonDecode(utf8.decode(resp.bodyBytes)) as Map;
      String role = jsonData["choices"][0]["message"]["role"];
      String content = jsonData["choices"][0]["message"]["content"];
      _historyList.last =
          _historyList.last.copyWith(role: role, content: content);
    }
    setState(() {
      _scrollDown();
    });
  }

  Stream requestChatStream(String text) async* {
    ChatCompletionModel openAiModel = ChatCompletionModel(
        model: "gpt-3.5-turbo",
        messages: [
          Messages(
            role: "system",
            content: "You are a helpful assistant.",
          ),
        ],
        stream: true);
    final url = Uri.https("api.openai.com", "/v1/chat/completions");
    final request = http.Request("POST", url)
      ..headers.addAll(
        {
          "Authorization": "Bearer ${apiKey}",
          "Content-Type": "application/json; charset=UTF-8",
          "Accept": "*/*",
          "Accept-Encoding": "gzip, deflate, br",
        },
      );
    request.body = jsonEncode(openAiModel.toJson());
    final resp = await http.Client().send(request);
    final byteStream = resp.stream.asyncExpand(
      (event) => Rx.timer(
        event,
        const Duration(milliseconds: 50),
      ),
    );
    final statusCode = resp.statusCode;
    var respText = "";

    await for (final byte in byteStream) {
      var decode = utf8.decode(byte, allowMalformed: false);
      final strings = decode.split("data: ");
      for (final string in strings) {
        final trimmedString = string.trim();
        if (trimmedString.isNotEmpty && !trimmedString.endsWith("[DONE]")) {
          final map = jsonDecode(trimmedString) as Map;
          final choices = map["choices"] as List;
          final delta = choices[0]["delta"] as Map;
          if (delta["content"] != null) {
            final content = delta["content"] as String;
            respText += content;
            setState(() {
              streamText = respText;
            });
            yield content;
          }
        }
      }
    }

    if (respText.isNotEmpty) {
      setState(() {});
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setupAnimations();
  }

  @override
  void dispose() {
    messageTextController.dispose();
    scrollController.dispose();

    super.dispose();
  }

  Future clearChat() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("새로운 대화의 시작"),
        content: Text("신규 대화를 생성하시겠어요?"),
        actions: [
          TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  messageTextController.clear();
                  _historyList.clear();
                });
              },
              child: Text("네"))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Align(
                alignment: Alignment.centerRight,
                child: Card(
                  child: PopupMenuButton(
                    itemBuilder: (context) {
                      return [
                        PopupMenuItem(
                          child: ListTile(
                            title: const Text("히스토리"),
                          ),
                        ),
                        PopupMenuItem(
                          child: ListTile(
                            title: const Text("설정"),
                          ),
                        ),
                        PopupMenuItem(
                          onTap: () {
                            clearChat();
                          },
                          child: ListTile(
                            title: const Text("새로운 채팅"),
                          ),
                        ),
                      ];
                    },
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: _historyList.isEmpty
                      ? Center(
                          child: AnimatedBuilder(
                            animation: _characterCount,
                            builder: (BuildContext context, Widget? child) {
                              String text = _currentString.substring(
                                  0, _characterCount.value);
                              return Row(
                                children: [
                                  Text(
                                    "${text}",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 24,
                                    ),
                                  ),
                                  CircleAvatar(
                                    radius: 8,
                                    backgroundColor: Colors.orange[200],
                                  )
                                ],
                              );
                            },
                          ),
                        )
                      : GestureDetector(
                          onTap: () => FocusScope.of(context).unfocus(),
                          child: ListView.builder(
                            controller: scrollController,
                            itemCount: _historyList.length,
                            itemBuilder: (context, index) {
                              if (_historyList[index].role == "user") {
                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  child: Row(
                                    children: [
                                      const CircleAvatar(),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text("User"),
                                            Text(_historyList[index].content),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                );
                              }
                              return Row(
                                children: [
                                  const CircleAvatar(
                                    backgroundColor: Colors.teal,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                      child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text("ChatGPT"),
                                      Text(_historyList[index].content),
                                    ],
                                  ))
                                ],
                              );
                            },
                          ),
                        ),
                ),
              ),
              Dismissible(
                key: Key("chat-bar"),
                direction: DismissDirection.startToEnd,
                onDismissed: (d) {
                  if (d == DismissDirection.startToEnd) {
                    // row
                  }
                },
                background: const Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text("New Chat"),
                  ],
                ),
                confirmDismiss: (d) async {
                  if (d == DismissDirection.startToEnd) {
                    // logic
                    if (_historyList.isEmpty) return;
                    clearChat();
                  }
                },
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(32),
                          border: Border.all(),
                        ),
                        child: TextField(
                          controller: messageTextController,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: "Message",
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                        onPressed: () async {
                          if (messageTextController.text.isEmpty) {
                            return;
                          }
                          setState(() {
                            _historyList.add(
                              Messages(
                                  role: "user",
                                  content: messageTextController.text.trim()),
                            );
                            _historyList
                                .add(Messages(role: "assistant", content: ""));
                          });
                          try {
                            var text = "";
                            final stream = requestChatStream(
                                messageTextController.text.trim());
                            await for (final textChunk in stream) {
                              text += textChunk;
                              setState(() {
                                _historyList.last =
                                    _historyList.last.copyWith(content: text);
                                _scrollDown();
                              });
                            }
                            // await requestChat(messageTextController.text.trim());
                            messageTextController.clear();
                            streamText = "";
                          } catch (e) {
                            print(e.toString());
                          }
                        },
                        iconSize: 42,
                        icon: Icon(Icons.arrow_circle_up))
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
