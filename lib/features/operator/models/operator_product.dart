import 'package:equatable/equatable.dart';

class OperatorProduct extends Equatable {
  final String id;
  final String name;
  final double price;
  final String imageUrl;
  final String category;

  const OperatorProduct({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.category,
  });

  Map<String, dynamic> toSocketPayload() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'imageUrl': imageUrl,
      'category': category,
    };
  }

  static List<OperatorProduct> mockCatalog() {
    return const [
      OperatorProduct(
        id: 'op-001',
        name: 'Nebula Bottle',
        price: 18,
        imageUrl: 'https://picsum.photos/seed/nebulabottle/400/400',
        category: 'Lifestyle',
      ),
      OperatorProduct(
        id: 'op-002',
        name: 'Pulse Speaker',
        price: 79,
        imageUrl: 'https://picsum.photos/seed/pulsespeaker/400/400',
        category: 'Audio',
      ),
      OperatorProduct(
        id: 'op-003',
        name: 'Aura Lamp',
        price: 34.5,
        imageUrl: 'https://picsum.photos/seed/auralamp/400/400',
        category: 'Home',
      ),
      OperatorProduct(
        id: 'op-004',
        name: 'Dash Earbuds',
        price: 52,
        imageUrl: 'https://picsum.photos/seed/dashearbuds/400/400',
        category: 'Audio',
      ),
      OperatorProduct(
        id: 'op-005',
        name: 'Nova Watch',
        price: 129,
        imageUrl: 'https://picsum.photos/seed/novawatch/400/400',
        category: 'Wearables',
      ),
      OperatorProduct(
        id: 'op-006',
        name: 'Studio Mic',
        price: 61,
        imageUrl: 'https://picsum.photos/seed/studiomic/400/400',
        category: 'Creator',
      ),
      OperatorProduct(
        id: 'op-007',
        name: 'Grip Tripod',
        price: 22,
        imageUrl: 'https://picsum.photos/seed/griptripod/400/400',
        category: 'Creator',
      ),
      OperatorProduct(
        id: 'op-008',
        name: 'Zen Keyboard',
        price: 88,
        imageUrl: 'https://picsum.photos/seed/zenkeyboard/400/400',
        category: 'Desk',
      ),
      OperatorProduct(
        id: 'op-009',
        name: 'Motion Bottle',
        price: 15,
        imageUrl: 'https://picsum.photos/seed/motionbottle/400/400',
        category: 'Lifestyle',
      ),
      OperatorProduct(
        id: 'op-010',
        name: 'Echo Ring Light',
        price: 46,
        imageUrl: 'https://picsum.photos/seed/echoringlight/400/400',
        category: 'Lighting',
      ),
    ];
  }

  @override
  List<Object?> get props => [id, name, price, imageUrl, category];
}
