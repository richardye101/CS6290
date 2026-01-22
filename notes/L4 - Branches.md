
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

- in a shallow 5 stage pipeline
