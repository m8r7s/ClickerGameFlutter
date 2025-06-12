import 'dart:async';
import 'package:flutter/material.dart';

void main() {
  runApp(const ClickerGameApp());
}

// Modèle pour les auto-clickers
class AutoClicker {
  final String name;
  final int cost;
  final double clicksPerSecond;
  final int requiredScore;
  bool isPurchased;

  AutoClicker({
    required this.name,
    required this.cost,
    required this.clicksPerSecond,
    required this.requiredScore,
    this.isPurchased = false,
  });
}

// Provider pour gérer l'état du jeu
class GameState extends ChangeNotifier {
  int _score = 0;
  int _clickValue = 1;
  String _playerName = 'Joueur';
  Timer? _gameTimer;

  final List<AutoClicker> _autoClickers = [
    AutoClicker(
      name: 'Auto-Clicker Basique',
      cost: 10,
      clicksPerSecond: 0.1,
      requiredScore: 10,
    ),
    AutoClicker(
      name: 'Auto-Clicker Rapide',
      cost: 50,
      clicksPerSecond: 0.5,
      requiredScore: 50,
    ),
    AutoClicker(
      name: 'Super Auto-Clicker',
      cost: 200,
      clicksPerSecond: 2.0,
      requiredScore: 200,
    ),
  ];

  // Getters
  int get score => _score;
  int get clickValue => _clickValue;
  String get playerName => _playerName;
  List<AutoClicker> get autoClickers => _autoClickers;
  List<AutoClicker> get availableAutoClickers =>
      _autoClickers.where((c) => _score >= c.requiredScore).toList();

  GameState() {
    _startAutoClickers();
  }

  void _startAutoClickers() {
    _gameTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      double autoPoints = 0;
      for (AutoClicker clicker in _autoClickers) {
        if (clicker.isPurchased) {
          autoPoints += clicker.clicksPerSecond * 0.1;
        }
      }
      if (autoPoints > 0) {
        _score += autoPoints.round();
        notifyListeners();
      }
    });
  }

  void performClick() {
    _score += _clickValue;
    notifyListeners();
  }

  void purchaseAutoClicker(AutoClicker clicker) {
    if (_score >= clicker.cost && !clicker.isPurchased) {
      _score -= clicker.cost;
      clicker.isPurchased = true;
      notifyListeners();
    }
  }

  void upgradeClickValue() {
    int cost = _clickValue * 20;
    if (_score >= cost) {
      _score -= cost;
      _clickValue++;
      notifyListeners();
    }
  }

  int getUpgradeCost() => _clickValue * 20;

  void updatePlayerName(String name) {
    _playerName = name.isNotEmpty ? name : 'Joueur';
    notifyListeners();
  }

  void resetGame() {
    _score = 0;
    _clickValue = 1;
    _playerName = 'Joueur';
    for (AutoClicker clicker in _autoClickers) {
      clicker.isPurchased = false;
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    super.dispose();
  }
}

// Application principale
class ClickerGameApp extends StatelessWidget {
  const ClickerGameApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => GameState(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Clicker Game',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const GameScreen(),
          '/settings': (context) => const SettingsScreen(),
        },
      ),
    );
  }
}

