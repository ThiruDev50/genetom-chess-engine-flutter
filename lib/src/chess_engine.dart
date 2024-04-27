// ignore_for_file: file_names

import 'dart:async';
import 'dart:math';

import 'package:genetom_chess_engine/src/chess_engine_core.dart';
import 'package:genetom_chess_engine/src/valid_moves.dart';

class ChessEngine {
  //Position tables
  List<List<double>> _whitePawnTable = [];
  List<List<double>> _whiteHorseTable = [];
  List<List<double>> _whiteBishopTable = [];
  List<List<double>> _whiteRookTable = [];
  List<List<double>> _whiteQueenTable = [];
  List<List<double>> _whiteKingMidGameTable = [];
  List<List<double>> _whiteKingEndgameTable = [];

  List<List<double>> _blackPawnTable = [];
  List<List<double>> _blackHorseTable = [];
  List<List<double>> _blackBishopTable = [];
  List<List<double>> _blackRookTable = [];
  List<List<double>> _blackQueenTable = [];
  List<List<double>> _blackKingMidGameTable = [];
  List<List<double>> _blackKingEndgameTable = [];

  List<List<int>> _board = [];
  final List<MovesLogModel> _moveLogs = [];
  int _maxDepth = 1;
  late bool boardViewIsWhite;
  late ChessConfig chessConfig;
  late Function(List<List<int>>) _boardChangeCallback;
  Function(bool, CellPosition)? _pawnPromotion; //
  late Function(GameOver) _gameOverCallback; //
  ChessEngine(ChessConfig config,
      {required Function(List<List<int>>) boardChangeCallback,
      required Function(GameOver) gameOverCallback,
      Function(bool, CellPosition)? pawnPromotion}) {
    chessConfig = config;
    boardViewIsWhite = chessConfig.isPlayerAWhite;
    _board = _initializeBoard();
    _initializePositionPointsTable();
    _initializeDifficultyMode();
    _boardChangeCallback = boardChangeCallback;
    _gameOverCallback = gameOverCallback;
    _pawnPromotion = pawnPromotion;
    _notifyBoardChangeCallback();
  }

  _initializeDifficultyMode() {
    if (chessConfig.difficulty == Difficulty.tooEasy) {
      _maxDepth = 2;
    } else if (chessConfig.difficulty == Difficulty.easy) {
      _maxDepth = 3;
    } else if (chessConfig.difficulty == Difficulty.medium) {
      _maxDepth = 4;
    } else if (chessConfig.difficulty == Difficulty.hard) {
      _maxDepth = 5;
    } else if (chessConfig.difficulty == Difficulty.asian) {
      _maxDepth = 6;
    }
  }

  _initializePositionPointsTable() {
    if (chessConfig.isPlayerAWhite) {
      //If player is white PSQT is => Bottom=White, Top=Black
      // As PSQT designed From bottom to top perspective (Neither black nor white)
      _setBottomToTopPositionPoints();
    } else {
      //If Player is black Then we are just reversing the perspective
      _setTopToBottomPositionPoints();
    }
  }

  _setBottomToTopPositionPoints() {
    _whitePawnTable = pawnSquareTable;
    _whiteHorseTable = horseSquareTable;
    _whiteBishopTable = bishopSquareTable;
    _whiteRookTable = rookSquareTable;
    _whiteQueenTable = queenSquareTable;
    _whiteKingMidGameTable = kingMidGameSquareTable;
    _whiteKingEndgameTable = kingEndGameSquareTable;

    _blackPawnTable =
        ChessEngineHelpers.deepCopyAndReversePositionTable(pawnSquareTable);
    _blackHorseTable =
        ChessEngineHelpers.deepCopyAndReversePositionTable(horseSquareTable);
    _blackBishopTable =
        ChessEngineHelpers.deepCopyAndReversePositionTable(bishopSquareTable);
    _blackRookTable =
        ChessEngineHelpers.deepCopyAndReversePositionTable(rookSquareTable);
    _blackQueenTable =
        ChessEngineHelpers.deepCopyAndReversePositionTable(queenSquareTable);
    _blackKingMidGameTable = ChessEngineHelpers.deepCopyAndReversePositionTable(
        kingMidGameSquareTable);
    _blackKingEndgameTable = ChessEngineHelpers.deepCopyAndReversePositionTable(
        kingEndGameSquareTable);
  }

