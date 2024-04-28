import 'package:genetom_chess_engine/src/chess_engine_core.dart';

class ValidMoves {
  static List<CellPosition> getValidHorseMoves(
      List<List<int>> board, CellPosition currPosition, bool boardViewIsWhite) {
    int row = currPosition.row;
    int col = currPosition.col;
    List<CellPosition> validMovesList = [];

    //  North Check
    if (row - 2 >= 0) {
      // N||th East Possibility
      if (col + 1 < 8 &&
          ((board[row][col] > 0 && board[row - 2][col + 1] < 0) ||
              (board[row][col] < 0 && board[row - 2][col + 1] > 0) ||
              (board[row - 2][col + 1] == emptyCellPower))) {
        validMovesList.add(CellPosition(row: row - 2, col: col + 1));
      }
      // North West possibility
      if (col - 1 >= 0 &&
          ((board[row][col] > 0 && board[row - 2][col - 1] < 0) ||
              (board[row][col] < 0 && board[row - 2][col - 1] > 0) ||
              (board[row - 2][col - 1] == emptyCellPower))) {
        validMovesList.add(CellPosition(row: row - 2, col: col - 1));
      }
    }

    //  South Check
    if (row + 2 < 8) {
      // South East Possibility
      if (col + 1 < 8 &&
          ((board[row][col] > 0 && board[row + 2][col + 1] < 0) ||
              (board[row][col] < 0 && board[row + 2][col + 1] > 0) ||
              (board[row + 2][col + 1] == emptyCellPower))) {
        validMovesList.add(CellPosition(row: row + 2, col: col + 1));
      }
      // South West possibility
      if (col - 1 >= 0 &&
          ((board[row][col] > 0 && board[row + 2][col - 1] < 0) ||
              (board[row][col] < 0 && board[row + 2][col - 1] > 0) ||
              (board[row + 2][col - 1] == emptyCellPower))) {
        validMovesList.add(CellPosition(row: row + 2, col: col - 1));
      }
    }

    //  East Check
    if (col + 2 < 8) {
      //  East South Check
      if (row + 1 < 8) {
        if (board[row + 1][col + 2] == emptyCellPower) {
          validMovesList.add(CellPosition(row: row + 1, col: col + 2));
        } else if ((board[row][col] > 0 && board[row + 1][col + 2] < 0) ||
            (board[row][col] < 0 && board[row + 1][col + 2] > 0)) {
          validMovesList.add(CellPosition(row: row + 1, col: col + 2));
        }
      }

      //  East North check
      if (row - 1 >= 0) {
        if (board[row - 1][col + 2] == emptyCellPower) {
          validMovesList.add(CellPosition(row: row - 1, col: col + 2));
        } else if ((board[row][col] > 0 && board[row - 1][col + 2] < 0) ||
            (board[row][col] < 0 && board[row - 1][col + 2] > 0)) {
          validMovesList.add(CellPosition(row: row - 1, col: col + 2));
        }
      }
    }

    //  West Check
    if (col - 2 >= 0) {
      // West South check
      if (row + 1 < 8) {
        if (board[row + 1][col - 2] == emptyCellPower) {
          validMovesList.add(CellPosition(row: row + 1, col: col - 2));
        } else if ((board[row][col] > 0 && board[row + 1][col - 2] < 0) ||
            (board[row][col] < 0 && board[row + 1][col - 2] > 0)) {
          validMovesList.add(CellPosition(row: row + 1, col: col - 2));
        }
      }

      //  West N||th check
      if (row - 1 >= 0) {
        if (board[row - 1][col - 2] == emptyCellPower) {
          validMovesList.add(CellPosition(row: row - 1, col: col - 2));
        } else if ((board[row][col] > 0 && board[row - 1][col - 2] < 0) ||
            (board[row][col] < 0 && board[row - 1][col - 2] > 0)) {
          validMovesList.add(CellPosition(row: row - 1, col: col - 2));
        }
      }
    }
    List<CellPosition> validMovesAfterCheckMateCheck = [];
    for (int inx = 0; inx < validMovesList.length; inx++) {
      MovesModel move = MovesModel(
          currentPosition: currPosition,
          targetPosition: CellPosition(
              row: validMovesList[inx].row, col: validMovesList[inx].col));

      if (!checkMateCheckIfThisMovePerformed(board, move, boardViewIsWhite)) {
        validMovesAfterCheckMateCheck.add(validMovesList[inx]);
      }
    }
    return validMovesAfterCheckMateCheck;
  }

