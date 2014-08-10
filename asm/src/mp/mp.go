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
    C int
}

type MPFunction struct {
    Args []Argument
    Terms []Term
    Variables []interface{}
    Id2Variable map[string]int
}

func NewMPFunction() *MPFunction {
    return &MPFunction{make([]Argument, 0, 6), make([]Term, 0, 6), make([]interface{}, 0, 12), make(map[string]int)}
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

func (f *MPFunction) AddNamedRegister(signed bool, fix int, id string) int {
    reg := f.AddRegister(signed, fix)
    f.Id2Variable[id] = reg
    return reg
}

func (f *MPFunction) GetNamedVariable(id string) (int, bool) {
    reg, ok := f.Id2Variable[id]
    return reg, ok
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

func (f *MPFunction) AddWMemory(base int, rev int, addr string) (int, bool) {
    v, ok := f.Id2Variable[addr]
    if ok == false {
        return 0, false
    }
    for _, x := range f.Variables {
        if mem, ok := x.(WMemory); ok {
            if mem.Base == base && mem.Addr == v && mem.Rev == rev {
                return 0, false
            }
        }
    }
    mem := RMemory{f.NewVariable(), base, v}
    return mem.Id, true
}

func (f *MPFunction) AddTerm(a, b, op, c int) {
    f.Terms = append(f.Terms, Term{a, b, op, c})
}

/* end of leftvar: allocate variable (ev. mark as final in table)
   fill ops from behind
   fill variables from behind
   check for leftovers
*/