  _setTopToBottomPositionPoints() {
    _blackPawnTable = pawnSquareTable;
    _blackHorseTable = horseSquareTable;
    _blackBishopTable = bishopSquareTable;
    _blackRookTable = rookSquareTable;
    _blackQueenTable = queenSquareTable;
    _blackKingMidGameTable = kingMidGameSquareTable;
    _blackKingEndgameTable = kingEndGameSquareTable;

    _whitePawnTable =
        ChessEngineHelpers.deepCopyAndReversePositionTable(pawnSquareTable);
    _whiteHorseTable =
        ChessEngineHelpers.deepCopyAndReversePositionTable(horseSquareTable);
    _whiteBishopTable =
        ChessEngineHelpers.deepCopyAndReversePositionTable(bishopSquareTable);
    _whiteRookTable =
        ChessEngineHelpers.deepCopyAndReversePositionTable(rookSquareTable);
    _whiteQueenTable =
        ChessEngineHelpers.deepCopyAndReversePositionTable(queenSquareTable);
    _whiteKingMidGameTable = ChessEngineHelpers.deepCopyAndReversePositionTable(
        kingMidGameSquareTable);
    _whiteKingEndgameTable = ChessEngineHelpers.deepCopyAndReversePositionTable(
        kingEndGameSquareTable);
  }

  void _notifyBoardChangeCallback() {
    _boardChangeCallback(_board);
  }

  void _notifyGameOverStatus(GameOver status) {
    _gameOverCallback(status);
  }

  List<List<int>> getBoardData() {
    return _board;
  }

  List<MovesLogModel> getMovesLogsData() {
    return _moveLogs;
  }

  Future<MovesModel?> generateBestMove() async {
    await Future.delayed(const Duration(milliseconds: 10));
    double alpha = -double.infinity;
    double beta = double.infinity;
    MoveScore res = _minimaxWithMoveAlphaBetaPruning(
        _board, _maxDepth, alpha, beta, !chessConfig.isPlayerAWhite);

    return res.move;
  }

  MovesModel? generateRandomMove() {
    List<CellPosition> allowedPeiceCoordinates = _getAllowedPieceCoordinates();
    allowedPeiceCoordinates.shuffle();
    for (var ele in allowedPeiceCoordinates) {
      List<CellPosition> validMove =
          getValidMovesOfPeiceByPosition(_board, ele);
      if (validMove.isEmpty) {
        continue;
      }
      validMove.shuffle();
      return MovesModel(
          currentPosition: CellPosition(row: ele.row, col: ele.col),
          targetPosition:
              CellPosition(row: validMove[0].row, col: validMove[0].col));
    }
    return null;
  }

  List<CellPosition> _getAllowedPieceCoordinates() {
    List<CellPosition> allowedPiecesPosition = [];

    for (int i = 0; i < 8; i++) {
      for (int j = 0; j < 8; j++) {
        if (chessConfig.isPlayerAWhite && _board[i][j] < 0) {
          allowedPiecesPosition.add(CellPosition(row: i, col: j));
        } else if (!chessConfig.isPlayerAWhite && _board[i][j] > 0) {
          allowedPiecesPosition.add(CellPosition(row: i, col: j));
        }
      }
    }

    return allowedPiecesPosition;
  }

  List<MovesModel> _getWhitePossibleMove(List<List<int>> boardCopy) {
    List<MovesModel> movesList = [];
    for (int i = 0; i < 8; i++) {
      for (int j = 0; j < 8; j++) {
        if (boardCopy[i][j] > emptyCellPower) {
          CellPosition currentPosition = CellPosition(row: i, col: j);
          List<CellPosition> possibleMove =
              getValidMovesOfPeiceByPosition(boardCopy, currentPosition);
          for (CellPosition targetPosition in possibleMove) {
            movesList.add(MovesModel(
                currentPosition: currentPosition,
                targetPosition: targetPosition));
          }
        }
      }
    }
    return movesList;
  }

