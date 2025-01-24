import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jogo da Velha',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: GameBoard(),
      debugShowCheckedModeBanner: false, // Remover o banner de debug
    );
  }
}

class GameBoard extends StatefulWidget {
  @override
  _GameBoardState createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard> {
  List<String> board = List.generate(9, (_) => '');
  bool isPlayerX = true;
  String winner = ''; // Armazena o vencedor, ou "Empate"
  bool gameOver = false; // Indica se o jogo acabou
  bool isPlayingWithComputer = false; // Flag para saber se está jogando contra o computador

  // Função para realizar a jogada
  void makeMove(int index) {
    if (board[index] == '' && !gameOver) {
      setState(() {
        board[index] = isPlayerX ? 'X' : 'O';
        isPlayerX = !isPlayerX;
      });
      checkGameStatus();

      // Se for a vez do computador, ele faz sua jogada
      if (!isPlayerX && isPlayingWithComputer && !gameOver) {
        Future.delayed(Duration(seconds: 1), () => makeComputerMove());
      }
    }
  }

  // Função para realizar a jogada do computador (simples AI)
  void makeComputerMove() {
    int index = getRandomEmptySpot();
    if (index != -1) {
      setState(() {
        board[index] = 'O';
        isPlayerX = !isPlayerX;
      });
      checkGameStatus();
    }
  }

  // Função para reiniciar o jogo
  void restartGame() {
    setState(() {
      board = List.generate(9, (_) => '');
      isPlayerX = true;
      winner = '';
      gameOver = false;
    });
  }

  // Função para verificar vitória ou empate
  void checkGameStatus() {
    // Listas de combinações vencedoras
    List<List<int>> winningCombinations = [
      [0, 1, 2],
      [3, 4, 5],
      [6, 7, 8],
      [0, 3, 6],
      [1, 4, 7],
      [2, 5, 8],
      [0, 4, 8],
      [2, 4, 6],
    ];

    for (var combination in winningCombinations) {
      String a = board[combination[0]];
      String b = board[combination[1]];
      String c = board[combination[2]];

      if (a == b && b == c && a != '') {
        setState(() {
          winner = a;
          gameOver = true;
        });
        return;
      }
    }

    // Verificar se houve empate (todas as células preenchidas)
    if (!board.contains('') && winner == '') {
      setState(() {
        winner = 'Empate';
        gameOver = true;
      });
    }
  }

  // Função para pegar um índice aleatório vazio para o computador jogar
  int getRandomEmptySpot() {
    List<int> emptySpots = [];
    for (int i = 0; i < board.length; i++) {
      if (board[i] == '') emptySpots.add(i);
    }
    if (emptySpots.isEmpty) return -1;
    return emptySpots[Random().nextInt(emptySpots.length)];
  }

  // Função para configurar o jogo para jogar com o computador
  void setPlayWithComputer(bool isComputer) {
    setState(() {
      isPlayingWithComputer = isComputer;
      restartGame();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Usando MediaQuery para ajustar o layout para telas menores
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    // Ajuste do tamanho da grade para 30% da largura da tela
    double gridSize = screenWidth * 0.3;
    double buttonHeight = 30.0; // Tamanho fixo para os botões

    return Scaffold(
      appBar: AppBar(title: Text('Jogo da Velha')),
      body: Center(
        child: Container(
          width: screenWidth * 0.3, // 30% da largura da tela
          height: screenHeight * 0.90, // 90% da altura da tela
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.black),
            color: const Color.fromARGB(255, 176, 203, 195),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Seleção de modo de jogo
              Padding(
                padding: const EdgeInsets.all(7.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () => setPlayWithComputer(false),
                      child: Text('Humano x Humano'),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () => setPlayWithComputer(true),
                      child: Text('Humano x Computador'),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              // Grid de Jogo
              Container(
                width: gridSize,
                height: gridSize,
                child: GridView.builder(
                  shrinkWrap: true,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 4,
                    mainAxisSpacing: 4,
                    childAspectRatio: 1,
                  ),
                  itemCount: 9,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () => makeMove(index),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black),
                          color: const Color.fromARGB(255, 187, 241, 241),
                        ),
                        child: Center(
                          child: Text(
                            board[index],
                            style: TextStyle(
                              fontSize: 36, // Tamanho ajustado para caber
                              fontWeight: FontWeight.bold,
                              color: board[index] == 'X' ? const Color.fromARGB(255, 114, 33, 243) : const Color.fromARGB(255, 54, 231, 244),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 20),
              winner.isNotEmpty
                  ? Text(
                      winner == 'Empate' ? 'Empate!' : '$winner Parabéns você venceu!',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    )
                  : SizedBox(),
              SizedBox(height: 20),
              // Botão de reiniciar com altura ajustada
              Container(
                height: buttonHeight,
                child: ElevatedButton(
                  onPressed: restartGame,
                  child: Text('Recomeçar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
