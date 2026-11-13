import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myalien/discover/cubit/discover_cubit.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DiscoverCubit, DiscoverState>(
      listener: (context, state) {
        if (state is DiscoverInitial) {
          // Show a loading indicator
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Loading Discover Screen...')),
          );
        } else {
          // Hide the loading indicator
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
        }
      },
      builder: (context, state) {
        return const Center(child: Text('Discover View'));
      },
    );
  }
}