  static List<CellPosition> getValidRookMoves(
      List<List<int>> board, CellPosition currPosition, bool boardViewIsWhite) {
    int row = currPosition.row;
    int col = currPosition.col;
    List<CellPosition> validMovesList = [];

    //  Can move downwards
    for (int i = row + 1; i < 8; i++) {
      if (board[i][col] == emptyCellPower) {
        validMovesList.add(CellPosition(row: i, col: col));
      } else if ((board[row][col] > 0 && board[i][col] < 0) ||
          (board[row][col] < 0 && board[i][col] > 0)) {
        validMovesList.add(CellPosition(row: i, col: col));
        break;
      } else {
        break;
      }
    }

    //  Can move upwards
    for (int i = row - 1; i > -1; i--) {
      if (board[i][col] == emptyCellPower) {
        validMovesList.add(CellPosition(row: i, col: col));
      } else if ((board[row][col] > 0 && board[i][col] < 0) ||
          (board[row][col] < 0 && board[i][col] > 0)) {
        validMovesList.add(CellPosition(row: i, col: col));
        break;
      } else {
        break;
      }
    }

    //  Can move Rightwards
    for (int j = col + 1; j < 8; j++) {
      if (board[row][j] == emptyCellPower) {
        validMovesList.add(CellPosition(row: row, col: j));
      } else if ((board[row][col] > 0 && board[row][j] < 0) ||
          (board[row][col] < 0 && board[row][j] > 0)) {
        validMovesList.add(CellPosition(row: row, col: j));
        break;
      } else {
        break;
      }
    }

    // Can move Rightwards
    for (int j = col - 1; j > -1; j--) {
      if (board[row][j] == emptyCellPower) {
        validMovesList.add(CellPosition(row: row, col: j));
      } else if ((board[row][col] > 0 && board[row][j] < 0) ||
          (board[row][col] < 0 && board[row][j] > 0)) {
        validMovesList.add(CellPosition(row: row, col: j));
        break;
      } else {
        break;
      }
    }
    List<CellPosition> validMovesAfterCheckMateCheck = [];
    for (int inx = 0; inx < validMovesList.length; inx++) {
      MovesModel move = MovesModel(
          currentPosition: currPosition,
          targetPosition: CellPosition(
              row: validMovesList[inx].row, col: validMovesList[inx].col));
      if (!checkMateCheckIfThisMovePerformed(board, move, boardViewIsWhite)) {
        validMovesAfterCheckMateCheck.add(validMovesList[inx]);
      }
    }
    return validMovesAfterCheckMateCheck;
  }

