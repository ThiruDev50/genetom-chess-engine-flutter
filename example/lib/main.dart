import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
      title: 'Genetom Chess Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff045388)),
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

  String fenBtnString = '';
  String fenBtnClickToCopyLabel = 'Copy FEN String';
  String fenBtnCopiedLabel = 'FEN Copied!';
  late Color fenBtnContainerColor;
  @override
  void initState() {
    super.initState();
    fenBtnContainerColor = primaryColor;
    fenBtnString = fenBtnClickToCopyLabel;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showLandingPopup(context);
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

  void _showTeamPickPopup(BuildContext context) {
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

  void _showLandingPopup(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: primaryColor,
          content: Text('How do you want to start the game?',
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
                  _showFenInputPopup(context);
                },
                child: Text(
                  'Import FEN',
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
                  _showTeamPickPopup(context);
                },
                child: Text(
                  'Start New Game',
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

  void _showFenInputPopup(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, setState) {
            return AlertDialog(
              backgroundColor: primaryColor,
              title: const Text(
                'Enter your FEN',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.white,
                        width: 1.0,
                      ),
                    ),
                    child: TextField(
                      controller: fenInpController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          // Use OutlineInputBorder for outline border
                          borderSide: const BorderSide(
                              color: Colors.transparent,
                              width: 1.0), // Border properties
                          borderRadius: BorderRadius.circular(
                              8.0), // Optional: border radius
                        ),
                        focusedBorder: OutlineInputBorder(
                          // Use the same border for focused state
                          borderSide: const BorderSide(
                              color: Colors.transparent,
                              width: 1.0), // Border properties
                          borderRadius: BorderRadius.circular(
                              8.0), // Optional: border radius
                        ),
                        hintText: '',
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10)),
                    child: ElevatedButton(
                      onPressed: () {
                        if (_validateFenInput()) {
                          Navigator.of(context).pop();
                          _showTeamPickPopup(context);
                        } else {
                          final snackBar = SnackBar(
                            content: const Text(
                              'Invalid FEN String',
                              style: TextStyle(color: Colors.white),
                            ),
                            duration: const Duration(seconds: 2),
                            backgroundColor: Colors.red,
                            action: SnackBarAction(
                              label: 'Close',
                              onPressed: () {
                                // Some action to take when the user presses the action button
                              },
                            ),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        }
                      },
                      child: Text(
                        'Load FEN',
                        style: TextStyle(color: primaryColor),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  TextEditingController fenInpController = TextEditingController();
  bool _validateFenInput() {
    String input = fenInpController.text.trim();
    var chessEngCopy = ChessEngine(ChessConfig(isPlayerAWhite: true),
        boardChangeCallback: (a) {}, gameOverCallback: (a) {});
    bool isValidFen = chessEngCopy.isValidFEN(input);
    return isValidFen;
  }

  String reverseString(String str) {
    String reversed = '';
    for (int i = str.length - 1; i >= 0; i--) {
      reversed += str[i];
    }
    return reversed;
  }

  initializeChessEngine(bool isWhite) {
    isPlayerWhite = isWhite;
    String fenInput = fenInpController.text.trim();
    List<String> parts = fenInpController.text.trim().split(' ');

    if (fenInpController.text.trim().isEmpty) {
      //NO FEN so Current Turn is white
      isPlayerTurn = isPlayerWhite;
    } else {
      if ((parts[1] == 'w' && isPlayerWhite) ||
          parts[1] == 'b' && !isPlayerWhite) {
        isPlayerTurn = true;
      } else {
        isPlayerTurn = false;
      }
    }

    if (!isPlayerWhite && fenInpController.text.trim().isNotEmpty) {
      //Reverse FEN String
      var reversedFenPos = parts[0].split('').reversed.join('');
      parts[0] = reversedFenPos;
      fenInput = parts.join(' ');
    }
    ChessConfig config = ChessConfig(
        fenString: fenInput,
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
    if (!isPlayerTurn) {
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
        child: Column(
          children: [
            const SizedBox(
              height: 10,
            ),
            SizedBox(
              height: dialogSize,
              width: dialogSize,
              child: _chessBoard(),
            ),
            const SizedBox(
              height: 10,
            ),
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () {
                  bool isWhiteTurn = false;
                  if (isPlayerTurn) {
                    if (isPlayerWhite) {
                      isWhiteTurn = true;
                    } else {
                      isWhiteTurn = false;
                    }
                  } else {
                    if (isPlayerWhite) {
                      isWhiteTurn = false;
                    } else {
                      isWhiteTurn = true;
                    }
                  }
                  Clipboard.setData(ClipboardData(
                      text: chessEngine.getFenString(isWhiteTurn)));
                  fenBtnString = fenBtnCopiedLabel;
                  fenBtnContainerColor = Colors.green;
                  setState(() {});
                  Future.delayed(
                    const Duration(seconds: 2),
                    () {
                      fenBtnString = fenBtnClickToCopyLabel;
                      fenBtnContainerColor = primaryColor;
                      setState(() {});
                    },
                  );
                },
                child: Container(
                  width: 200,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: fenBtnContainerColor),
                  padding: const EdgeInsets.all(10),
                  child: Center(
                      child: Text(
                    fenBtnString,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.white),
                  )),
                ),
              ),
            )
          ],
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
            ((index ~/ 8) + (index % 8)) % 2 == 0 ? Colors.white : primaryColor;
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

    BorderRadiusGeometry? borderRadius;
    double curve = 15;
    if (row == 0 && col == 0) {
      borderRadius = BorderRadius.only(topLeft: Radius.circular(curve));
    } else if (row == 0 && col == 7) {
      borderRadius = BorderRadius.only(topRight: Radius.circular(curve));
    } else if (row == 7 && col == 0) {
      borderRadius = BorderRadius.only(bottomLeft: Radius.circular(curve));
    } else if (row == 7 && col == 7) {
      borderRadius = BorderRadius.only(bottomRight: Radius.circular(curve));
    }
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () async {
          await blockClicked();
        },
        child: Container(
          decoration: BoxDecoration(
              borderRadius: borderRadius,
              border: Border.all(color: Colors.green, width: 1)),
          child: Container(
            decoration: BoxDecoration(
              color: color,
              borderRadius: borderRadius,
            ),
            width: 30.0,
            height: 30.0,
            child: Container(
              padding: const EdgeInsets.all(5),
              child: pieceImgPath.isNotEmpty
                  ? SvgPicture.asset(pieceImgPath)
                  : const SizedBox.shrink(),
            ),
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
