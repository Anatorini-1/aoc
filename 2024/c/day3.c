
#include <stdio.h>
#include <stdlib.h>

int execute(char *a, char *b);

int main(int argc, char *argv[]) {
  FILE *f;
  f = fopen(argv[1], "r");

  char line_buffer[5000];
  char operand_buffer_1[4];
  char operand_buffer_2[4];
  char c;

  int total = 0;

  int pos;
  int operand_index_1;
  int operand_index_2;

  enum {
    OPT,
    OPENING_BRACKET,
    OPERAND_1,
    COLON,
    OPERAND_2,
    CLOSING_BRACKET,
  };

  enum {
    ON,
    OFF,
  };
  int state = OPT;
  int enabled = ON;

  while (fgets(line_buffer, 5000, f)) {
    pos = 0;
    operand_index_1 = 0;
    operand_index_2 = 0;

    while (pos < 4990) {
      c = line_buffer[pos];

      if (c == '\0') {
        break;
      }
      if (line_buffer[pos] == 'd' && line_buffer[pos + 1] == 'o' &&
          line_buffer[pos + 2] == 'n' && line_buffer[pos + 3] == 39 &&
          line_buffer[pos + 4] == 't' && line_buffer[pos + 5] == '(' &&
          line_buffer[pos + 6] == ')') {
        enabled = OFF;
        pos++;
        continue;
      }
      if (line_buffer[pos] == 'd' && line_buffer[pos + 1] == 'o' &&
          line_buffer[pos + 2] == '(' && line_buffer[pos + 3] == ')') {
        enabled = ON;
        pos++;
        continue;
      }
      if (enabled == OFF) {
        pos++;
        continue;
      }
      switch (state) {
      case OPT:
        operand_index_1 = 0;
        operand_index_2 = 0;
        if (line_buffer[pos] == 'm' && line_buffer[pos + 1] == 'u' &&
            line_buffer[pos + 2] == 'l' && line_buffer[pos + 3] == '(') {
          state = OPERAND_1;
          pos += 3;
        }
        break;
      case OPERAND_1:
        if (c >= '0' && c <= '9') {
          operand_buffer_1[operand_index_1] = c;
          operand_buffer_1[operand_index_1 + 1] = '\0';
          operand_index_1++;
          if (operand_index_1 == 3) {
            state = COLON;
          }
        } else if (c == ',' && operand_index_1 > 0) {
          state = OPERAND_2;
        } else {
          state = OPT;
          pos--;
        }
        break;
      case COLON:
        if (c == ',') {
          state = OPERAND_2;
        } else {
          state = OPT;
        }
        break;
      case OPERAND_2:
        if (c >= '0' && c <= '9') {
          operand_buffer_2[operand_index_2] = c;
          operand_buffer_2[operand_index_2 + 1] = '\0';
          operand_index_2++;
          if (operand_index_2 == 3) {
            state = CLOSING_BRACKET;
          }
        } else if (c == ')' && operand_index_2 > 0) {
          total += execute(operand_buffer_1, operand_buffer_2);
          state = OPT;
        } else {
          state = OPT;
        }
        break;
      case CLOSING_BRACKET:
        if (c == ')') {
          total += execute(operand_buffer_1, operand_buffer_2);
          state = OPT;
        } else {
          state = OPT;
        }
        break;
      }
      pos++;
    }
  }
  printf("%d\n", total);
  return 0;
}
int execute(char *a, char *b) {
  printf("mul(%s,%s)\n", a, b);
  return atoi(a) * atoi(b);
}
