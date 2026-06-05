# 🧬 Chain Reaction Game: Adversarial Search

Chain Reaction Game is a strategic board game implementation featuring an advanced AI system powered by the Minimax algorithm with Alpha-Beta pruning. Built with Flutter, this remake focuses on performance optimization, dynamic gameplay animations, and intelligent decision-making through iterative deepening search and multiple customizable heuristic strategies.

The AI employs alpha-beta pruning to efficiently explore the game tree, reducing the number of nodes evaluated from $O(b^d)$ to approximately $O(b^{d/2})$ in the best case, where $b$ is the branching factor and $d$ is the search depth. This optimization, combined with iterative deepening and Dart Isolates, allows the AI to make strategic decisions in real-time without blocking the main rendering loop.

<div align="center">

[![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![Android](https://img.shields.io/badge/Android-3DDC84?style=for-the-badge&logo=android&logoColor=white)](https://www.android.com)

</div>

---

## 📦 Installation
Head to the **Releases** tab of your repository to download the version of the app.
Download the optimized release APK for the latest version of the game from the link below:  

<br>
<div align="center">

[![Download APK](https://img.shields.io/badge/DOWNLOAD-APK_RELEASE-blue?style=for-the-badge&logo=android&logoColor=white)](https://github.com/YOUR_GITHUB_USERNAME/YOUR_REPO_NAME/releases/download/v1.0.0/app-release.apk)

<br>
<h3>Or Scan to Install</h3>
<img src="assets/docs/qrCode.png" alt="qr code" width="180"/>
</div>
<br>

---

## ✨ Features

*   **Multiple Game Modes**
    *   **Human vs Human**: Local pass-and-play multiplayer.
    *   **Human vs AI**: Challenge the computer (you play as Red, AI plays as Blue).
    *   **AI vs AI**: Configure different algorithms and depths for both players to observe matches.
*   🤖 **Advanced AI Implementation**
    *   Minimax search tree with Alpha-Beta pruning.
    *   Iterative deepening search to manage time limits.
    *   Six customizable evaluation profiles (Balanced, Orb Count, Critical Mass, Strategic Position, Opponent Mobility, Explosion Potential).
*   ⚙️ **Detailed Configurations**
    *   Customizable grid sizes: Small (6×5), Medium (9×6), and Large (10×8).
    *   Adjustable search depth (1-5 levels) and time limit per move.
    *   Adjustable animation speeds for customized pacing.
*   📜 **Match History**
    *   Automatically logs matches with dates, turns, board details, and winner statistics.
    *   Saves match results locally using persistent JSON storage.

---

## 🎲 Game Rules

1.  Players take turns placing orbs (🔴|🔵) in valid cells (either empty or cells they already own).
2.  Each cell has a **critical mass** equal to the number of orthogonal neighbors:
    *   **Corner cells**: Critical Mass = 2
    *   **Edge cells**: Critical Mass = 3
    *   **Middle cells**: Critical Mass = 4
3.  When a cell reaches its critical mass, it **explodes** 💥:
    *   It loses orbs equal to its critical mass.
    *   One orb is distributed to each adjacent neighbor.
    *   All neighbor cells are converted to the exploding player's color.
4.  Neighbor cells that exceed their critical mass will explode in a **chain reaction**.
5.  A player wins when they eliminate all opponent orbs from the board (only checked after both players have made at least one move) 🏆.

---

## 🛠️ Technical Details & Optimizations

### AI Algorithms & Heuristics

The AI evaluates board positions by calling specific functions defined in [lib/engine/ai_player.dart](lib/engine/ai_player.dart):

1.  **Orb Count Strategy** ([_heuristicOrbCount](lib/engine/ai_player.dart#L135)): Focuses on the ratio difference in total orbs between the AI and the opponent.
    $$\text{Score} = \frac{\text{My Orbs} - \text{Opponent Orbs}}{\text{Total Orbs}}$$
2.  **Critical Mass Strategy** ([_heuristicCriticalMass](lib/engine/ai_player.dart#L149)): Prioritizes placing orbs in cells that are close to exploding to set up quick reactions.
3.  **Strategic Position Strategy** ([_heuristicStrategicPosition](lib/engine/ai_player.dart#L164)): Assigns higher weights to corner and edge cells since they require fewer orbs to explode and are safer from opponent attacks.
    $$\text{Cell Value} = \frac{1}{\text{Critical Mass}}$$
4.  **Opponent Mobility Analysis** ([_heuristicOpponentMobility](lib/engine/ai_player.dart#L181)): Calculates the difference in available legal moves to restrict the opponent's space.
5.  **Explosion Potential Strategy** ([_heuristicExplosionPotential](lib/engine/ai_player.dart#L195)): Rewards placing orbs near opponent cells, setting up explosive chain captures.

---

### ⚡ Performance Optimizations

#### 1. Immutable State Management & Cheap Copies
To evaluate thousands of future paths inside the minimax search, the board is designed with an immutable cell architecture. Instead of heavy objects, cells are lightweight structures, enabling extremely quick board duplications during state search.

Reference from [lib/models/cell.dart](lib/models/cell.dart):
```dart
class Cell {
  const Cell({this.count = 0, this.player});
  final int count;
  final Player? player;
  
  bool get isEmpty => count == 0 || player == null;
  Cell withAddedOrb(Player p) => Cell(count: count + 1, player: p);
}
```

#### 2. Background Computation via Dart Isolates
Minimax searches explore exponential game paths. To prevent frame drops and keep animations running smoothly at 60 FPS, the calculation is run on a background thread using a Dart isolate.

Reference from [lib/engine/ai_isolate.dart](lib/engine/ai_isolate.dart):
```dart
Future<AIResult> computeAIMove(AIArgs args) async {
  return compute(runAI, args);
}
```

#### 3. Iterative BFS Explosion Resolution
Explosions are resolved iteratively using a Queue-based BFS (Breadth-First Search) rather than recursion. This eliminates call-stack growth and prevents stack overflow errors during massive chain reactions.

Reference from [lib/engine/chain_reaction_engine.dart](lib/engine/chain_reaction_engine.dart):
```dart
final queue = Queue<(int, int)>();
// Seed queue with critical cells...
while (queue.isNotEmpty) {
  final (row, col) = queue.removeFirst();
  // Explode cell and distribute to orthogonal neighbors...
}
```

---

## 📸 Screenshots

<div align="center">
  <table border="0">
    <tr>
      <td><p align="center"><b>Title Screen</b></p><img src="screenshots/title_screen.png" alt="Title Screen" width="230"/></td>
      <td><p align="center"><b>Mode Selection</b></p><img src="screenshots/mode_selection_screen.png" alt="Mode Selection" width="230"/></td>
      <td><p align="center"><b>Game Settings</b></p><img src="screenshots/settings_screen.png" alt="Game Settings" width="230"/></td>
    </tr>
    <tr>
      <td><p align="center"><b>Gameplay (9×6)</b></p><img src="screenshots/gameplay_screen.png" alt="Gameplay Screen" width="230"/></td>
      <td><p align="center"><b>Match Results</b></p><img src="screenshots/result_screen.png" alt="Results" width="230"/></td>
      <td><p align="center"><b>History Logs</b></p><img src="screenshots/history_screen.png" alt="History Logs" width="230"/></td>
    </tr>
  </table>
</div>

---

## 🛠️ Building from Source

1.  **Prerequisites**
    *   Flutter SDK installed on your computer.
    *   Dart SDK.
    *   Android Studio / VS Code with Flutter extensions.
2.  **Setup**
    ```bash
    # Clone the repository
    git clone https://github.com/YOUR_GITHUB_USERNAME/YOUR_REPO_NAME.git
    
    # Go to folder
    cd YOUR_REPO_NAME
    
    # Get dependencies
    flutter pub get
    
    # Run the application
    flutter run
    ```

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
