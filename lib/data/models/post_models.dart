class Post {
  final String id;
  final String userId;
  final String username;
  final String? avatarUrl;
  final String imageUrl;
  final String? caption;
  final String? theme;
  final int yeahCount;
  final int commentCount;
  final DateTime createdAt;
  final int streakDay;
  final bool isYeahed;

  const Post({
    required this.id,
    required this.userId,
    required this.username,
    this.avatarUrl,
    required this.imageUrl,
    this.caption,
    this.theme,
    required this.yeahCount,
    required this.commentCount,
    required this.createdAt,
    required this.streakDay,
    this.isYeahed = false,
  });

  Post copyWith({
    String? id,
    String? userId,
    String? username,
    String? avatarUrl,
    String? imageUrl,
    String? caption,
    String? theme,
    int? yeahCount,
    int? commentCount,
    DateTime? createdAt,
    int? streakDay,
    bool? isYeahed,
  }) {
    return Post(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      imageUrl: imageUrl ?? this.imageUrl,
      caption: caption ?? this.caption,
      theme: theme ?? this.theme,
      yeahCount: yeahCount ?? this.yeahCount,
      commentCount: commentCount ?? this.commentCount,
      createdAt: createdAt ?? this.createdAt,
      streakDay: streakDay ?? this.streakDay,
      isYeahed: isYeahed ?? this.isYeahed,
    );
  }

  // Static mock data generator
  static List<Post> getMockPosts() {
    final now = DateTime.now();
    return [
      Post(
        id: '1',
        userId: 'user1',
        username: 'volltox',
        avatarUrl: null,
        imageUrl: 'https://picsum.photos/seed/art1/400/400',
        caption: null,
        theme: 'Spooky Creatures',
        yeahCount: 42,
        commentCount: 5,
        createdAt: now.subtract(const Duration(hours: 2)),
        streakDay: 15,
        isYeahed: false,
      ),
      Post(
        id: '2',
        userId: 'user2',
        username: 'artisan_maya',
        avatarUrl: null,
        imageUrl: 'https://picsum.photos/seed/art2/400/600',
        caption: 'Daily sketch practice! Trying to improve my character design 🎨',
        theme: 'Character Design',
        yeahCount: 128,
        commentCount: 12,
        createdAt: now.subtract(const Duration(hours: 5)),
        streakDay: 7,
        isYeahed: true,
      ),
      Post(
        id: '3',
        userId: 'user3',
        username: 'sketch_master',
        avatarUrl: null,
        imageUrl: 'https://picsum.photos/seed/art3/600/400',
        caption: 'Landscape study from today',
        theme: 'Nature',
        yeahCount: 89,
        commentCount: 8,
        createdAt: now.subtract(const Duration(hours: 8)),
        streakDay: 23,
        isYeahed: false,
      ),
      Post(
        id: '4',
        userId: 'user4',
        username: 'ink_dreamer',
        avatarUrl: null,
        imageUrl: 'https://picsum.photos/seed/art4/400/400',
        caption: null,
        theme: 'Abstract Art',
        yeahCount: 201,
        commentCount: 18,
        createdAt: now.subtract(const Duration(days: 1)),
        streakDay: 45,
        isYeahed: true,
      ),
      Post(
        id: '5',
        userId: 'user5',
        username: 'creative_soul',
        avatarUrl: null,
        imageUrl: 'https://picsum.photos/seed/art5/500/700',
        caption: 'Experimenting with new techniques. What do you think?',
        theme: 'Experimental',
        yeahCount: 67,
        commentCount: 9,
        createdAt: now.subtract(const Duration(days: 1, hours: 3)),
        streakDay: 3,
        isYeahed: false,
      ),
      Post(
        id: '6',
        userId: 'user6',
        username: 'pixel_poet',
        avatarUrl: null,
        imageUrl: 'https://picsum.photos/seed/art6/400/400',
        caption: 'Day 10 of my drawing challenge! 🔥',
        theme: 'Daily Challenge',
        yeahCount: 156,
        commentCount: 15,
        createdAt: now.subtract(const Duration(days: 2)),
        streakDay: 10,
        isYeahed: false,
      ),
    ];
  }
}
