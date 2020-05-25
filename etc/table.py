from stats import d

def code(x):
    return x.get('code', 0) + x.get('compiletimecode', 0)

def spec(x):
    return x.get('spec', 0)

def proof(x):
    return x.get('proof', 0) + x.get('loopinv', 0)

def obvious(x):
    return x.get('obvious', 0) + x.get('workaround', 0) + x.get('bitvector', 0) + x.get('lemma', 0) + x.get('symex', 0)

def unrelated(x):
    return x.get('unrelated', 0) + x.get('UNTAGGED', 0)

def boilerplate(x):
    return x.get('importboilerplate', 0) + x.get('administrivia', 0)

library = d["coqutil"]["UNTAGGED"]
for k in d:
    library += d[k].get("library", 0)

kami = d["kami"]["UNTAGGED"]

unrel = 0
for k in d:
    if k == 'riscv-coq': continue # TODO
    if k == 'kami': continue
    if k == 'coqutil': continue
    unrel += unrelated(d[k])

boilerp = 0
for k in d:
    boilerp += boilerplate(d[k])

doc = 0
for k in d:
    doc += d[k].get('doc', 0)

with open('loc_excluded.tex', 'w') as f1:
    def line(what, v):
        f1.write(f'  {what:10s} & {v:5d} \\\\ \\hline \n')
    line('unrelated', unrel)
    line('imports', boilerp)
    line('doc', doc)
    line('Kami', kami)

with open('loc.tex', 'w') as f2:
    def line(what):
        overh =      (spec(d[what]) + proof(d[what]) + obvious(d[what])) * 100.0 / code(d[what])
        idealOverh = (spec(d[what]) + proof(d[what])                   ) * 100.0 / code(d[what])
        f2.write(f'{what:20s} & {code(d[what]):4d} & {spec(d[what]):4d} & {proof(d[what]):4d} & {obvious(d[what]):4d} &   {overh:6.0f} &   {idealOverh:6.0f} \\\\ \\hline\n')
    f2.write('                     % code & spec &   pf & obvi & overhead &    ideal \\\\\n')
    line('lightbulb app')
    line('program logic')
    line('compiler')
    f2.write('SW/HW interface      & todo & todo & todo & todo &     todo &     todo \\\\ \\hline\n') # TODO merge riscv-coq and bedrock2/processor directory
    line('end-to-end')
    f2.write(f'Missing libraries    &  \\NA &  \\NA &  \\NA & {library:4d} &      \\NA &      \\NA \\\\ \\hline\n')
    f2.write('Total                & todo & todo & todo & todo &     todo &     todo \\\\ \\hline\n')