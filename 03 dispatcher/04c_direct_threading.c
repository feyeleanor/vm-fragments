#include <stdio.h>
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

typedef enum { PUSH = 0, ADD, PRINT, EXIT } opcodes;

#define COMPILE(body, ...) \
	COMPILER(__VA_ARGS__); \
	int words = sizeof(*c) / sizeof(*c[0]); \
	void **p = malloc(sizeof(void *) * words); \
	void **cp = p; \
	COMPILE_NEXT_OPCODE \
	body
#define COMPILER(...) \
	static void *c[] = { __VA_ARGS__ }
#define DESCRIBE_PRIMITIVE(name, body) \
	name: body; \
	COMPILE_NEXT_OPCODE
#define COMPILE_NEXT_OPCODE \
	if (words < 1) return p; \
	goto *c[*tokens++];
#define WRITE_OPCODE(value) \
	*cp++ = value; \
	words--;

void **compile(int *tokens, void *dispatch_table[]) {
	COMPILE(
		DESCRIBE_PRIMITIVE(push,
			WRITE_OPCODE(dispatch_table[PUSH])
			WRITE_OPCODE((void *)(long)*tokens++)
		)
		DESCRIBE_PRIMITIVE(add,
			WRITE_OPCODE(dispatch_table[ADD])
		)
		DESCRIBE_PRIMITIVE(print,
			WRITE_OPCODE(dispatch_table[PRINT])
		)
		DESCRIBE_PRIMITIVE(exit,
			WRITE_OPCODE(dispatch_table[EXIT])
		),
		&&push, &&add, &&print, &&exit
	)
}

#define INTERPRETER(body, ...) \
	DISPATCHER(__VA_ARGS__); \
	void **p = compile(PC, d); \
	if (p == NULL) \
		exit(1); \
	EXECUTE_OPCODE \
	body
#define DISPATCHER(...) \
	static void *d[] = { __VA_ARGS__ }
#define READ_OPCODE *p++
#define EXECUTE_OPCODE goto *READ_OPCODE;
#define PRIMITIVE(name, body) \
	name: body; \
	EXECUTE_OPCODE

void interpret(int *PC) {
	STACK *S;
	int l, r;
	INTERPRETER(
		PRIMITIVE(
			push, S = push(S, (int)(long)READ_OPCODE)
		)
		PRIMITIVE(add,
			S = pop(S, &l);
			S = pop(S, &r);
			S = push(S, l + r)
		)
		PRIMITIVE(print,
			printf("%d + %d = %d\n", l, r, S->data)
		)
		PRIMITIVE(exit,
			return
		),
		&&push, &&add, &&print, &&exit
	)
}

int main() {
	int program[] = {
		PUSH, 13,
		PUSH, 28,
		ADD,
		PRINT,
		EXIT
	};
	interpret(program);
}