  List<MovesModel> _getBlackPossibleMove(List<List<int>> boardCopy) {
    List<MovesModel> movesList = [];
    for (int i = 0; i < 8; i++) {
      for (int j = 0; j < 8; j++) {
        if (boardCopy[i][j] < emptyCellPower) {
          CellPosition currentPosition = CellPosition(row: i, col: j);
          List<CellPosition> possibleMove =
              getValidMovesOfPeiceByPosition(boardCopy, currentPosition);
          for (CellPosition targetPosition in possibleMove) {
            movesList.add(MovesModel(
                currentPosition: currentPosition,
                targetPosition: targetPosition));
          }
        }
      }
    }
    return movesList;
  }

  List<CellPosition> getValidMovesOfPeiceByPosition(
      List<List<int>> currBoard, CellPosition currentPosition) {
    var peice = currBoard[currentPosition.row][currentPosition.col];
    List<CellPosition> movesWithPossibleCheck = [];
    if (peice.abs() == horsePower) {
      movesWithPossibleCheck = ValidMoves.getValidHorseMoves(
          currBoard, currentPosition, boardViewIsWhite);
    }
    if (peice.abs() == rookPower) {
      movesWithPossibleCheck = ValidMoves.getValidRookMoves(
          currBoard, currentPosition, boardViewIsWhite);
    } else if (peice.abs() == bishopPower) {
      movesWithPossibleCheck = ValidMoves.getValidBishopMoves(
          currBoard, currentPosition, boardViewIsWhite);
    } else if (peice.abs() == queenPower) {
      movesWithPossibleCheck = ValidMoves.getValidQueenMoves(
          currBoard, currentPosition, boardViewIsWhite);
    } else if (peice.abs() == kingPower) {
      movesWithPossibleCheck = ValidMoves.getValidKingMove(
          currBoard, currentPosition, boardViewIsWhite, _moveLogs);
    } else if (peice.abs() == pawnPower) {
      movesWithPossibleCheck = ValidMoves.getValidPawnMove(
          currBoard, currentPosition, boardViewIsWhite);
    }

    return movesWithPossibleCheck;
  }

  bool checkMateCheckIfThisBoardInCheck(
      List<List<int>> curBoard, bool checkForWhiteKingCheckMate) {
    CellPosition kingPos = CellPosition(row: -1, col: -1);
    for (int i = 0; i < 8; i++) {
      for (int j = 0; j < 8; j++) {
        if (curBoard[i][j].abs() == kingPower) {
          if (checkForWhiteKingCheckMate && curBoard[i][j] > 0) {
            kingPos = CellPosition(row: i, col: j);
            break;
          } else if (!checkForWhiteKingCheckMate && curBoard[i][j] < 0) {
            kingPos = CellPosition(row: i, col: j);
            break;
          }
        }
      }
    }

    //Generate all Enemy possible moves,
    List<MovesModel> possibleOpponentsMove = [];
    if (checkForWhiteKingCheckMate) {
      possibleOpponentsMove = _getBlackPossibleMove(curBoard);
    } else {
      possibleOpponentsMove = _getWhitePossibleMove(curBoard);
    }
    for (MovesModel possibleMove in possibleOpponentsMove) {
      if (possibleMove.targetPosition.row == kingPos.row ||
          possibleMove.targetPosition.col == kingPos.col) {
        return true;
      }
    }
    return false;
  }

  bool isGameOverForThisBoard(List<List<int>> currBoard) {
    int kingCount = 0;
    for (List<int> ele in currBoard) {
      for (int item in ele) {
        if (item.abs() == kingPower) {
          if (kingCount == 1) {
            return false;
          }
          kingCount += 1;
        }
      }
    }
    return true;
  }