  static List<CellPosition> getValidBishopMoves(
      List<List<int>> board, CellPosition currPosition, bool boardViewIsWhite) {
    List<CellPosition> validMovesList = [];
    int row = currPosition.row;
    int col = currPosition.col;
    //South East Check
    int seI = row;
    int seJ = col;
    while (seI + 1 < 8 && seJ + 1 < 8) {
      if (board[seI + 1][seJ + 1] == emptyCellPower) {
        validMovesList.add(CellPosition(row: seI + 1, col: seJ + 1));
      } else if ((board[row][col] > 0 && board[seI + 1][seJ + 1] < 0) ||
          (board[row][col] < 0 && board[seI + 1][seJ + 1] > 0)) {
        validMovesList.add(CellPosition(row: seI + 1, col: seJ + 1));
        break;
      } else {
        break;
      }
      seI += 1;
      seJ += 1;
    }

    // North East Check
    int neI = row;
    int neJ = col;
    while (neI - 1 > -1 && neJ + 1 < 8) {
      if (board[neI - 1][neJ + 1] == emptyCellPower) {
        validMovesList.add(CellPosition(row: neI - 1, col: neJ + 1));
      } else if ((board[row][col] > 0 && board[neI - 1][neJ + 1] < 0) ||
          (board[row][col] < 0 && board[neI - 1][neJ + 1] > 0)) {
        validMovesList.add(CellPosition(row: neI - 1, col: neJ + 1));
        break;
      } else {
        break;
      }
      neI -= 1;
      neJ += 1;
    }

    // North West check
    int nwI = row;
    int nwJ = col;
    while (nwI - 1 > -1 && nwJ - 1 > -1) {
      if (board[nwI - 1][nwJ - 1] == emptyCellPower) {
        validMovesList.add(CellPosition(row: nwI - 1, col: nwJ - 1));
      } else if ((board[row][col] > 0 && board[nwI - 1][nwJ - 1] < 0) ||
          (board[row][col] < 0 && board[nwI - 1][nwJ - 1] > 0)) {
        validMovesList.add(CellPosition(row: nwI - 1, col: nwJ - 1));
        break;
      } else {
        break;
      }
      nwI -= 1;
      nwJ -= 1;
    }

    // South West check
    int swI = row;
    int swJ = col;
    while (swI + 1 < 8 && swJ - 1 > -1) {
      if (board[swI + 1][swJ - 1] == emptyCellPower) {
        validMovesList.add(CellPosition(row: swI + 1, col: swJ - 1));
      } else if ((board[row][col] > 0 && board[swI + 1][swJ - 1] < 0) ||
          (board[row][col] < 0 && board[swI + 1][swJ - 1] > 0)) {
        validMovesList.add(CellPosition(row: swI + 1, col: swJ - 1));
        break;
      } else {
        break;
      }
      swI += 1;
      swJ -= 1;
    }

    List<CellPosition> validMovesAfterCheckMateCheck = [];
    for (int inx = 0; inx < validMovesList.length; inx++) {
      MovesModel move = MovesModel(
          currentPosition: currPosition,
          targetPosition: CellPosition(
              row: validMovesList[inx].row, col: validMovesList[inx].col));

      if (!checkMateCheckIfThisMovePerformed(board, move, boardViewIsWhite)) {
        validMovesAfterCheckMateCheck.add(validMovesList[inx]);
      }
    }
    return validMovesAfterCheckMateCheck;
  }

  static List<CellPosition> getValidQueenMoves(
      List<List<int>> board, CellPosition currPosition, bool boardViewIsWhite) {
    var rookMoves = getValidRookMoves(board, currPosition, boardViewIsWhite);
    var bishopMoves =
        getValidBishopMoves(board, currPosition, boardViewIsWhite);

    return bishopMoves + rookMoves;
  }

