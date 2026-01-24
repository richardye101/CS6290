
# Branch Intro
![[Obsidian-Attachments/Screenshot 2026-01-20 at 9.36.01 PM.png]]
- branching is when a condition is met, and something needs to happen
- if the condition is not satisfied (R1 != R2), the we just increment the PC to the next instruction outside of the if statement
- if the condition is satisfied, then it skips outside the if statement, AND is instructed to jump to somewhere else in the code

![[Obsidian-Attachments/Screenshot 2026-01-20 at 9.40.28 PM.png]]
- it always pays to fetch an instruction, regardless of if we know whether its right or not
- we either don't fetch anything until we know the result of the BEQ, which guarantees a bubble of 2
	- or we fetch and are sometimes wrong

![[Obsidian-Attachments/Screenshot 2026-01-20 at 9.45.11 PM.png]]
- in prediction, we only care if the instruction is going to be a taken branch

## Prediction Accuracy
![[Obsidian-Attachments/Screenshot 2026-01-20 at 9.51.24 PM.png]]
- CPI = 1 + % mispredictions of all instructions x penalty per mispred
- a better branch predictor helps regardless of shallow or deep pipeline (# stages)
	- but the amount of help changes based on how deep the pipeline is
- the speedup for deeper pipelines is greater

### Quiz
![[Obsidian-Attachments/Screenshot 2026-01-20 at 9.52.25 PM.png]]
Penalty per mispred: 2
No prediction at all, permanent penalty of 2
CPI = 1 + 1/3 x 2 = 1.67

If we had perfect prediction:
CPI = 1 + 0 = 1

![[Obsidian-Attachments/Screenshot 2026-01-20 at 9.57.27 PM.png]]
- each instruction has an added cost of 2 cycles because we only know if it's a branch in 3rd stage
- BNE2 takes 3 stages, because 1 extra to determine what the branch result is
- 7 bubbles per loop
- speed up = 7/3 = 2.33

## Not taken prediction
![[Obsidian-Attachments/Screenshot 2026-01-21 at 8.19.02 PM.png]]
- in a shallow 5 stage pipeline
- its always better to predict the next instruction

### Quiz
![[Obsidian-Attachments/Screenshot 2026-01-21 at 8.44.23 PM.png]]
- 5 cycles:
	- 3 cycles to know to goto Label A (2 wasted)
	- ~~2 cycles from Label A to Y~~ We immediately start at label A and fetch X
![[Obsidian-Attachments/Screenshot 2026-01-21 at 8.47.01 PM.png]]
- 2 cycles

## Predict Not-taken
![[Obsidian-Attachments/Screenshot 2026-01-21 at 8.52.26 PM.png]]


## Motivation for better prediction

![[Obsidian-Attachments/Screenshot 2026-01-21 at 8.57.11 PM.png]]
- 5 stage pipeline, 3rd stage branche resolve
- 14 stage pipeline, 11th stage branch resolve
- 14 stage pipeline, 11th stage branch resolve, 4 instr per cycle

### Quiz
![[Obsidian-Attachments/Screenshot 2026-01-21 at 8.57.45 PM.png]]
- branches are resolved in the 30th stage, and the taken branch is only determined in the 31st stage
- 0.5 + .20 x .01 x 30 = 0.56
- 0.5 + .20 x .02 x 30 = 0.616
- slowdown = 1.1039

![[Obsidian-Attachments/Screenshot 2026-01-21 at 9.03.05 PM.png]]
This is NOT what he wanted me to calculate
- The given CPI is the FINAL CPI, not the base.

![[Obsidian-Attachments/Screenshot 2026-01-21 at 9.04.38 PM.png]]
- misprediction can result in a LOT of wasted cycles, especially if multiple instructions are performed per cycle

## Better predictor
![[Obsidian-Attachments/Screenshot 2026-01-21 at 9.06.18 PM.png]]
- if all you know is the current PC, then you can't really do much
- don't really know anything useful, except the historical behaviour at the current PC

## Branch Target Buffer BTB

![[Obsidian-Attachments/Screenshot 2026-01-21 at 9.08.06 PM.png]]
- keep a table indexed by the PC, and stored there is the best guess for what the next PC is
- we carry the PC_now through the pipeline and if it's incorrect, then we update the BTB

![[Obsidian-Attachments/Screenshot 2026-01-21 at 9.10.12 PM.png]]
- cannot have a dedicated entry for each PC in a program, otherwise it would be just as large as the program

![[Obsidian-Attachments/Screenshot 2026-01-21 at 9.10.58 PM.png]]
- only need to have enough entries for the number of lines that are actually executed
![[Obsidian-Attachments/Screenshot 2026-01-21 at 9.12.59 PM.png]]
- need the mapping function to be simple so it can be done in 1 cycle
	- use the least significant bits of the PC as the key, becuase most lines in a program will share the most significant bits
### Quiz
![[Obsidian-Attachments/Screenshot 2026-01-21 at 9.14.58 PM.png]]
- word aligned: address divisible by 4 (e.g. not 3,5,17)
- 4bytes = 32 bits
- 10 11 0 12
	- becomes 1010 1011 0000 1100
![[Obsidian-Attachments/Screenshot 2026-01-21 at 9.21.57 PM.png]]
- need 10 bits (1024 entries)
- since the PC is 4 bytes & word aligned, not all addresses exist
- this means that we would waste 3/4 addresses in the BTB, if we take the last 10 bits
- therefore, we should shift left by 2 places and take 10 bits ending there
- therefore the index is 1010 **10|11 00|00 11**00 = 0x 2C3

## Direction Predictor BHT
![[Obsidian-Attachments/Screenshot 2026-01-21 at 9.24.49 PM.png]]
- on top of the BTB, we can have a separate Branch History Table which simply stores whether a certain PC is taken (use BTB) or not taken (increment PC)

### Quiz
![[Obsidian-Attachments/Screenshot 2026-01-21 at 9.27.27 PM.png]]
- 1
- 1
- 101
- 100
- 100
- 100
- 100
- 100
I'm pretty sure we access BHT for every instruction since we can store it all in the BHT
![[Obsidian-Attachments/Screenshot 2026-01-21 at 9.29.48 PM.png]]
### Quiz 2
- Which BHT entry do we access for each instruction?
![[Obsidian-Attachments/Screenshot 2026-01-21 at 9.30.50 PM.png]]
- since BHT has 16 entries, that means it is made up of 4 bits
- entries would be:
	- 0
	- 1
	- 2
	- 3
	- 4
	- 5
	- 6
	- 7
![[Obsidian-Attachments/Screenshot 2026-01-21 at 9.40.19 PM.png]]
### Quiz 3
![[Obsidian-Attachments/Screenshot 2026-01-21 at 9.40.48 PM.png]]
- 0
- 0
- 1 - on the last iteration, when R1 == R2, does it jump to Done
- 0
- 0
- 0
- 0
- 100
![[Obsidian-Attachments/Screenshot 2026-01-21 at 9.43.00 PM.png]]
### Quiz 4
![[Obsidian-Attachments/Screenshot 2026-01-21 at 9.43.21 PM.png]]
- 4 entries -> 2 bits
- N/A
- N/A
- C008 = 1100 0000 0000 **10**00 = 0x2
- N/A
- N/A
- N/A
- N/A
- C01C = 1100 0000 0010 **11**00 = 0x3
**Looking at ENTRY KEYS, not the values they store!**
![[Obsidian-Attachments/Screenshot 2026-01-21 at 9.48.27 PM.png]]
### Quiz 4
![[Obsidian-Attachments/Screenshot 2026-01-21 at 9.49.50 PM.png]]
- 0, 0, 101, 0, 0, 0, 0, 100
![[Obsidian-Attachments/Screenshot 2026-01-21 at 9.50.49 PM.png]]
- at the end of the loop, there is 1 misprediction, but then the BHT is updated and there are no more mispredictions
- similarly at BEQ, at the very end of the program, it predicts the next PC however it should have jumped to Done, so only 1 misprediction

## Problems with 1 bit prediction
![[Obsidian-Attachments/Screenshot 2026-01-21 at 9.56.07 PM.png]]
- >>> means vastly more than 
- each anomaly means 2 mispredictions
- does not do well when the number of taken vs not taken branches are similar
	- also does not do well in short loops

## 2 Bit Prediction (2BP, 2BC)
![[Obsidian-Attachments/Screenshot 2026-01-22 at 8.24.52 PM.png]]
- two bits, one prediction bit and one histeresis (conviction) bit
- very easy to implement this type of predictor
![[Obsidian-Attachments/Screenshot 2026-01-22 at 8.29.16 PM.png]]
- do we start in a strong state or weak state?
- should probably start in a weak state, because it only costs 1 cycle to switch compared to 2 in a strong state
- conversely, if the branches alternate being taken and not taken, then starting in a weak state means more wasted cycles (bad worse case scenario)
	- but this is less common, so not really worth optimizing for
- it may seem to be a good idea to start in a weak state, overall accuracy is not affected by where it starts, so start at 00 for simplicity

### Quiz
![[Obsidian-Attachments/Screenshot 2026-01-22 at 10.08.30 PM.png]]
- Sequence is: T T N T N
- Every predictor has some sequence that results in the worst outcome (all mispredictions)
	- All that changes is **how likely** that sequence is
![[Obsidian-Attachments/Screenshot 2026-01-22 at 10.10.06 PM.png]]

## More predictor bits
![[Obsidian-Attachments/Screenshot 2026-01-22 at 10.12.10 PM.png]]
- costs go up when adding more bits in the predictor
- prevents bad outcomes against anomalous outcomes that come in streaks
	- this doesn't happen very often

## History based predictors
![[Obsidian-Attachments/Screenshot 2026-01-22 at 10.18.31 PM.png]]
- predict the next branch using the most recent or 2 most recent results

## 1 bit history with 2 bit counters
![[Obsidian-Attachments/Screenshot 2026-01-22 at 10.22.28 PM.png]]
1 bit of history (T or N)
2 bit counter for when history is Not taken
2 bit counter for when history is Taken
![[Obsidian-Attachments/Screenshot 2026-01-22 at 10.25.36 PM.png]]

### Quiz
![[Obsidian-Attachments/Screenshot 2026-01-22 at 10.26.42 PM.png]]
0, SN, SN -> N, N, Y
0, SN, SN -> N, N, Y
0, SN, SN -> N, T, X
1, WN, SN -> N, N, Y
0, SN, SN -> N, N, Y
0, SN, SN -> N, T, X
1, WN, SN -> N, N, Y
0, WN, SN -> N, N, Y
0, SN, SN -> N, T, X
![[Obsidian-Attachments/Screenshot 2026-01-22 at 10.34.56 PM.png]]
Every 3 iterations, one wrong
3 iterations per repetition, and 100 repetitions = 100 mispredictions

## 2 Bit history predictor
![[Obsidian-Attachments/Screenshot 2026-01-22 at 10.39.29 PM.png]]
- we now track the last two bits of history, and it can predict the (NNT)* pattern perfectly
![[Obsidian-Attachments/Screenshot 2026-01-22 at 10.48.21 PM.png]]
- larger n bit history predictors can result in a lot of waste (10 bit history + $2^{n}$ BC's of size 2 bits)
- waste many BC's because it can only predict patterns of up to N+1 in length using N bits of history, while we have $2^{n}$ BC's 
	- if N = 10, we have 1024 BC's, but we'll only be using 11 of them
- it is necessary to have longer history predictors because there are commonly loops of 8-9 iterations, which need 8-9 bit predictors to be accurate
- the goal is to reduce the waste

### Quiz
![[Obsidian-Attachments/Screenshot 2026-01-22 at 10.50.58 PM.png]]
- N=4, ___ , Yes, 2
- N=8, (8 + 2 x 2^8) x 1024 , Yes, 2
- N=16, (16 + 2 x 2^16) x 1024 , Yes, 2
![[Obsidian-Attachments/Screenshot 2026-01-22 at 10.54.14 PM.png]]
### Quiz 2
![[Obsidian-Attachments/Screenshot 2026-01-22 at 10.55.11 PM.png]]
- 3 entries
- at least 8 bit history
- this means $2^{8}$ Bit Counters
![[Obsidian-Attachments/Screenshot 2026-01-22 at 10.59.29 PM.png]]
- need at least 4 entries, because there are 4 possible places to branch (the two for loop entires, and the two exits)

## Reducing waste in history predictors
![[Obsidian-Attachments/Screenshot 2026-01-22 at 11.01.50 PM.png]]
- only using about N counters, but don't know *which* N we're gonna be using
- can share the counters with other entries, and hopefully not have many overlaps
![[Obsidian-Attachments/Screenshot 2026-01-22 at 11.08.45 PM.png]]
- this system is essentially: a table of all possible histories indexed by `m` bits of PC + a Branch History Table, indexed by XOR'ing the PC and the N bits of history
- it saves a lot of storage
![[Obsidian-Attachments/Screenshot 2026-01-22 at 11.15.20 PM.png]]
- some patterns only use 1 or 2 counters total
- overlaps after XOR-ing the PC and history bits are very unlikely

## Pshare and Gshare
![[Obsidian-Attachments/Screenshot 2026-01-22 at 11.18.58 PM.png]]
- Gshare: one place that ALL history goes, useful for correlated branches

### Quiz
![[Obsidian-Attachments/Screenshot 2026-01-22 at 11.20.03 PM.png]]
- how many bits of history?
- 3 branches
- BEQ - Exit: no amount of history would help, it is always not taken until the last iteration
- BEQ - Even: alternates between N and T every loop -> NTT, NNT, NTT, NNT -> two bits of history needed
- B - Loop: doesn't care until the end
- Pshare needs at least 2 bits of history
- Gshare needs at least 2 bits of history too
![[Obsidian-Attachments/Screenshot 2026-01-22 at 11.26.11 PM.png]]
- Pshare only needs history length of 1 (its own history of taken or not, always do the opposite of what it did last)
- Gshare tracks everything like 011 001 011 001...
	- need at least 3 bits of history
![[Obsidian-Attachments/Screenshot 2026-01-23 at 6.04.54 PM.png]]
- wnat Gshare for correlated branches abd pshare for self-simliar branches (even if we have to use shorter history)

## Tournament Predictor
![[Obsidian-Attachments/Screenshot 2026-01-23 at 6.13.53 PM.png]]
- want best behaviour for certain types of branches
- use a meta-predictor, that predicts which predictor to use
- if both work or neither work, the meta BC doesn't change

## Hierarchical Predictor
![[Obsidian-Attachments/Screenshot 2026-01-23 at 6.43.17 PM.png]]
- only have one really good predictor, instead of 2 (because they're expensive)
- use an ok predictor for easy to predict branches
- update OK predictor on each iteration
	- only update good predictor if the OK predictor isn't doing well
- hierarchical usually wins because most branches can be predicted easily
- this leaves the good predictor witih lots of memory to use with only a few entries, while the ok predictor has a lot of entries
	- can have extremely long histories with the good predictor

![[Obsidian-Attachments/Screenshot 2026-01-23 at 6.47.46 PM.png]]
- Pentium M predictor has hierarchical predictors
- uses global predictor first if it has a match and tag array says it should use global
- then use local predictor if the tag array says it should
- otherwise then just use the 2BC

On update:
- we first update 2BC
- if we have in local, then update local 
- if we have in global, then update global

- If we don't have the branch in local and 2BC mispredicts, we insert into local
- If we don't have the branch in global and local mispredicts, we insert into global
- Most branches can be predicted well by the 2BC, so the local and global predictors don't need many entries

- There is a seperate array for local containing some upper bits of a PC that helps determine if a specific branch maps to that entry. All other branches that map there will say "not found"

### Quiz
![[Obsidian-Attachments/Screenshot 2026-01-23 at 6.59.39 PM.png]]
- E: Hierarchical
- A: 2BP and D: Tournament
- B: Pshare and C: Gshare
![[Obsidian-Attachments/Screenshot 2026-01-23 at 7.02.35 PM.png]]

## Return Address Stack (RAS)
![[Obsidian-Attachments/Screenshot 2026-01-23 at 7.06.43 PM.png]]
- conditional: if taken, need to determine target address
	- direction: already have good predictors above to predict
	- target: always goes to the same target. BTB works fine
- uncond jump calls: (e.g. function calls)
	- direction: always taken 
	- most of the time, jumps to a label or call a specific func. BTB that  remembers previous target does fine
- function returns:
	- always taken
	- hard to predict jump because it could be called from multiple places in the program
		- BTB will not do well, because it remembers the previous return only
![[Obsidian-Attachments/Screenshot 2026-01-23 at 7.10.22 PM.png]]
- Separate predictor dedicated to function returns
- a stack populated on function call with the return address, and the pointer is moved
- once the function reaches the return, it will pop from the RAS and get the correct target address

- why not just use the call stack?
	- it needs to be close to where branch prediction is happenning and needs to be very small
	- unlike traditional stack, with many function calls, this is a small hardware structure to make prediction quickly (1 cycle), with a limited number of entries
- if we exceed the size of the RAS:
	1. don't push anything
	2. wrap around and overwrite/fill 

### Quiz
![[Obsidian-Attachments/Screenshot 2026-01-23 at 7.10.39 PM.png]]
- don't push: we mispredict where functions return for however many extra calls we couldn't store
- wrap around: we predict accurately for the last N returns where N is the size of the stack, and mispredict any older entries. i think this is preferable
![[Obsidian-Attachments/Screenshot 2026-01-23 at 7.15.37 PM.png]]
- if we have a small RAS, and lots of function calls in the program, and we do Don't Push, then most of the actual work are going to be mispredicted. only when the initial return is reached is the RAS used
- many more small function calls than large function calls, in the end its more effect use of the RAS entries we have
- either way, we'll have mispredictions

## How do we know its a Return?
![[Obsidian-Attachments/Screenshot 2026-01-23 at 7.19.41 PM.png]]
- haven't been decoded yet when fetching the instruction, don't know if its a return
- use a predictor to predict if it's a return
	- it'll be very accurate, if we see a PC that is followed by a return, then a single bit predictor will be very good
	- we can do pre-decoding: CPU has a cache for instructions
		- when fetching from memory, i fetch enough of the instruction to know if it's a return, and store that info in the cache
		- predecoding is really powerful, can determine if a instr. is a branch, or ret and therefore telling us whether we need to use a predictor or not 


