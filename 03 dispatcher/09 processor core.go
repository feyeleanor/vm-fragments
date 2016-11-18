package main

import "fmt"

const PROCESSOR_READY = 0
const PROCESSOR_BUSY = 1
const CALL_STACK_UNDERFLOW = 2
const CALL_STACK_OVERFLOW = 4
const ILLEGAL_OPERATION = 8
const INVALID_ADDRESS = 16

const INVALID_OPCODE = -1

type Instruction []int

func (i Instruction) Opcode() int {
	if len(i) == 0 {
		return INVALID_OPCODE
	}
	return i[0]
}

func (i Instruction) Operands() []int {
	if len(i) < 2 {
		return []int{}
	}
	return i[1:]
}

func (i Instruction) Execute(op Operation) {
	op(i.Operands())
}

type Operation func(o []int)

type Executable interface {
	Opcode() int
	Operands() []int
	Execute(op Operation)
}

type Processor interface {
	Run(p []Executable)
}

type Core struct {
	Ticks     int
	Running   bool
	PC, Flags int
	CS        []int
	M         []int
	OP        Executable
}

func NewCore(CSSize, MSize int) Core {
	return Core{
		CS: make([]int, 0, Calls),
		M:  make([]int, MSize),
	}
}

func (p *Core) Reset() {
	p.Running = false
	p.Flags = PROCESSOR_READY
}

func (c *Core) RunExclusive(p []Executable, f func()) {
	defer func() {
		c.Running = false
		if x := recover(); x != nil {
			c.Flags &= x.(int)
		}
	}()

	if c.Running {
		panic(PROCESSOR_BUSY)
	}
	c.Running = true
	for c.PC = 0; c.Running; {
		c.LoadInstruction(p)
		f()
		c.Ticks++
	}
}

func (c *Core) LoadInstruction(program []Executable) {
	if c.PC >= len(program) {
		panic(PROCESSOR_READY)
	}
	c.OP = program[c.PC]
	c.PC++
}

func (c *Core) Goto(addr int) {
	c.PC = addr
}

func (c *Core) Call(addr int) {
	if top := len(c.CS); top < cap(c.CS)-1 {
		c.CS = c.CS[:top+1]
		c.CS[top] = c.PC
		c.PC = addr
	} else {
		panic(CALL_STACK_OVERFLOW)
	}
}

func (c *Core) TailCall(addr int) {
	c.CS[len(c.CS)-1] = c.PC
	c.PC = addr
}

func (c *Core) Return() {
	if top := len(c.CS); top > 0 {
		c.PC, c.CS = c.CS[top-1], c.CS[:top]
	} else {
		panic(CALL_STACK_UNDERFLOW)
	}
}

const (
	CALL = iota
	GOTO
	MOVE
	RETURN
)

func main() {
	c := NewCore(10, 8)
	p := []Executable{
		Instruction{CALL, 2},
		Instruction{GOTO, 5},
		Instruction{MOVE, 2},
		Instruction{RETURN},
		Instruction{MOVE, -1},
	}
	c.RunExclusive(p, func() {
		switch c.OP() {
		case CALL:
			c.Execute(func(o []int) { c.Call(o[0]) })
		case GOTO:
			c.Execute(func(o []int) { c.Goto(o[0]) })
		case MOVE:
			c.Execute(func(o []int) { c.Goto(c.PC + o[0]) })
		case RETURN:
			c.Execute(func(o []int) { c.Return() })
		default:
			panic(ILLEGAL_OPERATION)
		}
	})
	fmt.Println("Instructions Executed:", c.Ticks)
	fmt.Println("PC =", c.PC)
	if c.Flags|PROCESSOR_READY == PROCESSOR_READY {
		fmt.Println("Core Ready")
	} else {
		fmt.Println("Core Error:", c.Flags)
	}
}
