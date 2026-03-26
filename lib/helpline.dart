import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:url_launcher/url_launcher.dart';

class Helpline extends StatefulWidget {
  const Helpline({super.key});

  @override
  State<Helpline> createState() => _HelplineState();
}

class _HelplineState extends State<Helpline> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Ensures the base layer of the screen is white
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color.fromARGB(255, 58, 0, 0)),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text(
          'Helpline',
          style: TextStyle(
              color: Color.fromARGB(255, 58, 0, 0),
              fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.purple.shade100,
      ),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          color: Colors.white, // This removes the black default by painting white behind the image
          image: DecorationImage(
            image: AssetImage("assets/human1.jpg"),
            //fit: BoxFit.fill,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const ListTile(
                  leading: Text(
                    'Contact',
                    style: TextStyle(
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.bold,color:Color.fromARGB(255, 58, 0, 0)),
                  ),
                  title: Text(
                    'Organisation Name',
                    style: TextStyle(
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.bold,color:Color.fromARGB(255, 58, 0, 0) ),
                  ),
                  trailing: Text(
                    'Website',
                    style: TextStyle(
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                HelplineTile('021-111-111-943', 'Zindagi Trust Helpline',
                    'https://zindagitrust.org/'),
                HelplineTile('0311-7786264', 'Taskeen Mental Health',
                    'https://taskeen.org/'),
                HelplineTile('115', 'Edhi Helpline', 'https://edhi.org/'),
                HelplineTile('021-111-345-822', 'Sehat Kahani Mental Health',
                    'https://sehatkahani.com/'),
                HelplineTile('0300-8562301', 'Willing Ways', '0300-8562301'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class HelplineTile extends StatelessWidget {
  const HelplineTile(this.contact, this.foundation, this.websiteUrl,
      {super.key});
  final String contact;
  final String foundation;
  final String websiteUrl;

  _callNumber(String phoneNumber) async {
    String number = phoneNumber;
    await FlutterPhoneDirectCaller.callNumber(number);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: IconButton(
            icon: const Icon(Icons.phone, color: Colors.green),
            onPressed: () {
              _callNumber(contact);
            },
          ),
          title: Text(
            foundation,
            style: const TextStyle(color: Colors.indigo),
          ),
          trailing: IconButton(
            icon: const Icon(Icons.open_in_new_rounded, color: Colors.blue),
            onPressed: () {
              launch(websiteUrl);
            },
          ),
          tileColor: Colors.grey[200],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        const SizedBox(height: 15)
      ],
    );
  }
}