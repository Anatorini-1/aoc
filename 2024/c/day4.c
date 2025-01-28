#include <stdio.h>
#include <stdlib.h>
#include <string.h>

const int ROWS = 1000;
const int COLS = 1000;
const char text[] = "XMAS";
int test_part1(char **input, int row, int col, int dr, int dc) {
  for (int i = 0; i < 4; i++) {
    if (input[row + i * dr][col + i * dc] != text[i]) {
      return 0;
    }
  }
  return 1;
}

int part1(char **input, int row, int col) {
  int look_up = row - 3 >= 0;
  int look_down = row + 3 < ROWS;
  int look_left = col - 3 >= 0;
  int look_right = col + 3 < COLS;
  int total = 0;
  if (look_right) {
    total += test_part1(input, row, col, 0, 1);
    if (look_up) {
      total += test_part1(input, row, col, -1, 1);
    }
    if (look_down) {
      total += test_part1(input, row, col, 1, 1);
    }
  }
  if (look_left) {
    total += test_part1(input, row, col, 0, -1);
    if (look_up) {
      total += test_part1(input, row, col, -1, -1);
    }
    if (look_down) {
      total += test_part1(input, row, col, 1, -1);
    }
  }
  if (look_up) {
    total += test_part1(input, row, col, -1, 0);
  }
  if (look_down) {
    total += test_part1(input, row, col, 1, 0);
  }
  return total;
}

int test_part2(char **input, int row, int col, int horizontal, int vertical) {
  return 0;
}
int part2(char **input, int row, int col) {
  // printf("row %d col %d\n", row, col);
  if (row < 1 || row >= ROWS) {
    return 0;
  }
  if (col < 1 || col >= COLS) {
    return 0;
  }
  if (input[row - 1][col - 1] == 'M' && input[row + 1][col + 1] == 'S') {
    if (input[row + 1][col - 1] == 'M' && input[row - 1][col + 1] == 'S') {
      return 1;
    }
    if (input[row + 1][col - 1] == 'S' && input[row - 1][col + 1] == 'M') {
      return 1;
    }
  }
  if (input[row - 1][col - 1] == 'S' && input[row + 1][col + 1] == 'M') {
    if (input[row + 1][col - 1] == 'M' && input[row - 1][col + 1] == 'S') {
      return 1;
    }
    if (input[row + 1][col - 1] == 'S' && input[row - 1][col + 1] == 'M') {
      return 1;
    }
  }
  return 0;
}

int main(int argc, char *argv[]) {
  FILE *f;
  f = fopen(argv[1], "r");
  char line_buffer[COLS];
  char **input = (char **)malloc(sizeof(char **) * ROWS);
  for (int i = 0; i < ROWS; i++) {
    input[i] = (char *)malloc(sizeof(char) * COLS);
  }
  int lines = 0;
  while (fgets(line_buffer, COLS, f)) {
    memcpy(input[lines], line_buffer, COLS);
    lines++;
  }

  // Part 1
  int total = 0;
  int col = 0;
  for (int row = 0; row < lines; row++) {
    col = 0;
    while (input[row][col] != '\n' && col < COLS) {
      if (input[row][col] == 'X') {
        total += part1(input, row, col);
      }
      col++;
    }
  }
  printf("Part 1: %d\n", total);

  // Part 2
  total = 0;
  col = 0;
  for (int row = 0; row < lines; row++) {
    col = 0;
    while (input[row][col] != '\n' && col < COLS) {
      total += input[row][col] == 'A' && part2(input, row, col);
      col++;
    }
  }

  printf("Part 2: %d\n", total);

  for (int i = 0; i < ROWS; i++) {
    free(input[i]);
  }
  free(input);

  return 0;
}
