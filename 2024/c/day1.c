#include <stdio.h>
#include <stdlib.h>

int find_min_index(int *arr, int size);
int count_duplicates(int *arr, int val, int size);
int part1(int *left, int *right, int rows);
int part2(int *left, int *right, int rows);

int main(int argc, char **argv) {
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
  char line_buffer[120];
  char number_buffer[30];

  int left[1005];
  int right[1005];

  int pos = 0;
  int line_pos = 0;
  int row = 0;
  while (fgets(line_buffer, 120, fptr)) {
    while (line_buffer[line_pos] >= '0' && line_buffer[line_pos] <= '9') {
      number_buffer[pos] = line_buffer[line_pos];
      pos++;
      line_pos++;
    }
    number_buffer[pos] = '\0';
    left[row] = atoi(number_buffer);
    while (line_buffer[line_pos] == ' ') {
      line_pos++;
    }

    pos = 0;
    while (line_buffer[line_pos] >= '0' && line_buffer[line_pos] <= '9') {
      number_buffer[pos] = line_buffer[line_pos];
      pos++;
      line_pos++;
    }
    number_buffer[pos] = '\0';
    right[row] = atoi(number_buffer);
    row++;
    line_pos = 0;
    pos = 0;
  }
  fclose(fptr);
  // int total_distance = part1(left, right, row);
  // printf("%d\n", total_distance);
  int similarity = part2(left, right, row);
  printf("%d\n", similarity);

  return 0;
}

int part1(int *left, int *right, int rows) {
  int entry = 0;
  int left_min;
  int right_min;
  int total_distance = 0;
  while (entry < rows) {
    left_min = find_min_index(left, rows);
    right_min = find_min_index(right, rows);
    int diff = left[left_min] - right[right_min];
    if (diff < 0) {
      diff *= -1;
    }
    total_distance += diff;
    left[left_min] = -1;
    right[right_min] = -1;
    entry++;
  }
  return total_distance;
}
int part2(int *left, int *right, int rows) {
  const int MAX_VALUE = 100000;
  int occurences[MAX_VALUE];
  for (int i = 0; i < MAX_VALUE; i++) {
    occurences[i] = -1;
  }

  for (int row = 0; row < rows; row++) {
    int value = left[row];
    if (value > MAX_VALUE) {
      printf("Overflow imminent. Aborting\n");
      return -1;
    }
    if (occurences[value] == -1) {
      occurences[value] = count_duplicates(right, value, rows);
    }
  }

  int rval = 0;
  for (int row = 0; row < rows; row++) {
    rval += left[row] * occurences[left[row]];
  }
  return rval;
}

int count_duplicates(int *arr, int val, int size) {
  int count = 0;
  for (int i = 0; i < size; i++) {
    if (arr[i] == val) {
      count++;
    }
  }
  return count;
}
int find_min_index(int *arr, int size) {
  int rval = -1;
  int current_min = 1 << 30;

  for (int i = 0; i < size; i++) {
    if (arr[i] == -1)
      continue;
    if (arr[i] < current_min) {
      current_min = arr[i];
      rval = i;
    }
  }
  return rval;
}
