
- Unlike branch prediction, which guesses where the branch is going
	- no penalty if correct
	- huge penalty if wrong (because deep pipe with multiple stages, and many concurrent instructions)
- Predication: doing work on both directions, throw away work on the wrong path
	- wastes up to 50% of the work
	- either way we lose quite a bit

Comparison of prediction/predication of different branch types:
![[Obsidian-Attachments/Screenshot 2026-01-25 at 9.46.30 PM.png]]
- Loops:
	- Prediction: more loops -> better prediction
	- Predication: do work in the loop, do work after loop. After 1000 iterations, very little of the work will be done correctly (Branch diverges too much, too much work done is wasted if every loop, we do the work after the loop ends)
	- **Predict is better**
- Function call: 
	- predication: Always go to the function call, so doing the work when not going there is pointless
	- **Predict is better**
![[Obsidian-Attachments/Screenshot 2026-01-25 at 9.48.24 PM.png]]
- Large If & Else (100 instructions):
	- Prediction: If wrong, waste 50 instruction (given this CPU has a deep pipeline and resolves branch 50 stages in)
	- Predication: If equal weight to both sides of if/else, we waste 100 instructions either way
	- Predict is better
![[Obsidian-Attachments/Screenshot 2026-01-25 at 9.52.55 PM.png]]
- Small If & Else (5 instructions):
	- Prediction: Waste 50 instructions if we're wrong
	- Predication: We'll execute 10 instructions (double the 5 actually needed) and waste 5
	- Which is better?
		- Predication: Always waste 5 (100% x 5)
		- Prediction: Say 10% misprediction, we waste (10% x 50 = 5)
		- Better off predicating if branch prediction accuracy is lower than 90% in this case

## If Conversion (How predication works)
![[Obsidian-Attachments/Screenshot 2026-01-25 at 9.55.39 PM.png]]
- If Conversion is the technique the compiler uses to create the code on both paths
- If the "If Conversion" worked such that it does both branches of work, and still needs to choose between the values, we've just created TWO branches from the one. This is pointless
- Need a "MOV" instruction if a predicate is true

## Conditional Move
![[Obsidian-Attachments/Screenshot 2026-01-26 at 9.26.18 PM.png]]
- MIPS has a conditional move
	- `MOVZ`: Compares `Rt` to 0 and if so, then change `Rd=Rs`
	- `MOVN`: Compares `Rt` to NOT 0 and if so, then change `Rd=Rs`

- x86 has a whole set of `C` move instructions
	- if the cond code corresponds to any of the listed ones, it puts src into dst
	- don't even need to put the condition in a register like MIPS, can just test

### Quiz
![[Obsidian-Attachments/Screenshot 2026-01-26 at 9.35.13 PM.png]]
- if R1 == 0, branch and increment R3. otherwise, increment R2. finally, goto end.
- If conversion needs:
	- MOVN R2, R4, R1
	- MOVZ R3, R5, R1
- results in 4 instructions of work, no branches
- original has 3 +2 instructions of work
![[Obsidian-Attachments/Screenshot 2026-01-26 at 9.38.34 PM.png]]

## MOVZ/MOVN performance
![[Obsidian-Attachments/Screenshot 2026-01-26 at 9.45.41 PM.png]]
- if BEQZ is 80% accurately predicted and has 40-inst penalty
- if its not biased, then on average it costs $2.5 + 20\% \cdot 40 = 10.5$ instructions

### Quiz
![[Obsidian-Attachments/Screenshot 2026-01-26 at 9.46.16 PM.png]]
$$
\begin{aligned}
2.5 + x \cdot 30 &= 4\\
x &= \frac{1.5}{30}\\
x &= \frac{1}{20}\\
x &= 0.05 = 5\%
\end{aligned}
$$

Prediction accuracy below 95% means that if-conversion is better
![[Obsidian-Attachments/Screenshot 2026-01-26 at 9.48.45 PM.png]]

## MOVcond summary
![[Obsidian-Attachments/Screenshot 2026-01-26 at 9.57.15 PM.png]]
- need compiler support, which isn't backwards compatible (not all code will use these instructions)
- if we have a hard to predict branch, we can just use if-conversion to get rid of it
- if-conversion requires:
	- more registers: it needs to keep results from both paths
	- more instructions executed: instructions from both paths and the instructions to keep the values from the right path
- can make all instructions conditional to remove the need to store results from both paths in registers and make moves to pick the correct values at the end -> full predication
	- needs extensive support from the instruction set

## Full Predication hardware requirements


- conditional move:
	- needs separate opcode specifies each conditional move instruction
- full predication:
	- don't change the instruction, however we add condition bits to every instruction
	- e.g. Itanium has a **q**ualifying **p**redicate bit that the instruction depends on to determine if it should write or not. the least significant 6 bits specify the qp.
	- the predicates are small 1 bit registers so we can do a condition, check, and store results in these bits and tell us which of the 64bit conditional registers we want to use to determine the write

![[Obsidian-Attachments/Screenshot 2026-01-26 at 10.05.09 PM.png]]
- still have the work of both paths, but no extra registers and no extra instructions to move those results

### Quiz
![[Obsidian-Attachments/Screenshot 2026-01-26 at 10.06.13 PM.png]]
- ~~P1, P2~~
- $CPI = 0.5 + x \cdot 10 = 3$
- $x = 0.25$
- if BEQZ accuracy is less than 75%, then if-conversion with full predicatoin is better
![[Obsidian-Attachments/Screenshot 2026-01-26 at 10.18.01 PM.png]]
- P2 (happens with R2!=0, and we add 1 to R1)
- P1 (gets branched to IF R2 == 0 and we add -1 to R1)
- 0.5 CPI means the full predication takes 1.5 cycles total, and other things can be done during the cycle
- need to count the inst per branch (2 or 3), average to 2.5 inst
	- 2.5 x 0.5 = 1.25 cycles on avg
	- .25 = 10x so x = .025, and that means it must be 97.5% accurate or full predication is better
