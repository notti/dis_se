package mp

import (
    "fmt"
    "errors"
    "os"
)

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

const (
        NOT_FIXED = iota
        MEM_FIXED
        TERM_FIXED
)

type Argument struct {
    Id int
    Name string
    Signed bool
    Fix int
    Type int
    Membase int
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

func (f *MPFunction) AddArgument(signed bool, fix int, t int, membase int, id string) bool {
    if _, ok := f.Id2Variable[id]; ok {
        return false
    }
    arg := Argument{f.NewVariable(), id, signed, fix, t, membase}
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
    f.Variables = append(f.Variables, mem)
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

type place struct {
    fixed int
    assigned bool
    id int
}

type pstage struct {
    vars [6]place
    used map[int]int
    pointer int
}

func (p *pstage) add(i int) (int, bool) {
    for ; p.pointer < 6; p.pointer++ {
        if p.vars[p.pointer].assigned {
            continue
        }
        p.vars[p.pointer].id = i
        p.vars[p.pointer].assigned = true
        p.used[i] = p.pointer
        return p.pointer, true
    }
    return 0, false
}

func (p *pstage) place(i int) (int, bool) {
    if i < 0 {
        return i, true
    }
    id, ok := p.used[i]
    return id, ok
}

func (p *pstage) contains(i int) bool {
    _, ok := p.place(i)
    return ok
}

func (p *pstage) num() int {
    return len(p.used)
}

func (p *pstage) setFixed(i, how int) bool {
    id, ok := p.used[i]
    if ok {
        p.vars[id].fixed = how
        return true
    }
    return false
}

func (p *pstage) unFix(i int) {
    id, ok := p.used[i]
    if ok && p.vars[id].fixed != MEM_FIXED {
        p.vars[id].fixed = NOT_FIXED
    }
}

func (p *pstage) addFixed(i, how int) (int, bool) {
    id, ok := p.add(i)
    if ok == false {
        return 0, false
    }
    p.vars[p.pointer].fixed = how
    return id, true
}

func (p *pstage) copyFixed(o *pstage) {
    for i, val := range o.vars {
        if val.fixed != NOT_FIXED {
            p.vars[i].fixed = val.fixed
            p.vars[i].assigned = true
            p.vars[i].id = val.id
            p.used[val.id] = i
        }
    }
}

func (p *pstage) String() string {
    ret := ""
    for i, val := range p.vars {
        if val.assigned {
            ret += fmt.Sprintf("%d", val.id)
            switch val.fixed {
            case MEM_FIXED:
                ret += "M"
            case TERM_FIXED:
                ret += "T"
            default:
                ret += " "
            }
        } else {
            ret += "X "
        }
        if i<5 {
            ret += " "
        }
    }
    return ret
}

func newpstage() pstage {
    x := pstage{}
    x.used = make(map[int]int)
    return x
}

type pipeline struct {
    var0 pstage //before indirect
    var1 pstage //after indirect
    s1op []Term
    var2 pstage //after stage1
    s2op []Term
    var3 pstage //after stage2
    s3op []Term
    var4 pstage //after stage3
}

func (p *pipeline) String() string {
    ret := ""
    ret += p.var0.String() + "\n"
    ret += p.var1.String() + "\n"
    ret += fmt.Sprint(p.s1op) + "\n"
    ret += p.var2.String() + "\n"
    ret += fmt.Sprint(p.s2op) + "\n"
    ret += p.var3.String() + "\n"
    ret += fmt.Sprint(p.s3op) + "\n"
    ret += p.var4.String()
    return ret
}

func (f MPFunction) Emit() ([]Argument, error) {
    if len(f.Terms) > 6 {
        return f.Args, errors.New("too many Terms")
    }
    fmt.Fprintln(os.Stderr, f.Args)
    fmt.Fprintln(os.Stderr, f.Terms)
    fmt.Fprintln(os.Stderr, f.Out)
    fmt.Fprintln(os.Stderr, "-------------------")
    p := pipeline{newpstage(), newpstage(),
        make([]Term, 0, 2), newpstage(),
        make([]Term, 0 ,2), newpstage(),
        make([]Term, 0, 2), newpstage()}
    var arg_type, arg_memchunk, arg_val, arg_assign, mem_fetch, mem_memchunk [6]int
    var wb, wb_memchunk, wb_bitrev, wb_assign [6]int

///// decode_fetch
    for _, a := range f.Args {
        if i, ok := p.var0.add(a.Id); ok == false {
            return f.Args, errors.New("too many arguments")
        } else {
            arg_type[i] = a.Type
            arg_memchunk[i] = a.Membase
        }
    }
///// indirect_fetch
    //Stuff we need to read from memory (needs to come first -> HW!)
    for _, x := range f.Variables {
        if mem, ok := x.(RMemory); ok {
            if i, ok := p.var1.add(mem.Id); ok == false {
                return f.Args, errors.New("too many memory reads")
            } else {
                mem_fetch[i] = 1
                mem_memchunk[i] = mem.Base
                arg_assign[i] = mem.Addr
                arg_val[i] = 0
            }
        }
    }
    //Stuff we need to write out in the end (also needs to come first -> HW!)
    checked := false
    for _, x := range f.Out {
        if arg, ok := f.Variables[x.Id].(Argument); ok {
            if p.var1.setFixed(arg.Id, MEM_FIXED) {
                continue
            }
            if checked == false {
                if p.var1.num() > 0 {
                    //check if variables already stored get written
                    for used, _ := range p.var1.used {
                        found := false
                        for _, out := range f.Out {
                            if out.Id == used {
                                found = true
                                p.var1.setFixed(out.Id, MEM_FIXED)
                                break
                            }
                        }
                        if found == false {
                            return f.Args, errors.New("Read/Write combination not possible")
                        }
                    }
                }
                checked = true
            }
            if i, ok := p.var1.addFixed(arg.Id, MEM_FIXED); ok == false {
                return f.Args, errors.New("too many memory reads")
            } else {
                arg_assign[i] = arg.Id
                arg_val[i] = 1
            }
        }
    }
    //Finally input Values
    for _, x := range f.Terms {
        if x.A >=0 {
            if arg, ok := f.Variables[x.A].(Argument); ok {
                if i, ok := p.var1.add(arg.Id); ok == false {
                    return f.Args, errors.New("too many variables after fetch!")
                } else {
                    arg_assign[i] = arg.Id
                    arg_val[i] = 1
                }
            }
        }
        if x.B >=0 {
            if arg, ok := f.Variables[x.B].(Argument); ok {
                if i, ok := p.var1.add(arg.Id); ok == false {
                    return f.Args, errors.New("too many variables after fetch!")
                } else {
                    arg_assign[i] = arg.Id
                    arg_val[i] = 1
                }
            }
        }
    }
///// stage1
    for i:= 0; i < len(f.Terms); i++ {
        if f.Terms[i].Op == ALU_MUL {
            p.s1op = append(p.s1op, f.Terms[i])
            f.Terms = append(f.Terms[:i], f.Terms[i+1:]...)
            i--
        }
    }
    if len(p.s1op) > 2 {
        return f.Args, errors.New("too many complex ops!")
    }
    if len(f.Terms) > 4 {
        //assign non complex ops if we have lot's of stuff todo
        for i:= 0; i < len(f.Terms) && len(p.s1op) < 2; i++ {
            if f.Terms[i].Op != ALU_RSHIFT &&
                p.var1.contains(f.Terms[i].A) && p.var1.contains(f.Terms[i].B) {
                    //prefer ops with dependent values
                    for _, op := range f.Terms {
                        if f.Terms[i].C == op.A || f.Terms[i].C == op.B {
                            p.s1op = append(p.s1op, f.Terms[i])
                            f.Terms = append(f.Terms[:i], f.Terms[i+1:]...)
                            i--
                            break
                        }
                    }
            }
        }
        if len(f.Terms) > 4 {
            //now do random rest
            for i:= 0; i < len(f.Terms) && len(p.s1op) < 2; i++ {
                if f.Terms[i].Op != ALU_RSHIFT &&
                    p.var1.contains(f.Terms[i].A) && p.var1.contains(f.Terms[i].B) {
                    p.s1op = append(p.s1op, f.Terms[i])
                    f.Terms = append(f.Terms[:i], f.Terms[i+1:]...)
                    i--
                }
            }
        }
    }
    if len(f.Terms) > 4 {
        return f.Args, errors.New("too many simple ops or impossible variable combination for stage1!")
    }
    for _, op := range f.Terms {
        p.var1.setFixed(op.A, TERM_FIXED)
        p.var1.setFixed(op.B, TERM_FIXED)
    }
    for _, out := range f.Out {
        p.var1.setFixed(out.Id, MEM_FIXED)
        if !p.var0.contains(out.Addr) {
            p.var1.setFixed(out.Addr, MEM_FIXED)
        }
    }
    p.var2.copyFixed(&p.var1)
    for i, op := range p.s1op {
        if id, ok := p.var1.place(op.A); ok {
            p.s1op[i].A = id
        } else {
            return f.Args, errors.New("impossible variable combination in stage1")
        }
        if id, ok := p.var1.place(op.B); ok {
            p.s1op[i].B = id
        } else {
            return f.Args, errors.New("impossible variable combination in stage1")
        }
        if id, ok := p.var2.add(op.C); ok {
            p.s1op[i].C = id
        } else {
            return f.Args, errors.New("impossible variable combination in stage1")
        }
    }
///// stage2
    if len(f.Terms) > 0 {
        for i:= 0; i < len(f.Terms) && len(p.s2op) < 2; i++ {
            if p.var2.contains(f.Terms[i].A) && p.var2.contains(f.Terms[i].B) {
                //prefer ops with dependent values
                for _, op := range f.Terms {
                    if f.Terms[i].C == op.A || f.Terms[i].C == op.B {
                        p.var2.unFix(f.Terms[i].A)
                        p.var2.unFix(f.Terms[i].B)
                        p.s2op = append(p.s2op, f.Terms[i])
                        f.Terms = append(f.Terms[:i], f.Terms[i+1:]...)
                        i--
                        break
                    }
                }
            }
        }
        if len(p.s2op) < 2 && len(f.Terms) > 0 {
            //now do random rest
            for i:= 0; i < len(f.Terms) && len(p.s2op) < 2; i++ {
                if p.var2.contains(f.Terms[i].A) && p.var2.contains(f.Terms[i].B) {
                    p.var2.unFix(f.Terms[i].A)
                    p.var2.unFix(f.Terms[i].B)
                    p.s2op = append(p.s2op, f.Terms[i])
                    f.Terms = append(f.Terms[:i], f.Terms[i+1:]...)
                    i--
                }
            }
        }
    }
    if len(f.Terms) > 2 {
        return f.Args, errors.New("too many simple ops or impossible variable combination for stage 2!")
    }
    for _, op := range f.Terms {
        p.var2.setFixed(op.A, TERM_FIXED)
        p.var2.setFixed(op.B, TERM_FIXED)
    }
    for _, out := range f.Out {
        p.var2.setFixed(out.Id, MEM_FIXED)
        if !p.var0.contains(out.Addr) {
            p.var2.setFixed(out.Addr, MEM_FIXED)
        }
    }
    p.var3.copyFixed(&p.var2)
    for i, op := range p.s2op {
        if id, ok := p.var2.place(op.A); ok {
            p.s2op[i].A = id
        } else {
            return f.Args, errors.New("impossible variable combination in stage2")
        }
        if id, ok := p.var2.place(op.B); ok {
            p.s2op[i].B = id
        } else {
            return f.Args, errors.New("impossible variable combination in stage2")
        }
        if id, ok := p.var3.add(op.C); ok {
            p.s2op[i].C = id
        } else {
            return f.Args, errors.New("impossible variable combination in stage2")
        }
    }
///// stage3
    if len(f.Terms) > 0 {
        for i:= 0; i < len(f.Terms) && len(p.s3op) < 2; i++ {
            if p.var3.contains(f.Terms[i].A) && p.var3.contains(f.Terms[i].B) {
                p.var3.unFix(f.Terms[i].A)
                p.var3.unFix(f.Terms[i].B)
                p.s3op = append(p.s3op, f.Terms[i])
                f.Terms = append(f.Terms[:i], f.Terms[i+1:]...)
                i--
            }
        }
    }
    if len(f.Terms) > 0 {
        return f.Args, errors.New("too many simple ops or impossible variable combination for stage 3!")
    }
    for _, out := range f.Out {
        p.var3.setFixed(out.Id, MEM_FIXED)
        if !p.var0.contains(out.Addr) {
            p.var3.setFixed(out.Addr, MEM_FIXED)
        }
    }
    p.var4.copyFixed(&p.var3)
    for i, op := range p.s3op {
        if id, ok := p.var3.place(op.A); ok {
            p.s3op[i].A = id
        } else {
            return f.Args, errors.New("impossible variable combination in stage1")
        }
        if id, ok := p.var3.place(op.B); ok {
            p.s3op[i].B = id
        } else {
            return f.Args, errors.New("impossible variable combination in stage1")
        }
        if id, ok := p.var4.add(op.C); ok {
            p.s3op[i].C = id
        } else {
            return f.Args, errors.New("impossible variable combination in stage1")
        }
    }
///// writeback
    for i, out := range f.Out {
        wb[i] = 1
        wb_memchunk[i] = out.Base
        wb_bitrev[i] = out.Rev
        if id, ok := p.var0.place(out.Addr); ok {
            wb_assign[i] = id
        } else if id, ok := p.var4.place(out.Addr); ok {
            wb_assign[i] = id | 8
        } else {
            return f.Args, errors.New("impossible address assignment in writeback")
        }

    }

    fmt.Fprintln(os.Stderr, &p)
    fmt.Fprintln(os.Stderr, "-------------------")
    fmt.Fprintln(os.Stderr, arg_type)
    fmt.Fprintln(os.Stderr, arg_memchunk)
    fmt.Fprintln(os.Stderr, arg_assign)
    fmt.Fprintln(os.Stderr, arg_val)
    fmt.Fprintln(os.Stderr, mem_fetch)
    fmt.Fprintln(os.Stderr, mem_memchunk)
    fmt.Fprintln(os.Stderr, p.s1op)
    fmt.Fprintln(os.Stderr, p.s2op)
    fmt.Fprintln(os.Stderr, p.s3op)
    fmt.Fprintln(os.Stderr, wb)
    fmt.Fprintln(os.Stderr, wb_memchunk)
    fmt.Fprintln(os.Stderr, wb_bitrev)
    fmt.Fprintln(os.Stderr, wb_assign)
    return f.Args, nil
}

