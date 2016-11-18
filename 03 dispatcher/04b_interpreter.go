package main

import "fmt"
import "strings"
import "os"

type stack struct {
	data int
	tail *stack
}

func (s *stack) Push(v int) (r *stack) {
	return &stack{data: v, tail: s}
}

func (s *stack) Pop() (v int, r *stack) {
	return s.data, s.tail
}

func (s *stack) String() string {
	r := []string{}
	for i := s; i != nil; i = i.tail {
		r = append(r, fmt.Sprint(i.data))
	}
	return "[" + strings.Join(r, ", ") + "]"
}

type Label string
type labels map[Label] int

type VM struct {
	S			*stack
	l, r, PC	int
	m			[]interface{}
	labels
}

func (v *VM) read_program() interface{} {
	return v.m[v.PC]
}

func (v *VM) String() string {
	return fmt.Sprintf("@pc[%v] => #{%v}, %v", v.PC, v.m[v.PC], v.S)
}

func (v *VM) assemble(token interface{}) {
	switch t := token.(type) {
	case Label:
		if i, ok := v.labels[t]; ok {
			v.m = append(v.m, i)
		} else {
			v.labels[t] = v.PC
		}
	default:
		v.m = append(v.m, token)
		v.PC++
	}
}

func (v *VM) Load(program ...interface{}) {
	v.labels = make(labels)
	v.PC = -1
	for _, token := range program {
		v.assemble(token)
	}
}

func (v *VM) Run() {
	v.PC = -1
	for {
		v.PC++
		v.read_program().(func())()
	}
}

type Interpreter struct { VM }

func (i *Interpreter) Push() {
	i.PC++
	i.S = i.S.Push(i.read_program().(int))
}

func (i *Interpreter) Add() {
	i.l, i.S = i.S.Pop()
	i.r, i.S = i.S.Pop()
	i.S = i.S.Push(i.l + i.r)
}

func (i *Interpreter) JumpIfNotZero() {
	i.PC++
	if i.S.data != 0 {
		i.PC = i.m[i.PC].(int)
	}
}

func main() {
	i := new(Interpreter)
	print_state := func() {
		fmt.Println(i)
	}
	skip := func() { i.PC++ }
	i.Load(
		i.Push, 13,
		Label("decrement"),
		func() { i.S = i.S.Push(-1) },
		i.Add,
		print_state,
		skip,
		print_state,
		i.JumpIfNotZero, Label("decrement"),
		print_state,
		func() { os.Exit(0) },
	)
	i.Run()
}