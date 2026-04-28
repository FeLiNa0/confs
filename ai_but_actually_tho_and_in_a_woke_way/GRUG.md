# grug brain developer

this collection of thoughts on software gathered by grug who work on this codebase

grug brain developer not so smart, but grug brain developer program many year and learn some things, although mostly still confused

apex predator of grug is complexity

complexity bad

say again:

complexity _very_ bad

_you_ say now:

complexity _very_, _very_ bad

---

## saying no

best weapon against complexity is magic word: "no"

"no, grug not build that feature yet"

"no, grug not add that abstraction"

"no, grug not keep that dead code for later"

"later" is lie complexity demon tell grug. dead code not come back to life. delete now.

---

## dead code

grug learn hard way: code planned for "v2" that live in v1 codebase is not planned — it is abandoned, just not honest about it yet

if code is not called by anything, delete it. when v2 actually come, write it then with full knowledge of what v2 actually need. not what grug imagine v2 need from v1.

twenty lines of map and matching function that nothing call is twenty lines of complexity demon living rent free in codebase

delete. when need, write again. grug brain can do this.

---

## comments must be true

lying comment worse than no comment

if comment say "~8 miles" and code produce 5 miles, comment is lie. complexity demon love lying comment because make grug trust wrong thing and debug in wrong place

if grug change code, grug change comment. if grug too lazy to update comment, delete comment. bare code better than lying comment.

---

## one instance of thing

if thing already exist, do not make second thing same as first thing

two `TokenReader` reading same file at same time: one is complexity demon wearing disguise

grug ask: who own this? put it there. everyone else ask that owner. done.

---

## import discipline

when grug delete block of code, grug check what imports that block was holding up

unused import is small complexity demon but many small demons make big demon

compiler usually help here. listen to compiler.

---

## scratch notes do not belong in commits

grug understand: debugging is hard, notes help in moment

but notes like `....rbenv install....` or `OR JUST: do this` in committed file are confusion for next grug who read it

scratch pad is scratch pad. commit is commit. do not mix.

---

## document the tools

grug spend half day figuring out how to install tool that one make target needs

this is failure of documentation, not failure of grug

if feature need new tool to test (desktop head unit, emulator, simulator, whatever), put install command in makefile or readme. future grug will be grateful. future grug is probably present grug in three months who forgot.

---

## factor code slowly

early in feature, grug resist urge to extract and abstract everything

let code get a little ugly first. shape of problem become clear over time. good cut points emerge. then extract.

grug who abstract too early get abstractions wrong and spend much time maintaining wrong abstractions.

grug who wait a little get to see real shape of problem and cut at natural joints.

---

## testing

grug love test that catch real bug. grug have complicated feelings about test that mostly test that grug wrote the code.

integration test at cut point (repository, api boundary, screen lifecycle) worth ten unit tests on private helper function

unit test fine too, especially early. but do not worship. test that must be rewritten every refactor is tax, not asset.

when bug found: reproduce with test first, then fix. this one always works better.

---

## logging

grug huge fan of logging, especially in device code where debugger is painful

log token status. log location result. log api response code and first 500 chars. log station count.

future grug on device with no debugger will thank present grug very much.

wrap in `DEBUG` guard so production build stays quiet.

---

## tools

grug love tool. tool make grug brain bigger than it actually is.

learn the tools. read the makefile. if makefile target missing for common task, add it. good makefile is gift to whole tribe.

---

## complexity conclusion

grug look at code before and after:

before: evse type map never called, two instances of same reader, wrong comment, scratch notes in readme, no dhu install target

after: none of that

same features. less code. less confusion. complexity demon slightly weakened.

this is victory.

_you_ say: complexity _very_, _very_ bad