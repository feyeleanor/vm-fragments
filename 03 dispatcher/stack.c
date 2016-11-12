#include <stdlib.h>

typedef struct stack STACK;
struct stack {
	int data;
	STACK *next;
};

STACK *push(STACK *s, int data) {
	STACK *r = malloc(sizeof(STACK));
	r->data = data;
	r->next = s;
	return r;
}

STACK *pop(STACK *s, int *r) {
	if (s == NULL)
		exit(1);
	*r = s->data;
	return s->next;
}

int depth(STACK *s) {
  int r = 0;
  for (STACK *t = s; t != NULL; t = t->next) {
    r++;
  }
  return r;
}