# Pipelining
![[Obsidian-Attachments/Screenshot 2026-01-18 at 2.23.11 PM.png]]
## Pipelining Quiz
![[Obsidian-Attachments/Screenshot 2026-01-18 at 2.23.53 PM.png]]
- no pipelining: 30 hours
- with pipelining: 12 hours
![[Obsidian-Attachments/Screenshot 2026-01-18 at 2.29.02 PM.png]]
## Instruction Pipeline Quiz
![[Obsidian-Attachments/Screenshot 2026-01-18 at 2.32.35 PM.png]]
- no pipelining: 50 cycles
- with pipelining: 5 + 9 = 14 cycles
![[Obsidian-Attachments/Screenshot 2026-01-18 at 2.33.59 PM.png]]

## Pipeline CPI is > 1
![[Obsidian-Attachments/Screenshot 2026-01-18 at 2.36.27 PM.png]]
- pipeline CPI (cycles per instruction) could get close to 1 if the number of instructions approach $\infty$ 
- in reality, we have pipeline stalls which cause gaps in the pipeline processing, increasing cycles taken per unit of intructions completed

## Processor Pipeline Stalls
![[Obsidian-Attachments/Screenshot 2026-01-18 at 2.41.22 PM.png]]
- if we have three dependent instructions, and the first one is supposed to produce a value the subsequent ones depend on, it could create a pipeline stall
- other instructions must wait for the value to be available in the registers, causing wasted cycles
![[Obsidian-Attachments/Screenshot 2026-01-18 at 2.51.31 PM.png]]
- with a JUMP instruction, it may be followed by other non related instructions, which must be cleared so that when the JUMP evaluates, the correct next instructino can be pulled in and executed in the correct order

## Control Dependencies
![[Obsidian-Attachments/Screenshot 2026-01-18 at 2.59.07 PM.png]]
- a lot of times, instructions rely on previous branch/jump instructions to tell it what the correct next instructions are.
- if 20% of instructions are branch/jump, and about 50% of those are "taken" (PC goes somewhere else and doesn't just continue)
- then 10% of instructions will have idle cycles following them
- if it takes 2 cycles to figure out where to go, that results in a CPI of $1+0.1 \cdot 2 = 1.2$

### Control Dependence Quiz
![[Obsidian-Attachments/Screenshot 2026-01-18 at 3.01.47 PM.png]]
- 25% are taken branch/jump
- figure out where in the 6th stage -> 5 idle stages
- $CPI = 1 + .25 \cdot 5 = 2.25$
![[Obsidian-Attachments/Screenshot 2026-01-18 at 3.03.03 PM.png]]
## Data Dependencies 
![[Obsidian-Attachments/Screenshot 2026-01-18 at 3.08.37 PM.png]]
- RAW: Read-After-Write dependence
	- AKA: Flow, True dependence
	- need to read R1 from ADD before using it in SUBTRACT
- WAW: Write-After-Write dependence
	- need to write R1 in ADD before R1 in MULTIPLY
- WAR: Write-After-Read
	- AKA: Anti-depedence
	- need to ensure we write R1 in MULITPLY after R1 is read in SUBTRACT

### Quiz
![[Obsidian-Attachments/Screenshot 2026-01-18 at 3.10.43 PM.png]]

- I1 -> I3: /--/--Yes
- I1 -> I4: /--/--/
	- no WAR because I4 is not writing to something I1 is reading
	- no WAW because I1 and I4 are writing to different registers, if I4 was writing to R1, it would be a WAW with I3
- I2 -> I3: /--Yes--/
![[Obsidian-Attachments/Screenshot 2026-01-18 at 3.16.00 PM.png]]

## Dependencies and Hazards
![[Obsidian-Attachments/Screenshot 2026-01-18 at 4.12.00 PM.png]]
 - in this case, the MUL always happens following ADD, so there is no problem with this dependence, as MUL will always write after ADD according to program order
![[Obsidian-Attachments/Screenshot 2026-01-18 at 4.14.11 PM.png]]
- in this case, the read of R4 in MUL is many cycles before the write of R4 by SUB
![[Obsidian-Attachments/Screenshot 2026-01-18 at 4.20.07 PM.png]]
- this is a situation where a dependence can cause a problem, because SUB has not yet written to R4, but DIV has read the wrong version of R4, causing a **HAZARD**
	- Hazards are a property of the program (can't have a hazard without a dependency), and the pipeline itself (output and anti dependence cannot become a hazard, but true dependencies can)
![[Obsidian-Attachments/Screenshot 2026-01-18 at 4.22.30 PM.png]]
- in this particular pipeline, if there are 3 or more steps between dependent steps, it would not be a hazard as the writes would have already occurred (ADD has already left the pipeline)
	- MUL result R7 is however a hazard 
### Dependencies and Hazards quiz
![[Obsidian-Attachments/Screenshot 2026-01-18 at 4.23.12 PM.png]]
- SUB: RAW, Yes
- DIV: RAW, No
- DIV: RAW, No
![[Obsidian-Attachments/Screenshot 2026-01-18 at 4.27.44 PM.png]]

## Handling hazards

- need to use flushes for control dependencies
	- the instructions in the pipeline after the control are the **wrong** instructions
- can stall for data dependence, or forward the value that it needs from within the pipeline, if detected
	- forwarding doesn't always work, will have to stall
	- prefer forwarding if possible becuase it doesn't introduce stalls

### Quiz
![[Obsidian-Attachments/Screenshot 2026-01-18 at 4.28.53 PM.png]]
- Flush, /, /
- /, /, Forward (one after the other, Read is right behind ALU)
- ~~/, /, Forward~~ Stall, because LW is still computing the value of R1 in ALU, and hasn't written it in the MEM stage yet. can forward after that one stall cycle
![[Obsidian-Attachments/Screenshot 2026-01-18 at 4.32.14 PM.png]]
## How many stages?
![[Obsidian-Attachments/Screenshot 2026-01-18 at 4.35.19 PM.png]]
- need to balance performance and power consumption, which is 10-15 stages in a modern pipeline.