  static List<CellPosition> getValidKingMove(
      List<List<int>> board,
      CellPosition currPosition,
      bool boardViewIsWhite,
      List<MovesLogModel> movelogs) {
    List<CellPosition> validMovesList = [];
    int row = currPosition.row;
    int col = currPosition.col;
    //South Check
    if (row + 1 < 8 &&
        ((board[row + 1][col] == emptyCellPower) ||
            (board[row][col] > 0 && board[row + 1][col] < 0) ||
            (board[row][col] < 0 && board[row + 1][col] > 0))) {
      validMovesList.add(CellPosition(row: row + 1, col: col));
    }
    //North Check
    if (row - 1 > -1 &&
        ((board[row - 1][col] == emptyCellPower) ||
            (board[row][col] > 0 && board[row - 1][col] < 0) ||
            (board[row][col] < 0 && board[row - 1][col] > 0))) {
      validMovesList.add(CellPosition(row: row - 1, col: col));
    }
    //East Check
    if (col + 1 < 8 &&
        ((board[row][col + 1] == emptyCellPower) ||
            (board[row][col] > 0 && board[row][col + 1] < 0) ||
            (board[row][col] < 0 && board[row][col + 1] > 0))) {
      validMovesList.add(CellPosition(row: row, col: col + 1));
    }
    //West Check
    if (col - 1 > -1 &&
        ((board[row][col - 1] == emptyCellPower) ||
            (board[row][col] > 0 && board[row][col - 1] < 0) ||
            (board[row][col] < 0 && board[row][col - 1] > 0))) {
      validMovesList.add(CellPosition(row: row, col: col - 1));
    }

    //North East Check
    if ((row - 1 > -1 && col + 1 < 8) &&
        ((board[row - 1][col + 1] == emptyCellPower) ||
            (board[row][col] > 0 && board[row - 1][col + 1] < 0) ||
            (board[row][col] < 0 && board[row - 1][col + 1] > 0))) {
      validMovesList.add(CellPosition(row: row - 1, col: col + 1));
    }
    //South East Check
    if ((row + 1 < 8 && col + 1 < 8) &&
        ((board[row + 1][col + 1] == emptyCellPower) ||
            (board[row][col] > 0 && board[row + 1][col + 1] < 0) ||
            (board[row][col] < 0 && board[row + 1][col + 1] > 0))) {
      validMovesList.add(CellPosition(row: row + 1, col: col + 1));
    }

    //North west check
    if ((row - 1 > -1 && col - 1 > -1) &&
        ((board[row - 1][col - 1] == emptyCellPower) ||
            (board[row][col] > 0 && board[row - 1][col - 1] < 0) ||
            (board[row][col] < 0 && board[row - 1][col - 1] > 0))) {
      validMovesList.add(CellPosition(row: row - 1, col: col - 1));
    }

    //South west check
    if ((row + 1 < 8 && col - 1 > -1) &&
        ((board[row + 1][col - 1] == emptyCellPower) ||
            (board[row][col] > 0 && board[row + 1][col - 1] < 0) ||
            (board[row][col] < 0 && board[row + 1][col - 1] > 0))) {
      validMovesList.add(CellPosition(row: row + 1, col: col - 1));
    }

    List<CellPosition> castlingPos =
        getValidCastlingPos(board, currPosition, boardViewIsWhite, movelogs);

    validMovesList.addAll(castlingPos);

    List<CellPosition> validMovesAfterCheckMateCheck = [];
    for (int inx = 0; inx < validMovesList.length; inx++) {
      MovesModel move = MovesModel(
          currentPosition: currPosition,
          targetPosition: CellPosition(
              row: validMovesList[inx].row, col: validMovesList[inx].col));

      if (!checkMateCheckIfThisMovePerformed(board, move, boardViewIsWhite)) {
        validMovesAfterCheckMateCheck.add(validMovesList[inx]);
      }
    }

    return validMovesAfterCheckMateCheck;
  }

  static List<CellPosition> getValidCastlingPos(
      List<List<int>> currBoard,
      CellPosition currPosition,
      bool boardViewIsWhite,
      List<MovesLogModel> movelogs) {
    int currKingPower = currBoard[currPosition.row][currPosition.col];
    int currRookPower = currKingPower > 0 ? rookPower : -rookPower;
    CellPosition firstRookPos = CellPosition(row: 0, col: 0);
    CellPosition secondRookPos = CellPosition(row: 0, col: 7);
    bool isFirstRookEligible = true;
    bool isSecondRookEligible = true;
    if ((boardViewIsWhite && currKingPower > 0) ||
        (!boardViewIsWhite && currKingPower < 0)) {
      firstRookPos = CellPosition(row: 7, col: 0);
      secondRookPos = CellPosition(row: 7, col: 7);
    } else {
      firstRookPos = CellPosition(row: 0, col: 0);
      secondRookPos = CellPosition(row: 0, col: 7);
    }
    if (currBoard[firstRookPos.row][firstRookPos.col] != currRookPower) {
      // First Rook moved
      isFirstRookEligible = false;
    }
    if (currBoard[secondRookPos.row][secondRookPos.col] != currRookPower) {
      // Second Rook moved
      isSecondRookEligible = false;
    }
    for (var log in movelogs) {
      if (log.piece == currKingPower) {
        //King moved
        return [];
      }
      if (log.piece == currRookPower) {
        //Rook moved
        if ((log.move.currentPosition.row == firstRookPos.row &&
            log.move.currentPosition.col == firstRookPos.col)) {
          //First Rook moved
          isFirstRookEligible = false;
        } else if ((log.move.currentPosition.row == secondRookPos.row &&
            log.move.currentPosition.col == secondRookPos.col)) {
          //Second Rook moved
          isSecondRookEligible = false;
        }
      }
    }
    int firstCol = 1;
    while (firstCol < currPosition.col) {
      if (currBoard[firstRookPos.row][firstCol] != emptyCellPower) {
        isFirstRookEligible = false;
        break;
      }
      firstCol += 1;
    }
    int secondCol = 6;
    while (secondCol > currPosition.col) {
      if (currBoard[firstRookPos.row][secondCol] != emptyCellPower) {
        isSecondRookEligible = false;
        break;
      }
      secondCol -= 1;
    }
    List<CellPosition> eligiblePos = [];
    if (isFirstRookEligible && currPosition.col - 2 > -1) {
      eligiblePos
          .add(CellPosition(row: currPosition.row, col: currPosition.col - 2));
    }
    if (isSecondRookEligible && currPosition.col + 2 < 8) {
      eligiblePos
          .add(CellPosition(row: currPosition.row, col: currPosition.col + 2));
    }
    return eligiblePos;
  }

