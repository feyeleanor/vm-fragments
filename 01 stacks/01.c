#include <stdio.h>
#include <stdlib.h>
#define STACK_MAX 100

typedef enum {
	STACK_OK = 0,
	STACK_OVERFLOW,
	STACK_UNDERFLOW
} STACK_STATUS;

typedef struct stack STACK;
struct stack {
	int data[STACK_MAX];
	int size;
};

STACK *NewStack() {
	STACK *s;
  s = malloc(sizeof(STACK));
	s->size = 0;
	return s;
}

STACK_STATUS push(STACK *s, int data) {
	if (s->size < STACK_MAX) {
		s->data[s->size++] = data;
		return STACK_OK;
	}
	return STACK_OVERFLOW;
}

STACK_STATUS pop(STACK *s, int *r) {
	if (s->size > 0) {
		*r = s->data[s->size - 1];
		s->size--;
		return STACK_OK;
	}
	return STACK_UNDERFLOW;
}

int depth(STACK *s) {
  return s->size;
}

int main() {
	int l, r;
	STACK *s = NewStack();
	push(s, 1);
	push(s, 3);
	printf("depth = %d\n", depth(s));
	pop(s, &l);
	pop(s, &r);
	printf("%d + %d = %d\n", l, r, l + r);
	printf("depth = %d\n", depth(s));
}
