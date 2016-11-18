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

type VM struct {
	S			*stack
	l, r, PC	int
	m			[]interface{}
	labels		map[string] int
}

func (v *VM) read_program() interface{} {
	return v.m[v.PC]
}

func (v *VM) String() string {
	return fmt.Sprintf("@pc[%v] => #{%v}, %v", v.PC, v.m[v.PC], v.S)
}

func (v *VM) Run() {
	v.labels = make(map[string] int)
	for {
		switch t := v.read_program().(type) {
		case func():
			t()
		case string:
			v.labels[t] = v.PC
		}
		v.PC++
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
	if i.S.data == 0 {
		i.PC++
	} else {
		i.PC++
		switch t := i.m[i.PC].(type) {
		case int:
			i.PC = t - 1
		case string:
			i.m[i.PC] = i.labels[t]
			i.PC = i.m[i.PC].(int)
		}
	}
}

func main() {
	i := new(Interpreter)
	i.m = []interface{}{
		i.Push, 13,
		"decrement",
		func() { i.S = i.S.Push(-1) },
		i.Add,
		func() { fmt.Println(i) },
		func() { i.PC++ },
		func() { fmt.Println(i) },
		i.JumpIfNotZero, "decrement",
		func() { fmt.Println(i) },
		func() { os.Exit(0) },
	}
	i.Run()
}