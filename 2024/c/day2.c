#include <stdio.h>
#include <stdlib.h>

int part1(int *report, int size);
int part2(int *report, int size);

int main(int argc, char *argv[]) {
  if (argc < 2) {
    printf("Input file name missing");
    return -1;
  }

  FILE *fptr;
  fptr = fopen(argv[1], "r");

  if (fptr == NULL) {
    printf("Failed to open file %s", argv[1]);
    return -1;
  }

  const int MAX_LINE = 200;
  const int MAX_REPORTS = 10;
  const int MAX_NUMBER_SIZE = 20;

  char line_buffer[MAX_LINE];
  char number_buffer[MAX_NUMBER_SIZE];

  int pos;
  int number_pos;
  int report_index;
  int reports[MAX_REPORTS];
  int safe_reports = 0;
  while (fgets(line_buffer, MAX_LINE, fptr)) {
    pos = 0;
    number_pos = 0;
    report_index = 0;

    while (pos < MAX_LINE) {
      if (line_buffer[pos] == '\0') {
        break;
      }
      if (line_buffer[pos] >= '0' && line_buffer[pos] <= '9') {
        if (number_pos >= MAX_NUMBER_SIZE) {
          printf("Number to large for buffer size. Aborting");
          return -1;
        }
        number_buffer[number_pos] = line_buffer[pos];
        number_pos++;
      } else {
        if (report_index >= MAX_REPORTS) {
          printf("To many reports for buffer. Aborting");
          return -1;
        }
        number_buffer[number_pos] = '\0';
        reports[report_index] = atoi(number_buffer);
        report_index++;
        number_pos = 0;
      }
      pos++;
    }
    // safe_reports += part1(reports, report_index);
    safe_reports += part2(reports, report_index);
  }
  fclose(fptr);
  printf("%d\n", safe_reports);

  return 0;
}
int part1(int *report, int size) {
  if (size < 2) {
    return 1;
  } else {
    int rising = (report[1] - report[0]) > 0;
    int good = 1;
    int diff;
    for (int i = 1; i < size; i++) {
      diff = report[i] - report[i - 1];
      if (diff == 0) {
        return 0;
      } else if (diff > 0) {
        if (!rising) {
          return 0;
        }
        if (diff > 3) {
          return 0;
        }
      } else {
        if (rising) {
          return 0;
        }
        if (diff < -3) {
          return 0;
        }
      }
    }
  }
  return 1;
}
int part2(int *report, int size) {
  int good = part1(report, size);
  if (good) {
    return 1;
  }
  int *report2 = (int *)malloc(sizeof(int) * size);
  for (int skip = 0; skip < size; skip++) {
    int index = 0;
    for (int i = 0; i < size; i++) {
      if (i == skip)
        continue;
      report2[index] = report[i];
      index++;
    }
    good = part1(report2, size - 1);
    if (good) {
      free(report2);
      return 1;
    }
  }
  free(report2);
  return 0;
}