  MoveScore _minimaxWithMoveAlphaBetaPruning(
      currBoard, depth, alpha, beta, maximizingPlayer) {
    if (depth == 0 || isGameOverForThisBoard(currBoard)) {
      return MoveScore(move: null, score: _getScoreForBoard(currBoard));
    }

    if (maximizingPlayer) {
      double maxEval = -double.infinity;
      MovesModel? bestMove;
      List<MovesModel> whitePossibleMove = _getWhitePossibleMove(currBoard);
      for (MovesModel possibleMove in whitePossibleMove) {
        List<List<int>> boardCopy = ChessEngineHelpers.deepCopyBoard(currBoard);
        _movePieceForMinMax(boardCopy, possibleMove);
        double evaluation = _minimaxWithMoveAlphaBetaPruning(
                boardCopy, depth - 1, alpha, beta, false)
            .score;

        //Undoing the changes
        MovesModel undoingMove = MovesModel(
            currentPosition: possibleMove.targetPosition,
            targetPosition: possibleMove.currentPosition);
        _movePieceForMinMax(boardCopy, undoingMove);
        if (evaluation > maxEval) {
          maxEval = evaluation;
          bestMove = possibleMove;
        }
        alpha = max<double>(alpha, maxEval);
        if (beta <= alpha) {
          break; // Beta cut-off
        }
      }
      return MoveScore(move: bestMove, score: maxEval);
    } else {
      double minEval = double.infinity;
      MovesModel? bestMove;
      List<MovesModel> blackPossibleMove = _getBlackPossibleMove(currBoard);
      for (MovesModel possibleMove in blackPossibleMove) {
        List<List<int>> boardCopy = ChessEngineHelpers.deepCopyBoard(currBoard);
        _movePieceForMinMax(boardCopy, possibleMove);
        double evaluation = _minimaxWithMoveAlphaBetaPruning(
                boardCopy, depth - 1, alpha, beta, true)
            .score;
        //Undoing the changes
        MovesModel undoingMove = MovesModel(
            currentPosition: possibleMove.targetPosition,
            targetPosition: possibleMove.currentPosition);
        _movePieceForMinMax(boardCopy, undoingMove);
        if (evaluation < minEval) {
          minEval = evaluation;
          bestMove = possibleMove;
        }
        beta = min<double>(beta, minEval);
        if (beta <= alpha) {
          break; // Alpha cut-off
        }
      }
      return MoveScore(move: bestMove, score: minEval);
    }
  }

  double _getScoreForBoard(List<List<int>> currBoard) {
    double overallScore = 0;

    // Material Advantage
    overallScore += _getMaterialScore(currBoard);
    // Piece Mobility and Positional Advantages
    overallScore += _getPositionalScore(currBoard);

    return overallScore;
  }

  double _getMaterialScore(List<List<int>> currBoard) {
    double materialScore = 0;

    for (int row = 0; row < currBoard.length; row++) {
      for (int col = 0; col < currBoard.length; col++) {
        int piece = currBoard[row][col];
        switch (piece.abs()) {
          case pawnPower:
            materialScore +=
                pawnPower * (piece > 0 ? 1 : -1); // Assigning value to pawns
            break;
          case rookPower:
            materialScore +=
                rookPower * (piece > 0 ? 1 : -1); // Assigning value to rooks
            break;
          case horsePower:
            materialScore +=
                horsePower * (piece > 0 ? 1 : -1); // Assigning value to knights
            break;
          case bishopPower:
            materialScore += bishopPower *
                (piece > 0 ? 1 : -1); // Assigning value to bishops
            break;
          case queenPower:
            materialScore +=
                queenPower * (piece > 0 ? 1 : -1); // Assigning value to queens
            break;
          case kingPower:
            materialScore +=
                kingPower * (piece > 0 ? 1 : -1); // Assigning value to kings
            break;
          default:
            break;
        }
      }
    }

    return materialScore;
  }

