package main

import "fmt"
import "os"

type S []int

type StackMachine struct {
	S
	VM
}

func (s *StackMachine) String() string {
	return fmt.Sprintf("%v, %v", s.VM, s.S)
}

func (s *StackMachine) Push() {
	s.PC++
	s.S = append(s.S, s.read_program().(int))
}

func (s *StackMachine) Add() {
	s.S[len(s.S) - 2] += s.S[len(s.S) - 1]
	s.S = s.S[:len(s.S) - 1]
}

func (s *StackMachine) JumpIfNotZero() {
	s.PC++
	if s.S[len(s.S) - 1] != 0 {
		s.PC = s.m[s.PC].(int)
	}
}

func main() {
	s := new(StackMachine)
	print_state := func() {
		fmt.Println(s)
	}
	skip := func() { s.PC++ }
	s.Load(
		s.Push, 13,
		Label("decrement"),
		func() { s.S = append(s.S, -1) },
		s.Add,
		print_state,
		skip,
		print_state,
		s.JumpIfNotZero, Label("decrement"),
		print_state,
		func() { os.Exit(0) },
	).Run()
}