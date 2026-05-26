// import 'package:flutter/material.dart';
// import 'package:flutter/widgets.dart';
// import 'package:images/src/modules/dictionary/presentation/bloc/dictionary_bloc.dart';

// class DictonaryCard extends StatelessWidget {
//   // final String word;
//   // final String definition;

//   // DictonaryCard({required this.word, required this.definition});

//   @override
//   Widget build(BuildContext context, String example, DictionaryBloc audio) {
//   return Card(
//     margin: const EdgeInsets.only(top: 8),
//     child: Padding(
//       padding: const EdgeInsets.all(12),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Expanded(
//             child: Text(
//               '“$example”',
//               style: const TextStyle(fontStyle: FontStyle.italic),
//             ),
//           ),
//           IconButton(
//             tooltip: 'Listen to example',
//             onPressed: () => audio.speak(example),
//             icon: const Icon(Icons.record_voice_over_outlined),
//           ),
//         ],
//       ),
//     ),
//   );
// }
// }