// Écran principal du jeu
class GameScreen extends StatelessWidget {
  const GameScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clicker Game'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
        ],
      ),
      body: Consumer<GameState>(
        builder: (context, gameState, child) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Salutation
                Center(
                  child: Text(
                    'Salut ${gameState.playerName}!',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                const SizedBox(height: 20),

                // Affichage du score
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade100,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.amber.shade300),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star, color: Colors.amber.shade700, size: 30),
                      const SizedBox(width: 10),
                      Text(
                        'Score: ${gameState.score}',
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.amber.shade800,
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // Bouton de clic principal
                Center(
                  child: GestureDetector(
                    onTap: gameState.performClick,
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            Colors.blue.shade300,
                            Colors.blue.shade600,
                            Colors.blue.shade800,
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.4),
                            blurRadius: 15,
                            spreadRadius: 3,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.touch_app,
                                size: 40, color: Colors.white),
                            const SizedBox(height: 5),
                            Text(
                              'CLIC!',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Amélioration du clic
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Valeur par clic: ${gameState.clickValue}'),
                    const SizedBox(width: 15),
                    ElevatedButton(
                      onPressed: gameState.score >= gameState.getUpgradeCost()
                          ? gameState.upgradeClickValue
                          : null,
                      child: Text('Améliorer (${gameState.getUpgradeCost()})'),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Auto-clickers
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Auto-Clickers:',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: gameState.availableAutoClickers.isEmpty
                            ? const Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.lock,
                                        size: 60, color: Colors.grey),
                                    SizedBox(height: 10),
                                    Text(
                                      'Continuez à cliquer pour débloquer des auto-clickers!',
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                itemCount:
                                    gameState.availableAutoClickers.length,
                                itemBuilder: (context, index) {
                                  final clicker =
                                      gameState.availableAutoClickers[index];
                                  final canAfford =
                                      gameState.score >= clicker.cost;

                                  return Card(
                                    color: clicker.isPurchased
                                        ? Colors.green.shade50
                                        : (canAfford
                                            ? Colors.white
                                            : Colors.grey.shade100),
                                    child: ListTile(
                                      leading: Icon(
                                        clicker.isPurchased
                                            ? Icons.check_circle
                                            : Icons.precision_manufacturing,
                                        color: clicker.isPurchased
                                            ? Colors.green
                                            : (canAfford
                                                ? Colors.blue
                                                : Colors.grey),
                                      ),
                                      title: Text(clicker.name),
                                      subtitle: Text(
                                        '${clicker.clicksPerSecond >= 1 ? '${clicker.clicksPerSecond.toInt()} clics/sec' : '1 clic/${(1 / clicker.clicksPerSecond).toInt()}s'}',
                                      ),
                                      trailing: clicker.isPurchased
                                          ? const Text('Acheté',
                                              style: TextStyle(
                                                  color: Colors.green))
                                          : ElevatedButton(
                                              onPressed: canAfford
                                                  ? () => gameState
                                                      .purchaseAutoClicker(
                                                          clicker)
                                                  : null,
                                              child: Text('${clicker.cost}'),
                                            ),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// Écran des paramètres
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final gameState = Provider.of<GameState>(context);
    _nameController.text = gameState.playerName;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Consumer<GameState>(
        builder: (context, gameState, child) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Configuration du nom
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Profil du joueur',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Nom du joueur',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                gameState
                                    .updatePlayerName(_nameController.text);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Nom mis à jour!')),
                                );
                              },
                              child: const Text('Sauvegarder'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Statistiques
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Statistiques',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Score actuel:'),
                            Text('${gameState.score}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Valeur par clic:'),
                            Text('${gameState.clickValue}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Auto-clickers achetés:'),
                            Text(
                                '${gameState.autoClickers.where((c) => c.isPurchased).length}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Auto-clickers possédés
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Auto-clickers possédés',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 16),
                          Expanded(
                            child: gameState.autoClickers
                                    .where((c) => c.isPurchased)
                                    .isEmpty
                                ? const Center(
                                    child: Text(
                                        'Aucun auto-clicker acheté pour le moment'),
                                  )
                                : ListView(
                                    children: gameState.autoClickers
                                        .where((c) => c.isPurchased)
                                        .map((clicker) => ListTile(
                                              leading: const Icon(
                                                  Icons.check_circle,
                                                  color: Colors.green),
                                              title: Text(clicker.name),
                                              subtitle: Text(
                                                '${clicker.clicksPerSecond >= 1 ? '${clicker.clicksPerSecond.toInt()} clics/sec' : '1 clic/${(1 / clicker.clicksPerSecond).toInt()}s'}',
                                              ),
                                            ))
                                        .toList(),
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Bouton de réinitialisation
                ElevatedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Réinitialiser le jeu'),
                        content: const Text(
                            'Voulez-vous vraiment recommencer à zéro ?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Annuler'),
                          ),
                          TextButton(
                            onPressed: () {
                              gameState.resetGame();
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Jeu réinitialisé!')),
                              );
                            },
                            child: const Text('Confirmer'),
                          ),
                        ],
                      ),
                    );
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Réinitialiser le jeu'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// Classes utilitaires pour Provider
class ChangeNotifier with ChangeNotifierMixin {}

mixin ChangeNotifierMixin {
  final List<VoidCallback> _listeners = [];

  void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }

  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  void notifyListeners() {
    for (final listener in _listeners) {
      listener();
    }
  }

  void dispose() {
    _listeners.clear();
  }
}

class ChangeNotifierProvider<T extends ChangeNotifier> extends StatefulWidget {
  final T Function(BuildContext context) create;
  final Widget child;

  const ChangeNotifierProvider({
    Key? key,
    required this.create,
    required this.child,
  }) : super(key: key);

  @override
  State<ChangeNotifierProvider<T>> createState() =>
      _ChangeNotifierProviderState<T>();
}

class _ChangeNotifierProviderState<T extends ChangeNotifier>
    extends State<ChangeNotifierProvider<T>> {
  late T _notifier;

  @override
  void initState() {
    super.initState();
    _notifier = widget.create(context);
  }

  @override
  void dispose() {
    _notifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _InheritedProvider<T>(
      notifier: _notifier,
      child: widget.child,
    );
  }
}

class _InheritedProvider<T> extends InheritedWidget {
  final T notifier;

  const _InheritedProvider({
    required this.notifier,
    required Widget child,
  }) : super(child: child);

  @override
  bool updateShouldNotify(_InheritedProvider<T> oldWidget) {
    return notifier != oldWidget.notifier;
  }
}

class Consumer<T extends ChangeNotifier> extends StatefulWidget {
  final Widget Function(BuildContext context, T value, Widget? child) builder;
  final Widget? child;

  const Consumer({
    Key? key,
    required this.builder,
    this.child,
  }) : super(key: key);

  @override
  State<Consumer<T>> createState() => _ConsumerState<T>();
}

class _ConsumerState<T extends ChangeNotifier> extends State<Consumer<T>> {
  T? _notifier;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final newNotifier = Provider.of<T>(context);
    if (_notifier != newNotifier) {
      _notifier?.removeListener(_listener);
      _notifier = newNotifier;
      _notifier?.addListener(_listener);
    }
  }

  void _listener() {
    setState(() {});
  }

  @override
  void dispose() {
    _notifier?.removeListener(_listener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notifier = _notifier;
    if (notifier == null) {
      return const SizedBox.shrink(); // or a loading widget
    }
    return widget.builder(context, notifier, widget.child);
  }
}

class Provider {
  static T of<T>(BuildContext context) {
    final provider =
        context.dependOnInheritedWidgetOfExactType<_InheritedProvider<T>>();
    if (provider == null) {
      throw Exception('Provider<$T> not found');
    }
    return provider.notifier;
  }
}
