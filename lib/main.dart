import 'package:chat_gpt_app/model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';

// AIzaSyBsfxb7MBVPAPSLvtLh7n65JN_I6vTUoNA

void main() {
  runApp(ChatGptApp());
}

class ChatGptApp extends StatefulWidget {
  ChatGptApp({super.key});

  @override
  State<ChatGptApp> createState() => _ChatGptAppState();
}

class _ChatGptAppState extends State<ChatGptApp> {
  final TextEditingController _controller = TextEditingController();

  final FocusNode _focusNode = FocusNode();

  bool _canSendMessage = false;

  ChatRoom _room = ChatRoom(
    chats: [],
    createdAt: DateTime.now(),
  );

  @override
  void initState() {
    super.initState();
    Gemini.init(apiKey: "AIzaSyBsfxb7MBVPAPSLvtLh7n65JN_I6vTUoNA");
  }

  // state, 화면전체가 필요해지지 않을때 화면이 완전히 메모리에서 해제가되는 시점을 감지하는 수단
  @override
  void dispose() {
    super.dispose();
    // 화면이 더이상 불필요해지는 시점. 해제가 되는 시점을 감지함
    _controller.dispose();
    _focusNode.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text(
            "GPT",
            style: TextStyle(
              fontSize: 14,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
        ),
        // floatingActionButton: FloatingActionButton(
        //   onPressed: () {
        //     _focusNode.requestFocus();
        //   },
        // ),
        backgroundColor: Colors.white,

        body: Stack(
          children: [
            // 빈 채팅방
            if (_room.chats.isEmpty)
              Align(
                alignment: Alignment.center,
                child: Image.asset(
                  "assets/logo.png",
                  width: 40,
                  height: 40,
                ),
              ),
            // Align(
            //   alignment: Alignment.center,
            //   child: Container(
            //     width: 50,
            //     height: 50,
            //     decoration: BoxDecoration(
            //       image: DecorationImage(
            //         image: AssetImage('assets/logo.png'),
            //       ),
            //     ),
            //   ),
            // ),
            ListView(
              padding: EdgeInsets.only(bottom: 100),
              children: [
                for (var chat in _room.chats)
                  chat.isMe
                      ? _buildMyChatBubble(chat)
                      : _buildGPTChatBubble(chat),
              ],
            ),
            Align(alignment: Alignment.bottomCenter, child: _buildTextField()),
          ],
        ),
      ),
    );
  }

  Widget _buildGPTChatBubble(ChatMessage chat) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.only(
            left: 20,
            top: 5,
          ),
          child: Image.asset(
            "assets/logo.png",
            width: 20,
            height: 20,
          ),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: Container(
            constraints: BoxConstraints(
              maxWidth: 300,
            ),
            margin: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 5,
              bottom: 40,
            ),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(chat.text),
          ),
        ),
      ],
    );
  }

  Align _buildMyChatBubble(ChatMessage chat) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        constraints: BoxConstraints(maxWidth: 250),
        padding: EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        margin: EdgeInsets.only(right: 20, left: 20, bottom: 20),
        decoration: BoxDecoration(
            color: Colors.grey[100], borderRadius: BorderRadius.circular(20)),
        child: Text(chat.text),
      ),
    );
  }

  // Align _buildGPTChatBubble(ChatMessage chat) {
  //   return Align(
  //     alignment: Alignment.centerLeft,
  //     child: Container(
  //       margin: EdgeInsets.only(left: 20, right: 20, bottom: 20),
  //       child: Row(
  //         children: [
  //           Image.asset(
  //             'assets/logo.png',
  //             width: 30,
  //             height: 30,
  //           ),
  //           SizedBox(width: 10),
  //           // 상대방 말풍선
  //           Container(
  //             constraints: BoxConstraints(maxWidth: 300),
  //             padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
  //             decoration: BoxDecoration(
  //               color: Colors.transparent,
  //               borderRadius: BorderRadius.circular(20),
  //             ),
  //             child: Text(chat.text),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  Widget _buildTextField() {
    return Container(
      margin: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: 16,
      ),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(30),
      ),
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        onSubmitted: (_) {
          _sendMessage();
        },
        onChanged: (text) {
          setState(() {
            _canSendMessage = text.isNotEmpty;
          });
        },
        decoration: InputDecoration(
          hintText: "메시지",
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            vertical: 15,
            horizontal: 15,
          ),
          suffixIcon: IconButton(
            icon: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: _canSendMessage ? Colors.black : Colors.black12,
                borderRadius: BorderRadius.circular(100),
              ),
              child: Icon(
                Icons.arrow_upward_rounded,
                color: Colors.white,
              ),
            ),
            onPressed: () {
              _sendMessage();
            },
          ),
        ),
        style: TextStyle(
          fontSize: 14,
        ),
      ),
    );
  }

  void _sendMessage() {
    // 엔터를 눌렀을 때 _controller를 통해서 텍스트 필드에 입력한 값을 찍어봅시다.
    // _controller.text = ""; == clear()

    // 텍스트 필드 포커스를 잃었다.
    _focusNode.unfocus();

    final ChatMessage chat = ChatMessage(
        isMe: true, // test코드 : Random().nextBool(),
        text: _controller.text,
        sentAt: DateTime.now());

    // 텍스트 필드에 있는 값을 조작을 해야한다.(원래있는 값을 비워줘야함)
    _controller.clear();

    setState(() {
      _room.chats.add(chat);
      _canSendMessage = false;
    });

    // 사용자가 채팅에 입력한 문자를 Gemini에게 전달
    String quenstion = _controller.text;
    quenstion += "진짜 기깔난 플러터 삼행시 지어줘";
    Gemini.instance.streamGenerateContent(quenstion).listen((event) {
      print(event.output);
      setState(() {
        _room.chats.last.text += (event.output ?? "");
      });
    });

    // 챗지피티 말풍선을 노출 (말풍선의 내용은 비어있다)
    _room.chats.add(
      ChatMessage(isMe: false, text: "", sentAt: DateTime.now()),
    );

    // Gemini로부터 응답값을 받아볼 수 있도록 한다
    // 응답값을 챗 지피티 말풍선에 추가해준다.

    // 텍스트 필드에 있는 값을 조작을 해야한다. (비워주기)
    _controller.clear();
  }
}