  static List<CellPosition> getValidPawnMove(
      List<List<int>> board, CellPosition currPosition, bool boardViewIsWhite) {
    List<CellPosition> validMovesList = [];
    int row = currPosition.row;
    int col = currPosition.col;
    // Can go two steps, If in start position
    if (row == 1 || row == 6) {
      if (row - 2 > -1 &&
          board[row - 2][col] == emptyCellPower &&
          board[row - 1][col] == emptyCellPower) {
        validMovesList.add(CellPosition(row: row - 2, col: col));
      }
      if (row + 2 < 8 &&
          board[row + 2][col] == emptyCellPower &&
          board[row + 1][col] == emptyCellPower) {
        validMovesList.add(CellPosition(row: row + 2, col: col));
      }
    }

    //Can move One steps
    if (row + 1 < 8 && board[row + 1][col] == emptyCellPower) {
      validMovesList.add(CellPosition(row: row + 1, col: col));
    }
    if (row - 1 > -1 && board[row - 1][col] == emptyCellPower) {
      validMovesList.add(CellPosition(row: row - 1, col: col));
    }

    //Can kill diagnolly
    //North East Check
    if (col + 1 < 8 && row - 1 > -1) {
      if ((board[row][col] > 0 && board[row - 1][col + 1] < 0) ||
          (board[row][col] < 0 && board[row - 1][col + 1] > 0)) {
        validMovesList.add(CellPosition(row: row - 1, col: col + 1));
      }
    }
    //South East check
    if (col + 1 < 8 && row + 1 < 8) {
      if ((board[row][col] > 0 && board[row + 1][col + 1] < 0) ||
          (board[row][col] < 0 && board[row + 1][col + 1] > 0)) {
        validMovesList.add(CellPosition(row: row + 1, col: col + 1));
      }
    }

    //North East Check
    if (col - 1 > -1 && row + 1 < 8) {
      if ((board[row][col] > 0 && board[row + 1][col - 1] < 0) ||
          (board[row][col] < 0 && board[row + 1][col - 1] > 0)) {
        validMovesList.add(CellPosition(row: row + 1, col: col - 1));
      }
    }

    //North West check
    if (col - 1 > -1 && row - 1 > -1) {
      if ((board[row][col] > 0 && board[row - 1][col - 1] < 0) ||
          (board[row][col] < 0 && board[row - 1][col - 1] > 0)) {
        validMovesList.add(CellPosition(row: row - 1, col: col - 1));
      }
    }

    //Filtering Pawn Moves
    List<CellPosition> filteredPawnMoves = [];
    if ((boardViewIsWhite && board[row][col] > 0) ||
        (!boardViewIsWhite && board[row][col] < 0)) {
      for (var ele in validMovesList) {
        if (ele.row < row) {
          filteredPawnMoves.add(ele);
        }
      }
    } else {
      for (var ele in validMovesList) {
        if (ele.row > row) {
          filteredPawnMoves.add(ele);
        }
      }
    }

    List<CellPosition> validMovesAfterCheckMateCheck = [];
    for (int inx = 0; inx < filteredPawnMoves.length; inx++) {
      MovesModel move = MovesModel(
        currentPosition: currPosition,
        targetPosition: CellPosition(
            row: filteredPawnMoves[inx].row, col: filteredPawnMoves[inx].col),
      );

      if (!checkMateCheckIfThisMovePerformed(board, move, boardViewIsWhite)) {
        validMovesAfterCheckMateCheck.add(filteredPawnMoves[inx]);
      }
    }
    return validMovesAfterCheckMateCheck;
  }

