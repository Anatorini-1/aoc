#include <stdio.h>
#include <stdlib.h>

struct rule {
  int X;
  int Y;
};
int inBuffer();

int inArr(int *haystack, int needle, int size) {
  for (int i = 0; i < size; i++) {
    if (haystack[i] == needle) {
      return 1;
    }
  }
  return 0;
}

int isValid(struct rule *rules, int rule_count, int *pages, int page_count,
            int *printed, int printed_count, int page) {
  for (int r = 0; r < rule_count; r++) {
    if (rules[r].Y == page) {
      if (inArr(pages, rules[r].X, page_count)) {
        if (inArr(printed, rules[r].X, printed_count) == 0) {
          return 0;
        }
      }
    }
  }
  return 1;
}

int main(int argc, char *argv[]) {
  FILE *f;
  const int MAX_LINE = 1024;
  enum read_state { rule, page };

  int state = rule;

  f = fopen(argv[1], "r");

  char *line_buffer = (char *)malloc(sizeof(char) * MAX_LINE);
  int line_buffer_index = 0;

  char *int_buffer = (char *)malloc(sizeof(char) * 5);
  int int_buffer_index = 0;

  int *pages = malloc(sizeof(int) * 100);
  int *printed = malloc(sizeof(int) * 100);
  int page_index = 0;
  int printed_index = 0;
  int result = 0;

  struct rule *rules = malloc(sizeof(rule) * 2048);
  struct rule *new_rule = 0;
  int rule_count = 0;

  while (fgets(line_buffer, MAX_LINE, f)) {
    switch (state) {
    case rule:
      if (line_buffer[0] == '\n') {
        state = page;
        continue;
      }
      int_buffer_index = 0;
      line_buffer_index = 0;
      while (line_buffer[line_buffer_index] != '|') {
        int_buffer[int_buffer_index++] = line_buffer[line_buffer_index++];
      }
      line_buffer_index++;
      int_buffer[int_buffer_index] = 0;
      new_rule = &rules[rule_count];
      rule_count++;
      new_rule->X = atoi(int_buffer);
      int_buffer_index = 0;

      while (line_buffer[line_buffer_index] != '\n') {
        int_buffer[int_buffer_index++] = line_buffer[line_buffer_index++];
      }
      line_buffer_index++;
      int_buffer[int_buffer_index] = 0;
      new_rule->Y = atoi(int_buffer);

      break;
    case page:
      if (line_buffer[0] == '\n') {
        continue;
      }
      line_buffer_index = 0;
      int_buffer_index = 0;
      page_index = 0;
      char c;
      int cond = 1;
      while (cond) {
        c = line_buffer[line_buffer_index];
        switch (c) {
        case ',':
          pages[page_index] = atoi(int_buffer);
          int_buffer_index = 0;
          page_index++;
          break;
        case '\n':
          pages[page_index] = atoi(int_buffer);
          int_buffer_index = 0;
          page_index++;
          cond = 0;
          break;
        default:
          int_buffer[int_buffer_index++] = c;
          int_buffer[int_buffer_index] = 0;
        }
        line_buffer_index++;
      }
      int good = 1;
      printed_index = 0;

      for (int i = 0; i < page_index; i++) {
        if (0 == isValid(rules, rule_count, pages, page_index, printed,
                         printed_index, pages[i])) {
          good = 0;
          break;
        } else {
          printed[printed_index] = pages[i];
          printed_index++;
        }
      }

      if (good) {
        result += pages[page_index / 2];
      } else {
      }
      break;
    }
  }
  printf("%d\n", result);
  return EXIT_SUCCESS;
}
