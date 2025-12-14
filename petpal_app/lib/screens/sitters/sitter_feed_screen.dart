import 'package:flutter/material.dart';

class SitterFeedScreen extends StatelessWidget {
  const SitterFeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Community Feed')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 10,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=$index'),
                  ),
                  title: Text('Sitter ${index + 1}'),
                  subtitle: Text('2 hours ago'),
                  trailing: const Icon(Icons.more_vert),
                ),
                Container(
                  height: 200,
                  width: double.infinity,
                  color: Colors.grey[300],
                  child: Image.network(
                    'https://picsum.photos/seed/$index/500/300',
                    fit: BoxFit.cover,
                    errorBuilder: (c, e, s) => const Center(child: Icon(Icons.image)),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    'Had a great time sitting for this lovely energetic husky today! #petpal #sitterlife',
                    style: TextStyle(color: Colors.grey[800]),
                  ),
                ),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    TextButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.favorite_border),
                      label: const Text('Like'),
                    ),
                    TextButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.comment_outlined),
                      label: const Text('Comment'),
                    ),
                    TextButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.share_outlined),
                      label: const Text('Share'),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
