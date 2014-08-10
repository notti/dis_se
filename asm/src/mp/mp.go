package mp

const (
        ARG_NONE = iota
        ARG_REG
        ARG_MEM
        ARG_IMM
)

const (
        _ = iota
        ALUIN_0 = -iota
        ALUIN_1
)

const (
        ALU_BOTH = iota - 1
        ALU_SIMPLE
        ALU_COMPLEX
)

const (
        CALU_NOOP = iota
        CALU_ADD
        CALU_SUB
        CALU_UMUL
        CALU_SMUL
        CALU_AND
        CALU_OR
        CALU_XOR
)

const (
        SALU_NOOP = iota
        SALU_ADD
        SALU_SUB
        SALU_SAR
        SALU_SLR
        SALU_AND
        SALU_OR
        SALU_XOR
)

const (
        ALU_NOOP = iota
        ALU_ADD
        ALU_SUB
        ALU_MUL
        ALU_RSHIFT
        ALU_AND
        ALU_OR
        ALU_XOR
)

type Argument struct {
    Id int
    Name string
    Signed bool
    Fix int
    Type int
}

type Register struct {
    Id int
    Signed bool
    Fix int
}

type RMemory struct {
    Id int
    Base int
    Addr int
}

type WMemory struct {
    Id int
    Base int
    Addr int
    Rev int
}

type Term struct {
    A int
    B int
    Op int
    Signed bool
    Fix int
    C int
}

type MPFunction struct {
    Args []Argument
    Terms []Term
    Variables []interface{}
    Id2Variable map[string]int
    Out []WMemory
}

func NewMPFunction() MPFunction {
    return MPFunction{make([]Argument, 0, 6), make([]Term, 0, 6), make([]interface{}, 0, 12), make(map[string]int), make([]WMemory, 0, 5)}
}

func (f *MPFunction) NewVariable() int {
    return len(f.Variables)
}

func (f *MPFunction) AddArgument(signed bool, fix int, t int, id string) bool {
    if _, ok := f.Id2Variable[id]; ok {
        return false
    }
    arg := Argument{f.NewVariable(), id, signed, fix, t}
    f.Args = append(f.Args, arg)
    f.Variables = append(f.Variables, arg)
    f.Id2Variable[id] = arg.Id
    return true
}

func (f *MPFunction) AddRegister(signed bool, fix int) int {
    reg := Register{f.NewVariable(), signed, fix}
    f.Variables = append(f.Variables, reg)
    return reg.Id
}

func (f *MPFunction) AddNamedRegister(name string, id int) {
    f.Id2Variable[name] = id
}

func (f *MPFunction) GetNamedRegister(id string) (int, bool, int, bool) {
    regid, ok := f.Id2Variable[id]
    if ok == false {
        return 0, false, 0, false
    }
    switch reg := f.Variables[regid].(type) {
    default:
        return 0, false, 0, false
    case Register:
        return regid, reg.Signed, reg.Fix, true
    case Argument:
        return regid, reg.Signed, reg.Fix, true
    }
}

func (f *MPFunction) AddRMemory(base int, addr string) (int, bool) {
    v, ok := f.Id2Variable[addr]
    if ok == false {
        return 0, false
    }
    for id, x := range f.Variables {
        if mem, ok := x.(RMemory); ok {
            if mem.Base == base && mem.Addr == v {
                return id, true
            }
        }
    }
    mem := RMemory{f.NewVariable(), base, v}
    return mem.Id, true
}

func (f *MPFunction) AddWMemory(base int, rev int, addr string, id int) (bool, bool) {
    v, ok := f.Id2Variable[addr]
    if ok == false {
        return false, false
    }
    for _, x := range f.Variables {
        if mem, ok := x.(WMemory); ok {
            if mem.Base == base && mem.Addr == v && mem.Rev == rev {
                return true, false
            }
        }
    }
    f.Out = append(f.Out, WMemory{id, base, v, rev})
    return true, true
}

func (f *MPFunction) AddTerm(a, b, op int, signed bool, fix, c int) {
    f.Terms = append(f.Terms, Term{a, b, op, signed, fix, c})
}

/* end of leftvar: allocate variable (ev. mark as final in table)
   fill ops from behind
   fill variables from behind
   check for leftovers
*/