  double _getPositionalScore(List<List<int>> currBoard) {
    double positionalScore = 0;
    for (int row = 0; row < currBoard.length; row++) {
      for (int col = 0; col < currBoard.length; col++) {
        int piece = currBoard[row][col];
        if (piece == emptyCellPower) {
          continue;
        }
        bool isWhitePiece = piece > emptyCellPower;
        double pieceScore = 0;
        if (isWhitePiece) {
          //White Position points
          if (piece.abs() == pawnPower) {
            pieceScore = _whitePawnTable[row][col];
          } else if (piece.abs() == horsePower) {
            pieceScore = _whiteHorseTable[row][col];
          } else if (piece.abs() == bishopPower) {
            pieceScore = _whiteBishopTable[row][col];
          } else if (piece.abs() == rookPower) {
            pieceScore = _whiteRookTable[row][col];
          } else if (piece.abs() == kingPower) {
            if (_isEndGame(currBoard, true)) {
              pieceScore = _whiteKingEndgameTable[row][col];
            } else {
              pieceScore = _whiteKingMidGameTable[row][col];
            }
          } else if (piece.abs() == queenPower) {
            pieceScore = _whiteQueenTable[row][col];
          }
        } else {
          //Black Position points
          if (piece.abs() == pawnPower) {
            pieceScore = _blackPawnTable[row][col];
          } else if (piece.abs() == horsePower) {
            pieceScore = _blackHorseTable[row][col];
          } else if (piece.abs() == bishopPower) {
            pieceScore = _blackBishopTable[row][col];
          } else if (piece.abs() == rookPower) {
            pieceScore = _blackRookTable[row][col];
          } else if (piece.abs() == kingPower) {
            if (_isEndGame(currBoard, false)) {
              pieceScore = _blackKingEndgameTable[row][col];
            } else {
              pieceScore = _blackKingMidGameTable[row][col];
            }
          } else if (piece.abs() == queenPower) {
            pieceScore = _blackQueenTable[row][col];
          }
        }
        if (isWhitePiece) {
          positionalScore += pieceScore;
        } else {
          positionalScore -= pieceScore;
        }
      }
    }

    return positionalScore;
  }

  bool _isEndGame(List<List<int>> curBoard, bool endGameCheckForWhite) {
    bool whiteQueenAlive = false;
    bool blackQueenAlive = false;
    int whiteMinorPieceCount = 0;
    int blackMinorPieceCount = 0;
    for (int i = 0; i < 8; i++) {
      for (int j = 0; j < 8; j++) {
        switch (curBoard[i][j]) {
          case queenPower:
            {
              whiteQueenAlive = true;
              break;
            }
          case const (-queenPower):
            {
              blackQueenAlive = true;
              break;
            }
          case const (bishopPower):
          case const (horsePower):
            {
              whiteMinorPieceCount += 1;
              break;
            }
          case const (-bishopPower):
          case const (-horsePower):
            {
              blackMinorPieceCount += 1;
              break;
            }
        }
        if (endGameCheckForWhite) {
          if (whiteQueenAlive && whiteMinorPieceCount > 2) {
            return false;
          }
        } else {
          if (blackQueenAlive && blackMinorPieceCount > 2) {
            return false;
          }
        }
      }
    }
    if ((!whiteQueenAlive && !blackQueenAlive)) {
      return true;
    }
    return false;
  }

  void _movePieceForMinMax(List<List<int>> currBoard, MovesModel moves) {
    try {
      currBoard[moves.targetPosition.row][moves.targetPosition.col] =
          currBoard[moves.currentPosition.row][moves.currentPosition.col];
      currBoard[moves.currentPosition.row][moves.currentPosition.col] =
          emptyCellPower;
    } catch (ex) {
      // Do Nothing
    }
  }

  setPawnPromotion(CellPosition targetPos, ChessPiece piece) {
    _setPawnPromotion(_board, targetPos, piece);
  }

  _setPawnPromotion(
      List<List<int>> currBoard, CellPosition targetPos, ChessPiece piece) {
    if (piece != ChessPiece.king && piece != ChessPiece.pawn) {
      int isWhite = currBoard[targetPos.row][targetPos.col] > 0 ? 1 : -1;
      currBoard[targetPos.row][targetPos.col] =
          isWhite * chessPieceValue[piece]!;
    }
  }

