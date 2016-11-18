package main

import "fmt"

type Label string
type labels map[Label] int

type VM struct {
	PC		int
	m		[]interface{}
	labels
}

func (v *VM) read_program() interface{} {
	return v.m[v.PC]
}

func (v *VM) String() string {
	return fmt.Sprintf("@pc[%v] => #{%v}, %v", v.PC, v.m[v.PC])
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

func (v *VM) Load(program ...interface{}) *VM {
	v.labels = make(labels)
	v.PC = -1
	for _, token := range program {
		v.assemble(token)
	}
	return v
}

func (v *VM) Run() {
	v.PC = -1
	for {
		v.PC++
		v.read_program().(func())()
	}
}