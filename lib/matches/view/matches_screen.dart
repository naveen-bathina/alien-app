import 'package:flutter/material.dart';
import 'package:myalien/app/view/brand_logo.dart';
import 'package:myalien/matches/view/matches_view.dart';

class MatchesScreen extends StatelessWidget {
  const MatchesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const BrandAppBarTitle('Matches'),
        centerTitle: true,
      ),
      body: const MatchesView(),
    );
  }
}