  void movePiece(MovesModel move) {
    if (_canPromotePawn(_board, move)) {
      if (_pawnPromotion != null) {
        bool isWhitePiece =
            _board[move.currentPosition.row][move.currentPosition.col] > 0;
        Future.delayed(const Duration(milliseconds: 100), () {
          _pawnPromotion!(isWhitePiece, move.targetPosition);
        });
      }
    }

    if (_board[move.currentPosition.row][move.currentPosition.col].abs() ==
            kingPower &&
        ((move.currentPosition.col - move.targetPosition.col).abs() == 2)) {
      // perfom castling
      _performCastling(_board, move);
    } else {
      _board[move.targetPosition.row][move.targetPosition.col] =
          _board[move.currentPosition.row][move.currentPosition.col];
      _board[move.currentPosition.row][move.currentPosition.col] =
          emptyCellPower;
    }
    _moveLogs.add(MovesLogModel(
        move: move,
        piece: _board[move.targetPosition.row][move.targetPosition.col]));
    GameOver? gameOverStatus = _checkIfGameOver(
        _board[move.targetPosition.row][move.targetPosition.col] > 0);
    if (gameOverStatus != null) {
      _notifyGameOverStatus(gameOverStatus);
    }
    _notifyBoardChangeCallback();
  }

  _performCastling(List<List<int>> currBoard, MovesModel move) {
    currBoard[move.targetPosition.row][move.targetPosition.col] =
        currBoard[move.currentPosition.row][move.currentPosition.col];
    currBoard[move.currentPosition.row][move.currentPosition.col] =
        emptyCellPower;

    // Castling with Right side Rook
    if (move.targetPosition.col > move.currentPosition.col) {
      currBoard[move.currentPosition.row][move.currentPosition.col + 1] =
          currBoard[move.currentPosition.row][7];
      currBoard[move.currentPosition.row][7] = emptyCellPower;
    }
    //Castling with left side rook
    else {
      currBoard[move.currentPosition.row][move.currentPosition.col - 1] =
          currBoard[move.currentPosition.row][0];
      currBoard[move.currentPosition.row][0] = emptyCellPower;
    }
  }

  bool _canPromotePawn(List<List<int>> currBoard, MovesModel move) {
    if (currBoard[move.currentPosition.row][move.currentPosition.col] ==
            pawnPower &&
        (move.targetPosition.row == 0 || move.targetPosition.row == 7)) {
      return true;
    }
    return false;
  }

  GameOver? _checkIfGameOver(bool islastMoveByWhite) {
    bool onlyKingsInBoard = true;
    for (var rowEle in _board) {
      for (var ele in rowEle) {
        if (ele.abs() != kingPower) {
          onlyKingsInBoard = false;
          break;
        }
      }
    }
    if (onlyKingsInBoard) {
      return GameOver.draw;
    }
    for (int i = 0; i < 8; i++) {
      for (int j = 0; j < 8; j++) {
        if (_board[i][j] != emptyCellPower) {
          if ((islastMoveByWhite && _board[i][j] < 0) ||
              (!islastMoveByWhite && _board[i][j] > 0)) {
            List<CellPosition> possible = getValidMovesOfPeiceByPosition(
                _board, CellPosition(row: i, col: j));
            if (possible.isNotEmpty) {
              return null;
            }
          }
        }
      }
    }
    if (islastMoveByWhite) {
      return GameOver.whiteWins;
    } else {
      return GameOver.blackWins;
    }
  }

