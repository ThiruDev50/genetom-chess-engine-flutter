import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:genetom_chess_engine/genetom_chess_engine.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const ChessPage(),
    );
  }
}

class ChessPage extends StatefulWidget {
  const ChessPage({super.key});

  @override
  State<ChessPage> createState() => _ChessPageState();
}

class _ChessPageState extends State<ChessPage> {
  Color primaryColor = const Color(0xff045388);
  Color secondaryColor = const Color(0xfff5811d);
  Color bgColor = const Color(0xffF2F2F2);
  Color iconsTextColor = const Color(0xffFFFFFF);

  List<CellPosition> validMoves = [];
  late bool isPlayerTurn;
  bool isPlayerWhite = true;
  CellPosition? currSelectedElementPosition;
  late ChessEngine chessEngine;
  List<List<int>> boardData = [
    [0, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0]
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showPopup(context);
    });
  }

  void _showGameOverPopup(BuildContext context, String winBy) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: primaryColor,
          title: Column(
            children: [
              Text(winBy,
                  style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10)),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    initializeChessEngine(isPlayerWhite);
                  },
                  child: Text('Play Again',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: primaryColor)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showPopup(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: primaryColor,
          title: Text('Choose your side!',
              style: TextStyle(color: bgColor, fontWeight: FontWeight.bold)),
          content: Text('What would you like to play as?',
              style: TextStyle(color: bgColor, fontWeight: FontWeight.bold)),
          actions: <Widget>[
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
                color: bgColor, // Button background color
              ),
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                  initializeChessEngine(true);
                },
                child: Text(
                  'White',
                  style: TextStyle(
                      color: primaryColor, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
                color: bgColor, // Button background color
              ),
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                  initializeChessEngine(false);
                },
                child: Text(
                  'Black',
                  style: TextStyle(
                      color: primaryColor, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  initializeChessEngine(bool isWhite) {
    isPlayerWhite = isWhite;
    isPlayerTurn = isPlayerWhite;
    ChessConfig config = ChessConfig(
        isAgainstComputer: true,
        isPlayerAWhite: isPlayerWhite,
        difficulty: Difficulty.medium);
    chessEngine = ChessEngine(
      config,
      pawnPromotion: (isWhitePawn, targetPosition) {
        ChessPiece piece;
        if (isWhitePawn) {
          piece = ChessPiece.queen;
        } else {
          piece = ChessPiece.queen;
        }
        chessEngine.setPawnPromotion(targetPosition, piece);
        reloadBoard();
      },
      boardChangeCallback: (newData) {
        boardData = newData;
        setState(() {});
      },
      gameOverCallback: (gameStatus) {
        if (gameStatus == GameOver.blackWins) {
          _showGameOverPopup(context, 'Black wins');
        } else if (gameStatus == GameOver.whiteWins) {
          _showGameOverPopup(context, 'White wins');
        } else {
          _showGameOverPopup(context, 'Match Draw!');
        }
      },
    );

    if (!isPlayerWhite) {
      Future.delayed(const Duration(seconds: 1), () {
        computerTurn();
      });
    }
  }

  void reloadBoard() {
    boardData = chessEngine.getBoardData();
    setState(() {});
  }

  computerTurn() async {
    Future.delayed(const Duration(milliseconds: 200), () async {
      isPlayerTurn = false;
      MovesModel? pos = await chessEngine.generateBestMove();
      if (pos == null) {
        return;
      }
      isPlayerTurn = true;
      chessEngine.movePiece(pos);
      resetMovesData();
      reloadBoard();
    });
  }

  resetMovesData() {
    validMoves = [];
    currSelectedElementPosition = null;
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double dialogSize =
        screenWidth < screenHeight ? screenWidth * 0.8 : screenHeight * 0.8;

    return Scaffold(
      backgroundColor: Colors.grey,
      appBar: AppBar(
        centerTitle: true,
        elevation: 2,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
        title: Text(
          "Genetom Chess",
          style: TextStyle(color: iconsTextColor),
        ),
        backgroundColor: primaryColor,
      ),
      body: Center(
        child: SizedBox(
          height: dialogSize,
          width: dialogSize,
          child: _chessBoard(),
        ),
      ),
    );
  }

  Widget _chessBoard() {
    return GridView.builder(
      itemCount: 64,
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 8,
      ),
      itemBuilder: (BuildContext context, int index) {
        // Determine the color of the square based on its position
        Color color =
            ((index ~/ 8) + (index % 8)) % 2 == 0 ? primaryColor : Colors.white;
        // print(currBox.row.toString()+currBox.col.toString());
        for (var element in validMoves) {
          if (element.row == (index ~/ 8) && element.col == (index % 8)) {
            color = Colors.orange;
            break;
          }
        }

        return chessBlock(boardData, index, color);
      },
    );
  }

  Widget chessBlock(List<List<int>> boardData, int index, Color color) {
    int row = index ~/ 8; // Calculate row index
    int col = index % 8; // Calculate column index

    String pieceImgPath = getPeiceSvgImgPath(boardData[row][col]);
    bool checkIfThisBlockIsValidMove() {
      for (var ele in validMoves) {
        if (ele.row == row && ele.col == col) {
          return true;
        }
      }
      return false;
    }

    bool checkIfClickAllowed() {
      if (!isPlayerTurn) {
        return false;
      }
      for (var ele in validMoves) {
        if (ele.row == row && ele.col == col) {
          return true;
        }
      }

      if ((isPlayerWhite && boardData[row][col] > 0) ||
          (!isPlayerWhite && boardData[row][col] < 0)) {
        return true;
      }
      return false;
    }

    blockClicked() async {
      if (!checkIfClickAllowed()) {
        resetMovesData();
        reloadBoard();
        return;
      }

      if (checkIfThisBlockIsValidMove() &&
          currSelectedElementPosition != null) {
        MovesModel move = MovesModel(
            targetPosition: CellPosition(row: row, col: col),
            currentPosition: CellPosition(
                row: currSelectedElementPosition!.row,
                col: currSelectedElementPosition!.col));
        chessEngine.movePiece(move);
        resetMovesData();
        reloadBoard();
        await computerTurn();
        return;
      }

      resetMovesData();
      currSelectedElementPosition = CellPosition(row: row, col: col);
      validMoves = chessEngine.getValidMovesOfPeiceByPosition(
          chessEngine.getBoardData(), CellPosition(row: row, col: col));
      if (validMoves.isEmpty) {
        resetMovesData();
      }
      reloadBoard();
    }

    return GestureDetector(
      onTap: () async {
        await blockClicked();
      },
      child: Container(
        decoration:
            BoxDecoration(border: Border.all(color: Colors.green, width: 1)),
        child: Container(
          width: 30.0,
          height: 30.0,
          color: color,
          child: Container(
            padding: const EdgeInsets.all(5),
            child: pieceImgPath.isNotEmpty
                ? SvgPicture.asset(pieceImgPath)
                : const SizedBox.shrink(),
          ),
        ),
      ),
    );
  }

  String getPeiceSvgImgPath(int piecePower) {
    if (piecePower == emptyCellPower) {
      return '';
    }
    String peicePath = 'assets/ChessPiece/';
    if (piecePower > 0) {
      peicePath += 'white_';
    } else {
      peicePath += 'black_';
    }
    String? fileName = filePath[piecePower.abs()];
    if (fileName == null) {
      return '';
    }
    return '$peicePath$fileName.svg';
  }

  Map<int, String> filePath = {
    pawnPower: 'pawn',
    rookPower: 'rook',
    bishopPower: 'bishop',
    horsePower: 'horse',
    queenPower: 'queen',
    kingPower: 'king',
  };
}