  static bool checkMateCheckIfThisMovePerformed(
      List<List<int>> board, MovesModel moves, bool boardViewIsWhite) {
    try {
      bool checkForWhite =
          board[moves.currentPosition.row][moves.currentPosition.col] > 0;
      // Moving the piece
      int pieceInTarget =
          board[moves.targetPosition.row][moves.targetPosition.col];
      board[moves.targetPosition.row][moves.targetPosition.col] =
          board[moves.currentPosition.row][moves.currentPosition.col];
      board[moves.currentPosition.row][moves.currentPosition.col] =
          emptyCellPower;
      bool res =
          checkMateCheckForThisBoard(board, checkForWhite, boardViewIsWhite);

      // Undoing the move
      board[moves.currentPosition.row][moves.currentPosition.col] =
          board[moves.targetPosition.row][moves.targetPosition.col];
      board[moves.targetPosition.row][moves.targetPosition.col] = pieceInTarget;
      return res;
    } catch (ex) {
      return false;
    }
  }

  static bool checkMateCheckForThisBoard(
      List<List<int>> board, bool checkForWhite, bool boardViewIsWhite) {
    int row = 0;
    int col = 0;
    for (int i = 0; i < 8; i++) {
      for (int j = 0; j < 8; j++) {
        if (board[i][j].abs() == kingPower) {
          if (checkForWhite && board[i][j] > 0) {
            row = i;
            col = j;
            break;
          } else if (!checkForWhite && board[i][j] < 0) {
            row = i;
            col = j;
            break;
          }
        }
      }
    }

    int oppositeRook = checkForWhite ? -rookPower : rookPower;
    int oppositeQueen = checkForWhite ? -queenPower : queenPower;
    int oppositeBishop = checkForWhite ? -bishopPower : bishopPower;
    int oppositeHorse = checkForWhite ? -horsePower : horsePower;
    int oppositePawn = checkForWhite ? -pawnPower : pawnPower;
    int oppositeKing = checkForWhite ? -kingPower : kingPower;

    //East Check
    int eRow = row;
    int eCol = col + 1;
    while (eCol < 8) {
      if (board[eRow][eCol] != emptyCellPower) {
        if ((board[row][col] > 0 && board[eRow][eCol] < 0) ||
            (board[row][col] < 0 && board[eRow][eCol] > 0)) {
          //Check opposite king, If it is in 1 square
          if (eCol == col + 1 && board[eRow][eCol] == oppositeKing) {
            return true;
          }

          //Queen & Rook Check
          if (board[eRow][eCol] == oppositeRook ||
              board[eRow][eCol] == oppositeQueen) {
            return true;
          } else {
            //Contains Enemy piece which is not a threat, Hence breaking.
            break;
          }
        } else {
          // The Box is not empty and contain same team piece, So Not possible of check hence breaking.
          break;
        }
      }
      eCol += 1;
    }
    //West Check
    int wRow = row;
    int wCol = col - 1;
    while (wCol > -1) {
      if (board[wRow][wCol] != emptyCellPower) {
        if ((board[row][col] > 0 && board[wRow][wCol] < 0) ||
            (board[row][col] < 0 && board[wRow][wCol] > 0)) {
          //Check opposite king, If it is in 1 square
          if (wCol == col - 1 && board[wRow][wCol] == oppositeKing) {
            return true;
          }
          //Queen & Rook Check
          if (board[wRow][wCol] == oppositeRook ||
              board[wRow][wCol] == oppositeQueen) {
            return true;
          } else {
            //Contains Enemy piece which is not a threat, Hence breaking.
            break;
          }
        } else {
          // The Box is not empty and contain same team piece, So Not possible of check hence breaking.
          break;
        }
      }
      wCol -= 1;
    }

    //North Check
    int nRow = row - 1;
    int nCol = col;

    while (nRow > -1) {
      if (board[nRow][nCol] != emptyCellPower) {
        if ((board[row][col] > 0 && board[nRow][nCol] < 0) ||
            (board[row][col] < 0 && board[nRow][nCol] > 0)) {
          //Check opposite king, If it is in 1 square
          if (nRow == row - 1 && board[nRow][nCol] == oppositeKing) {
            return true;
          }
          //Queen & Rook Check
          if (board[nRow][nCol] == oppositeRook ||
              board[nRow][nCol] == oppositeQueen) {
            return true;
          } else {
            //Contains Enemy piece which is not a threat, Hence breaking.
            break;
          }
        } else {
          // The Box is not empty and contain same team piece, So Not possible of check hence breaking.
          break;
        }
      }
      nRow -= 1;
    }
    //South Check
    int sRow = row + 1;
    int sCol = col;
    while (sRow < 8) {
      if (board[sRow][sCol] != emptyCellPower) {
        if ((board[row][col] > 0 && board[sRow][sCol] < 0) ||
            (board[row][col] < 0 && board[sRow][sCol] > 0)) {
          //Check opposite king, If it is in 1 square
          if (sRow == row + 1 && board[sRow][sCol] == oppositeKing) {
            return true;
          }
          //Queen & Rook Check
          if (board[sRow][sCol] == oppositeRook ||
              board[sRow][sCol] == oppositeQueen) {
            return true;
          } else {
            //Contains Enemy piece which is not a threat, Hence breaking.
            break;
          }
        } else {  
          // The Box is not empty and contain same team piece, So Not possible of check hence breaking.
          break;
        }
      }
      sRow += 1;
    }

    //North East Check
    int neRow = row - 1;
    int neCol = col + 1;
    while (neRow > -1 && neCol < 8) {
      if (board[neRow][neCol] != emptyCellPower) {
        if ((board[row][col] > 0 && board[neRow][neCol] < 0) ||
            (board[row][col] < 0 && board[neRow][neCol] > 0)) {
          if (neRow == row - 1 && neCol == col + 1) {
            //Check opposite king, If it is in 1 square
            if (board[neRow][neCol] == oppositeKing) {
              return true;
            }
            //Check opposite Pawn, If it is in 1 square Diagnol
            if ((boardViewIsWhite && checkForWhite) ||
                (!boardViewIsWhite && !checkForWhite)) {
              if (board[neRow][neCol] == oppositePawn) {
                return true;
              }
            }
          }

          //Queen & Bishop Check
          if (board[neRow][neCol] == oppositeBishop ||
              board[neRow][neCol] == oppositeQueen) {
            return true;
          } else {
            //Contains Enemy piece which is not a threat, Hence breaking.
            break;
          }
        } else {
          // The Box is not empty and contain same team piece, So Not possible of check hence breaking.
          break;
        }
      }
      neRow -= 1;
      neCol += 1;
    }

    //South East Check
    int seRow = row + 1;
    int seCol = col + 1;
    while (seRow < 8 && seCol < 8) {
      if (board[seRow][seCol] != emptyCellPower) {
        if ((board[row][col] > 0 && board[seRow][seCol] < 0) ||
            (board[row][col] < 0 && board[seRow][seCol] > 0)) {
          if (seRow == row + 1 && seCol == col + 1) {
            //Check opposite king, If it is in 1 square
            if (board[seRow][seCol] == oppositeKing) {
              return true;
            }
            //Check opposite Pawn, If it is in 1 square Diagnol
            if ((!boardViewIsWhite && checkForWhite) ||
                (boardViewIsWhite && !checkForWhite)) {
              if (board[seRow][seCol] == oppositePawn) {
                return true;
              }
            }
          }
          //Queen & Bishop Check
          if (board[seRow][seCol] == oppositeBishop ||
              board[seRow][seCol] == oppositeQueen) {
            return true;
          } else {
            //Contains Enemy piece which is not a threat, Hence breaking.
            break;
          }
        } else {
          // The Box is not empty and contain same team piece, So Not possible of check hence breaking.
          break;
        }
      }
      seRow += 1;
      seCol += 1;
    }
    //South West Check
    int swRow = row + 1;
    int swCol = col - 1;
    while (swRow < 8 && swCol > -1) {
      if (board[swRow][swCol] != emptyCellPower) {
        if ((board[row][col] > 0 && board[swRow][swCol] < 0) ||
            (board[row][col] < 0 && board[swRow][swCol] > 0)) {
          if (swRow == row + 1 && swCol == col - 1) {
            //Check opposite king, If it is in 1 square
            if (board[swRow][swCol] == oppositeKing) {
              return true;
            }
            //Check opposite Pawn, If it is in 1 square Diagnol
            if ((!boardViewIsWhite && checkForWhite) ||
                (boardViewIsWhite && !checkForWhite)) {
              if (board[swRow][swCol] == oppositePawn) {
                return true;
              }
            }
          }
          //Queen & Bishop Check
          if (board[swRow][swCol] == oppositeBishop ||
              board[swRow][swCol] == oppositeQueen) {
            return true;
          } else {
            //Contains Enemy piece which is not a threat, Hence breaking.
            break;
          }
        } else {
          // The Box is not empty and contain same team piece, So Not possible of check hence breaking.
          break;
        }
      }
      swRow += 1;
      swCol -= 1;
    }
    //North West Check
    int nwRow = row - 1;
    int nwCol = col - 1;
    while (nwRow > -1 && nwCol > -1) {
      if (board[nwRow][nwCol] != emptyCellPower) {
        if ((board[row][col] > 0 && board[nwRow][nwCol] < 0) ||
            (board[row][col] < 0 && board[nwRow][nwCol] > 0)) {
          if (nwRow == row - 1 && nwCol == col - 1) {
            //Check opposite king, If it is in 1 square

            if (board[nwRow][nwCol] == oppositeKing) {
              return true;
            }
            //Check opposite Pawn, If it is in 1 square Diagnol
            if ((boardViewIsWhite && checkForWhite) ||
                (!boardViewIsWhite && !checkForWhite)) {
              if (board[nwRow][nwCol] == oppositePawn) {
                return true;
              }
            }
          }
          //Queen & Bishop Check
          if (board[nwRow][nwCol] == oppositeBishop ||
              board[nwRow][nwCol] == oppositeQueen) {
            return true;
          } else {
            //Contains Enemy piece which is not a threat, Hence breaking.
            break;
          }
        } else {
          // The Box is not empty and contain same team piece, So Not possible of check hence breaking.
          break;
        }
      }
      nwRow -= 1;
      nwCol -= 1;
    }

    //Horse check

    // 2Up 1 Left
    if (row - 2 > -1 && col - 1 > -1) {
      if (board[row - 2][col - 1] == oppositeHorse) {
        return true;
      }
    }
    // 2Up 1 Right
    if (row - 2 > -1 && col + 1 < 8) {
      if (board[row - 2][col + 1] == oppositeHorse) {
        return true;
      }
    }

    //2 Right 1 Up
    if (row - 1 > -1 && col + 2 < 8) {
      if (board[row - 1][col + 2] == oppositeHorse) {
        return true;
      }
    }
    //2 Right 1 down
    if (row + 1 < 8 && col + 2 < 8) {
      if (board[row + 1][col + 2] == oppositeHorse) {
        return true;
      }
    }

    //2 Down 1 Right
    if (row + 2 < 8 && col + 1 < 8) {
      if (board[row + 2][col + 1] == oppositeHorse) {
        return true;
      }
    }
    //2 Down 1 left
    if (row + 2 < 8 && col - 1 > -1) {
      if (board[row + 2][col - 1] == oppositeHorse) {
        return true;
      }
    }

    //2 Left 1 Up
    if (row - 1 > -1 && col - 2 > -1) {
      if (board[row - 1][col - 2] == oppositeHorse) {
        return true;
      }
    }
    if (row + 1 < 8 && col - 2 > -1) {
      if (board[row + 1][col - 2] == oppositeHorse) {
        return true;
      }
    }
    return false;
  }
}