  List<List<int>> _initializeBoard() {
    List<List<int>> chessBoard = [
      [
        -chessPieceValue[ChessPiece.rook]!,
        -chessPieceValue[ChessPiece.horse]!,
        -chessPieceValue[ChessPiece.bishop]!,
        -chessPieceValue[ChessPiece.queen]!,
        -chessPieceValue[ChessPiece.king]!,
        -chessPieceValue[ChessPiece.bishop]!,
        -chessPieceValue[ChessPiece.horse]!,
        -chessPieceValue[ChessPiece.rook]!,
      ],
      [
        -chessPieceValue[ChessPiece.pawn]!,
        -chessPieceValue[ChessPiece.pawn]!,
        -chessPieceValue[ChessPiece.pawn]!,
        -chessPieceValue[ChessPiece.pawn]!,
        -chessPieceValue[ChessPiece.pawn]!,
        -chessPieceValue[ChessPiece.pawn]!,
        -chessPieceValue[ChessPiece.pawn]!,
        -chessPieceValue[ChessPiece.pawn]!,
      ],
      [
        chessPieceValue[ChessPiece.emptyCell]!,
        chessPieceValue[ChessPiece.emptyCell]!,
        chessPieceValue[ChessPiece.emptyCell]!,
        chessPieceValue[ChessPiece.emptyCell]!,
        chessPieceValue[ChessPiece.emptyCell]!,
        chessPieceValue[ChessPiece.emptyCell]!,
        chessPieceValue[ChessPiece.emptyCell]!,
        chessPieceValue[ChessPiece.emptyCell]!
      ],
      [
        chessPieceValue[ChessPiece.emptyCell]!,
        chessPieceValue[ChessPiece.emptyCell]!,
        chessPieceValue[ChessPiece.emptyCell]!,
        chessPieceValue[ChessPiece.emptyCell]!,
        chessPieceValue[ChessPiece.emptyCell]!,
        chessPieceValue[ChessPiece.emptyCell]!,
        chessPieceValue[ChessPiece.emptyCell]!,
        chessPieceValue[ChessPiece.emptyCell]!
      ],
      [
        chessPieceValue[ChessPiece.emptyCell]!,
        chessPieceValue[ChessPiece.emptyCell]!,
        chessPieceValue[ChessPiece.emptyCell]!,
        chessPieceValue[ChessPiece.emptyCell]!,
        chessPieceValue[ChessPiece.emptyCell]!,
        chessPieceValue[ChessPiece.emptyCell]!,
        chessPieceValue[ChessPiece.emptyCell]!,
        chessPieceValue[ChessPiece.emptyCell]!
      ],
      [
        chessPieceValue[ChessPiece.emptyCell]!,
        chessPieceValue[ChessPiece.emptyCell]!,
        chessPieceValue[ChessPiece.emptyCell]!,
        chessPieceValue[ChessPiece.emptyCell]!,
        chessPieceValue[ChessPiece.emptyCell]!,
        chessPieceValue[ChessPiece.emptyCell]!,
        chessPieceValue[ChessPiece.emptyCell]!,
        chessPieceValue[ChessPiece.emptyCell]!
      ],
      [
        chessPieceValue[ChessPiece.pawn]!,
        chessPieceValue[ChessPiece.pawn]!,
        chessPieceValue[ChessPiece.pawn]!,
        chessPieceValue[ChessPiece.pawn]!,
        chessPieceValue[ChessPiece.pawn]!,
        chessPieceValue[ChessPiece.pawn]!,
        chessPieceValue[ChessPiece.pawn]!,
        chessPieceValue[ChessPiece.pawn]!,
      ],
      [
        chessPieceValue[ChessPiece.rook]!,
        chessPieceValue[ChessPiece.horse]!,
        chessPieceValue[ChessPiece.bishop]!,
        chessPieceValue[ChessPiece.queen]!,
        chessPieceValue[ChessPiece.king]!,
        chessPieceValue[ChessPiece.bishop]!,
        chessPieceValue[ChessPiece.horse]!,
        chessPieceValue[ChessPiece.rook]!,
      ]
    ];
    if (!chessConfig.isPlayerAWhite) {
      for (int i = 0; i < 2; i++) {
        for (int j = 0; j < 8; j++) {
          chessBoard[i][j] = (-1 * chessBoard[i][j]);
        }
      }
      for (int i = 6; i < 8; i++) {
        for (int j = 0; j < 8; j++) {
          chessBoard[i][j] = (-1 * chessBoard[i][j]);
        }
      }
    }
    return chessBoard;
  }
}
