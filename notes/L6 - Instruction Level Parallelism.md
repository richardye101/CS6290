## If all inst execute in the same cycle
![[Obsidian-Attachments/Screenshot 2026-01-28 at 6.51.18 PM.png]]
- would be great if all instructions could execute at the same time, and take 5 cycles for every instructions
- can't, because subsequent instructions would depend on previous results, which won't have been written until the end

## Execute stage
![[Obsidian-Attachments/Screenshot 2026-01-28 at 6.55.06 PM.png]]
- forwarding values will feed values to the instructions that need it before it's written to registers
	- this doesn't solve the problem because we would've needed the values to go back in time
![[Obsidian-Attachments/Screenshot 2026-01-28 at 6.55.56 PM.png]]
- must stall I2 and wait for I1, the rest of the instructions can still execute
- results in 2 cycles to execute 5 instructions = 2/5 = 0.4

## Read after Write dependencies
![[Obsidian-Attachments/Screenshot 2026-01-28 at 6.57.28 PM.png]]
- a CPU that can execute any number of instructions per cycle still has raw dependencies
![[Obsidian-Attachments/Screenshot 2026-01-28 at 6.57.52 PM.png]]
- if we have dependencies across every instruction, it'll result in CPI=1

## Write after write Dependencies
![[Obsidian-Attachments/Screenshot 2026-01-28 at 7.00.33 PM.png]]
- R4 will get written to by I2 last, which is the wrong order; I5 should have written to it last
![[Obsidian-Attachments/Screenshot 2026-01-28 at 7.03.03 PM.png]]
- to fix it, we don't write in I5, stall, and write after cycle 8

## Dependency
![[Obsidian-Attachments/Screenshot 2026-01-28 at 7.05.28 PM.png]]
- ADD: 3, 5
- MUL: 2, 4
- ADD: 4, 6 (needs to wait for I2 to finish EXE, which is C4)
- MUL: 2, 4
- ADD: 5, 7 (needs to wait for I4)
![[Obsidian-Attachments/Screenshot 2026-01-28 at 7.08.23 PM.png]]

## Removing False Dependencies
![[Obsidian-Attachments/Screenshot 2026-01-28 at 7.09.43 PM.png]]
- can do it by duplciated register values
![[Obsidian-Attachments/Screenshot 2026-01-28 at 7.12.51 PM.png]]
- store all possible values of a register
- instruction that wants to read it must search all versions of the register, and pick the one produced the latest

- can also rename registers
![[Obsidian-Attachments/Screenshot 2026-01-28 at 7.15.56 PM.png]]
- separates architectural registers and physical registers
- RAT: register allocation table
	- used to say which physical register contains the value for which architectural register

## RAT Example
![[Obsidian-Attachments/Screenshot 2026-01-28 at 7.17.07 PM.png]]
- put the result somewhere else, say P17
![[Obsidian-Attachments/Screenshot 2026-01-28 at 7.19.11 PM.png]]
- the register renaming helps so if the same register R4 is going to be written by two separate instructions:
	- the first one writes to a different physical register, and subsequent instructions that read it will use that physical register value
	- the second one writes to another different register, so if it completes first, the subsequent instructions will refer it's value, instead of the original R4 register.

### Quiz
![[Obsidian-Attachments/Screenshot 2026-01-28 at 7.24.20 PM.png]]
Renamed
- ADD R8, R1, R7
- MUL R9, R4, R4
- ADD R10, R3, R9
- MUL R11, R6, R6
- ADD R12, R5, R11

RAT
P1: R8
P2: R7 -> R9 -> R11
P3: R10
P4: 
P5: R12
P6: 
![[Obsidian-Attachments/Screenshot 2026-01-28 at 7.27.14 PM.png]]

## False Dependencies after renaming
![[Obsidian-Attachments/Screenshot 2026-01-28 at 7.31.04 PM.png]]
- true dependencies persist
- no more anti-dependency (WAR), no more output dependency (WAW)
- we can process all instructions here in 2 cycles:  CPI = 2/6 = 0.33, or IPC = 6/2 = 3

## Instruction Level Parallelism
![[Obsidian-Attachments/Screenshot 2026-01-28 at 7.35.28 PM.png]]
- ILP = IPC when:
	- processor can do an entire instruction in 1 cycle
	- processor can do any number of instructions in the same cycle, while obeying true dependencies
- to compute ILP:
	- rename registers
	- execute and count number of cycles
- ILP is a property of a program, not the processor

![[Obsidian-Attachments/Screenshot 2026-01-28 at 7.37.39 PM.png]]
- already renamed registers, this computes the true dependencies
- only 2 dependencies, go through to calculate ILP
- ILP = # Inst/# Cycles

### Quiz
![[Obsidian-Attachments/Screenshot 2026-01-28 at 7.38.11 PM.png]]
- I1
- I2 depends on I1
- I3 depends on I1, I2
- I4
- I5 depends on ~~I4~~ I3
- I6 depends on I1
- I7 ~~depends on I5~~
4 cycles for 7 instructions => 7/4 = ILP of 1.75
![[Obsidian-Attachments/Screenshot 2026-01-28 at 7.42.11 PM.png]]

## ILP w/ Structural & Control Dependencies
![[Obsidian-Attachments/Screenshot 2026-01-28 at 7.45.38 PM.png]]
- no structural dependencies (don't have enogh hardware to do things in the same cycle)
	- assume ideal hardware, no structural dependencies
- control dependencies: assume perfect same-cycle branch prediction (even though a branch might not be resolved till later, we assume we already know the right path, and as long as there aren't data dependencies, it can be executed in Cycle 1)

## ILP != IPC on real processors

- 2 issues (2 inst per cycle)
- can execute instructions out of order
- 1 MUL, 2 ADD/SUB/XOR units available to use
![[Obsidian-Attachments/Screenshot 2026-01-28 at 7.49.52 PM.png]]
- ILP can be calculated without considering processor limitations
	- As far as calculating ILP, can do this in 2 cycles => 5/2=2.5
![[Obsidian-Attachments/Screenshot 2026-01-28 at 7.50.13 PM.png]]
- IPC is calculated wrong here, 2 issue CPU means we only do 2 instructions on Cycle 1, 2 on Cycle 2, and then finally 1 on Cycle 3
	- Means IPC = 5/3 = 1.67
![[Obsidian-Attachments/Screenshot 2026-01-28 at 7.54.57 PM.png]]
- ILP >= IPC always
	- because ILP assumes a perfect processor with unlimited processing parallelism

### Quiz
![[Obsidian-Attachments/Screenshot 2026-01-28 at 7.56.26 PM.png]]
- ILP = 6/2 = 3
C1
C1
C2
C1
C2
C1
- IPC = 6/3 = 2
C1
C1
__ \ C2
__ \ C2 Bc in-order processor, cannot execute this if the prev wasn't
__ \ __ \ C3
__ \ __ \ C3

![[Obsidian-Attachments/Screenshot 2026-01-28 at 8.02.18 PM.png]]

## Discussion
![[Obsidian-Attachments/Screenshot 2026-01-28 at 8.04.35 PM.png]]
- the further down we go, the closer IPC will get to ILP. need wide issue, out of order execution on the processor, as well as fetching/executing many inst per cycle, elimination of false deps, and reordering of inst