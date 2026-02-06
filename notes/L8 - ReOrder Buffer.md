![[Obsidian-Attachments/Screenshot 2026-02-04 at 4.59.05 PM.png]]
- need to handle exceptions that occur
- if later instructions have been executed already before the instruction with an exception finishes:
	- the exception handler may refer to a new value of a register used in the original instruction
- handling exceptions is one of the main functions of tomasulo's algorithm

# Recover from Branch Mispredictions
![[Obsidian-Attachments/Screenshot 2026-02-04 at 8.10.18 PM.png]]
- instructions can write to registers before a previously mispredicted branch has been verified
- phantom exceptions:
	- mispredict branch -> jump to instruction -> generate exception
	- triggers an exception even though it should've never been executed

## Correct OOO Execution
![[Obsidian-Attachments/Screenshot 2026-02-04 at 8.11.51 PM.png]]
- introducing the reorder buffer

# Reorder Buffer (ROB)
![[Obsidian-Attachments/Screenshot 2026-02-04 at 8.15.52 PM.png]]
- table of entry with 3 fields:
	- reg: where the destination register is
	- value: the value which may/may not be written to register
	- done: whether the value is valid or not
- this one can hold up to 8 instructions (kept in program order)
- need two pointers:
	- ISSUE: where does the next instruction go after being issued
	- COMMIT: the next instruction that is complete and ready to be written

## Example
![[Obsidian-Attachments/Screenshot 2026-02-04 at 8.19.05 PM.png]]
- On issue, place instruction into RS, and in the next position in ROB
- Increment ISSUE pointer by one
- Point RAT to ROB entry
![[Obsidian-Attachments/Screenshot 2026-02-04 at 8.21.28 PM.png]]
- On dispatch, just like before (check operands are ready, send to execution)
	- Need to wait until broadcast to release the Reservation Station because the RAT needed to know which RS to reference for the value
	- Now that the RAT points to ROB, we can free the RS immediately
### Quiz
![[Obsidian-Attachments/Screenshot 2026-02-04 at 8.22.29 PM.png]]
- More likely when no ROB, because RS needs to wait until broadcast
![[Obsidian-Attachments/Screenshot 2026-02-04 at 8.23.30 PM.png]]

## Cont'd
![[Obsidian-Attachments/Screenshot 2026-02-04 at 8.25.00 PM.png]]
- Broadcast is sent to other RS, and written to ROB instead of Registers
	- RAT is **not updated** as it still points to the ROB entry

### Commit: Extra steps after tomasulo's is done
![[Obsidian-Attachments/Screenshot 2026-02-04 at 8.26.54 PM.png]]
- need to commit all previous instructions before committing the current one
- write to the destination register
- remove RAT entry, let it point to the register
## Hardware Organization with ROB
![[Obsidian-Attachments/Screenshot 2026-02-04 at 8.28.18 PM.png]]
### Quiz
![[Obsidian-Attachments/Screenshot 2026-02-04 at 8.28.49 PM.png]]
- Yes
- Yes
- Yes
- No
- No
![[Obsidian-Attachments/Screenshot 2026-02-04 at 8.29.53 PM.png]]

## Branch Misprediction Recovery
![[Obsidian-Attachments/Screenshot 2026-02-04 at 10.16.55 PM.png]]
- RED: instructions that shouldn't have been executed but were
1. Issue LOAD, increment ISSUE pointer. RAT for R1 now points to ROB1
2. Issue BNE, no output, no need to insert into RAT. Increment ISSUE ptr
![[Obsidian-Attachments/Screenshot 2026-02-04 at 10.18.50 PM.png]]
3. Issue instructions that **shouldn't** have been issued 
![[Obsidian-Attachments/Screenshot 2026-02-04 at 10.19.51 PM.png]]
4. Suppose LOAD takes a long time to produce a value, because it's a cache miss. BNE also depends on load, as well as the ADD. The other two can continue
5. If MUL produces a value, DIV can then execute as well. In this ROB processor, the values are held in ROB and **NOT written to registers which could've done permanent damage**
![[Obsidian-Attachments/Screenshot 2026-02-04 at 10.23.32 PM.png]]
- Once Load completes, we can COMMIT the instruction to registers and let RAT point to the registers.
- Assume BNE takes longer to complete than the ADD, and ADD completes
![[Obsidian-Attachments/Screenshot 2026-02-04 at 10.25.38 PM.png]]
- When the BNE finally resolves, we annonate the ROB entry, commit it and perform a *recovery*
![[Obsidian-Attachments/Screenshot 2026-02-04 at 10.29.01 PM.png]]
- At the point of recovery, the registers all contain the correct values up until that point. None of the mispredicted values have been committed to registers
![[Obsidian-Attachments/Screenshot 2026-02-04 at 10.31.37 PM.png]]
- To undo the wrong instructions:
	1. Reverse ISSUE pointer to before the wrong entries and unmark DONE bits for those entries
	2. Rewriting the RAT so it points to registers, not the ROB
	3. Also free whatever is in the RS and stop ALU's from broadcasting results

## ROB and exceptions
![[Obsidian-Attachments/Screenshot 2026-02-05 at 2.40.45 PM.png]]
- treat any exceptions like a result, stored in the ROB
1. If the exception is generated as part of the correct path, all following instructions in the ROB are discarded, and the state is correct
2. If it's a phantom exception (wrong branch path), its simply treated as a result in the ROB, and discarded once the correct target is found and issued

### Commit is what was officially executed
![[Obsidian-Attachments/Screenshot 2026-02-05 at 2.50.24 PM.png]]
![[Obsidian-Attachments/Screenshot 2026-02-05 at 2.50.47 PM.png]]
### Quiz
![[Obsidian-Attachments/Screenshot 2026-02-05 at 2.52.00 PM.png]]
- What is the status of all operations after the exception for DIV has been handled?
- Committed
- Committed
- Committed
- ~~Committed~~ Unexecuted -> stop committed and flush pipeline, then jump to exception handler
- Discarded
- Discarded
![[Obsidian-Attachments/Screenshot 2026-02-05 at 2.54.04 PM.png]]
## RAT Updates on Commit
![[Obsidian-Attachments/Screenshot 2026-02-05 at 3.04.38 PM.png]]
- Upon each commit of an instructin from the ROB, its sent to the registers. The RAT entry is also removed if it matches the ROB, otherwise it may point to a more recent ROB entry
	- ROB1 can now be cleared
![[Obsidian-Attachments/Screenshot 2026-02-05 at 3.06.31 PM.png]]
- Once ROB2 has been committed, it populates register R3, and because it is referenced in the RAT, the RAT is now pointed toward R3 too
![[Obsidian-Attachments/Screenshot 2026-02-05 at 3.07.52 PM.png]]
- ROB3 is now committed, but because it's not the value referenced in RAT for R1, RAT is not changed. The register is still updated
![[Obsidian-Attachments/Screenshot 2026-02-05 at 3.09.56 PM.png]]
- Once ROB4 is committed, it updates the registers and the RAT because it matches the entry for R1
![[Obsidian-Attachments/Screenshot 2026-02-05 at 3.11.54 PM.png]]
- Final notes:
	- Instructions are executed OOO, but are committed in program order
	- On commit, the correct register is updated with the value.
	- If the RAT points to the current ROB entry, then it is changed to point to the registers
		- If not, it is untouched

## ROB Example
![[Obsidian-Attachments/Screenshot 2026-02-05 at 3.21.22 PM.png]]
- tag being broadcast is now ROBx, instead of the actual register name like before
- In this example: Issue and dispatch in same cycle, execute in the next cycle
![[Obsidian-Attachments/Screenshot 2026-02-05 at 3.23.14 PM.png]]
- Sent DIV (all operands available) to ALU in cycle 2, need to wait 40 cycles
- Sent MUL (all operands available) to ALU in cycle 3, need to wait 10 cycles
- Updated ROB with destinations, updated RAT to point to ROB
![[Obsidian-Attachments/Screenshot 2026-02-05 at 3.35.24 PM.png]]
- Cycle 3: ADD is issued, operands are available so it gets dispatched as well. ROB3 is created for it, and RAT is updated so the ADD result R3 points to ROB3.
![[Obsidian-Attachments/Screenshot 2026-02-05 at 3.39.57 PM.png]]
- Cycle 4: ADD begins execution, can issue MUL. It produces R1, so the RAT value for R1 of ROB2 is overwritten by ROB4. It needs ROB2 and ROB3 to execution, so it must wait.
![[Obsidian-Attachments/Screenshot 2026-02-05 at 3.47.45 PM.png]]
- Cycle 5: 
	- SUB is issued, but it must wait for R1 == ROB4. R5 is available.
	- ADD from I3 is done executing, so it now broadcasts ROB3 to all the RS's, and the waiting MUL takes that value
![[Obsidian-Attachments/Screenshot 2026-02-05 at 3.53.51 PM.png]]
- Cycle 6:
	- Try to issue the last ADD, need to wait on ROB5 and ROB1
	- The ADD from I3 is done executing, but it cannot be committed until the previous instructions have been committed. it's result can still be used however
![[Obsidian-Attachments/Screenshot 2026-02-05 at 3.56.23 PM.png]]
- Cycle 13: Since nothing really happens until now
	- ROB2 finally completes, the ROB entry is marked as done, it's value (12) gets broadcast
	- The waiting MUL instruction is now ready to dispatch, and starts executing in cycle 14
![[Obsidian-Attachments/Screenshot 2026-02-05 at 4.01.20 PM.png]]
- Cycle 24: 
	- ROB4 broadcasts it's result, it's marked as done.
	- SUB waiting in the RS can now be dispatched, and execute in cycle 25
![[Obsidian-Attachments/Screenshot 2026-02-05 at 4.02.37 PM.png]]
- Cycle 26:
	- ROB5 has now finished executing the SUB, it can be marked done in ROB, and broadcasted
![[Obsidian-Attachments/Screenshot 2026-02-05 at 4.04.16 PM.png]]
- Cycle 42:
	- ROB1 DIV finally completes, the value (9) gets broadcast on the bus, and all waiting instructions (ADD) captures the value and dispatches. It can execute in cycle 43
![[Obsidian-Attachments/Screenshot 2026-02-05 at 4.06.13 PM.png]]
- Cycle 43:
	- I1 can commit it's value now from the ROB. The value updates the register file as R2. RAT entry for R2 that points to ROB1 is now erased (points to RF). ROB1 entry is deleted
![[Obsidian-Attachments/Screenshot 2026-02-05 at 4.09.26 PM.png]]
- Cycle 44:
	- ROB6 completes executing, the result (42) gets broadcast and it is marked as done.
	- Look at next ROB instruction, and commit. (Update register, check if RAT points to it, delete entry if so, free ROB entry, increment commit pointer)
![[Obsidian-Attachments/Screenshot 2026-02-05 at 4.09.07 PM.png]]![[Obsidian-Attachments/Screenshot 2026-02-05 at 4.10.07 PM.png]]
- In the last cycle, the RAT is cleared out as each ROB entry updates the RF and checks the RAT

### Quiz 1
![[Obsidian-Attachments/Screenshot 2026-02-05 at 4.11.34 PM.png]]
- What is the RAT for R2?
	- Issue I1 DIV, all operands available, can execute in cycle 2
	- Placed DIV in ROB1 with R2, 20 / 5 = 4, Not Done
	- Update RAT R2 to **ROB1**
![[Obsidian-Attachments/Screenshot 2026-02-05 at 4.13.16 PM.png]]
### Quiz 2
![[Obsidian-Attachments/Screenshot 2026-02-05 at 4.20.17 PM.png]]
- Issue I4 MUL R1, R1, R2
	- RS: MUL, dest = ROB4, TAG1 = ROB2, TAG2 = ROB1, no values yet
	- RAT: R1 updates from ROB2 to ROB4
![[Obsidian-Attachments/Screenshot 2026-02-05 at 4.22.18 PM.png]]
### Quiz 3
![[Obsidian-Attachments/Screenshot 2026-02-05 at 4.23.32 PM.png]]
- In Cycle 5
	- Dispatch: Because ROB3 gets sent to all RS, ROB5 SUB now has all operands and can be dispatched (Allow dispatch after broadcast here)
	- Wr Res:I4 ADD completes and the result is broadcast as ROB3
![[Obsidian-Attachments/Screenshot 2026-02-05 at 4.26.43 PM.png]]
### Quiz 4
![[Obsidian-Attachments/Screenshot 2026-02-05 at 4.27.54 PM.png]]
- In Cycle 6, the ROB2 MUL is now complete and result is broadcast
- ROB4 MUL is waiting on ROB1 to dispatch
	- needs to wait until cycle 12 to get broadcast the result from DIV
![[Obsidian-Attachments/Screenshot 2026-02-05 at 4.29.27 PM.png]]
### Quiz 5
![[Obsidian-Attachments/Screenshot 2026-02-05 at 4.30.31 PM.png]]
- ROB6 is also dispatched in cycle 12 as it also captured ROB1
- What else happens in cycle 13?
	- No more instructions to issue
	- I1 (ROB1) completed last cycle, and it can finally be committed.
	- ARF R2 is updated to 4
	- RAT R2 points to ROB1, so it is removed and now defaults to ARF
	- ROB1 entry is removed
![[Obsidian-Attachments/Screenshot 2026-02-05 at 4.32.42 PM.png]]
### Quiz 6
![[Obsidian-Attachments/Screenshot 2026-02-05 at 4.33.46 PM.png]]
- In cycle 14: Does any entry in the RAT change, as I6/ROB6 completes?
	- ROB6 targets R1, but it hasn't committed yet so **RAT is not changed**
![[Obsidian-Attachments/Screenshot 2026-02-05 at 4.35.44 PM.png]]
### Quiz 7
![[Obsidian-Attachments/Screenshot 2026-02-05 at 4.36.28 PM.png]]
- ROB2 is already completed, so we can commit it, however it doesn't change the RAT since it points to ROB6. It updates R1 to 8
	- ROB2 entry is also cleared
![[Obsidian-Attachments/Screenshot 2026-02-05 at 4.37.51 PM.png]]
### Quiz 8
![[Obsidian-Attachments/Screenshot 2026-02-05 at 4.38.03 PM.png]]
- What is the cycle for the last commit?
	- ROB4 writes in cycle 16, commits in 17
	- ROB5 commits in 18
	- ROB6 commits in 19
![[Obsidian-Attachments/Screenshot 2026-02-05 at 4.39.57 PM.png]]

## ROB Timing Example
![[Obsidian-Attachments/Screenshot 2026-02-05 at 6.50.23 PM.png]]
- free the RS on broadcast, not dispatch
	- some processors do this because they are speculating and keep the instruction in the RS until its really sure about it
- in this ex, 3 ADD/SUB RS and 2 MUL/DIV RS
- I4: since we free RS only on broadcast, I4 can only be issued into an RS when one is free, and it is freed after I2 MUL has broadcast in cycle 13
- I5: Can issue immediately after I4, but must wait for R1 in I4, which is after cycle 25 to execute
- I6: Execute depends on R2 from I1, which writes in cycle 42, so execute in cycle 43

### Quiz
![[Obsidian-Attachments/Screenshot 2026-02-05 at 6.53.01 PM.png]]
- Still 2 MUL/DIV RS
- What happens to instruction 2?
	- Issued in cycle 2
	- Executed in cycle 3
	- Write in cycle 5
	- Commit in cycle 7 (can commit 2 inst/cycle, this one broadcast before I1)
![[Obsidian-Attachments/Screenshot 2026-02-05 at 7.03.27 PM.png]]
> I think this is wrong...it should commit in cycle 7
### Quiz
![[Obsidian-Attachments/Screenshot 2026-02-05 at 7.04.39 PM.png]]
- when do the add and multiply issue?
	- ADD: Cycle 3
	- MUL: Cycle 4
- When do they commit
	- ADD: 9 (issue 3, exec 4, wr 5, commit 8) -> can broacast 1 add/sub and mul/div in same cycle (5), can commit with previous inst, **or in the correct soln, just by itself in cycle 8**
	- MUL: 10 (issue 4, exec 7, wr 9, commit 10) -> need to wait for R1/R2 to broadcast, so execute after cycle 6
![[Obsidian-Attachments/Screenshot 2026-02-05 at 7.12.33 PM.png]]
### Quiz 3
![[Obsidian-Attachments/Screenshot 2026-02-05 at 7.12.53 PM.png]]
- When does the last instruction commit?
- I5: Issue=5, Execute=7, Wr=8, C = 10
	- can execute in the same cycle as the previous instruction bc diff exe unit
	- need to wait for R2 in I1 to execute, can commit with previous
- I6: Issue=6, Execute=9, Wr=10, C = 11
	- need to wait for R4 in I5 to wr in cycle 8 to execute. commit in next cycle
![[Obsidian-Attachments/Screenshot 2026-02-05 at 7.19.53 PM.png]]
## Unified Reservation Stations
![[Obsidian-Attachments/Screenshot 2026-02-05 at 7.24.04 PM.png]]
- can run out of RS of one type, which will block the issue of further instructions
- to improve ability to use the expensive RS, we can combine them
- dispatching becomes more complex, need to look over all instructions to pick out what goes to execution
### Superscalar
![[Obsidian-Attachments/Screenshot 2026-02-05 at 7.27.09 PM.png]]
- to broadcast more than 1 result/cycle, need multiple buses, and many more comparisons per instruction
- the pipeline flow is limited by the weakest link, or the narrowest part 

## Terminology Confusion
![[Obsidian-Attachments/Screenshot 2026-02-05 at 7.28.51 PM.png]]
- some papers and resources have different names for these three stages, and some overlap

## Out of Order
![[Obsidian-Attachments/Screenshot 2026-02-05 at 7.35.29 PM.png]]
- what really is out of order?
- Fetch, decode and issue are in order to ensure dependencies retrieved are compatible with the original program order
### Quiz
![[Obsidian-Attachments/Screenshot 2026-02-05 at 7.36.02 PM.png]]
- Fetch: In order
- Decode: In order
- Issue: In order
- Dispatch: Out of Order
- Execute 1: Out of Order
- Execute 2: Out of Order
- Broadcast: Out of Order
- Commit: In order
- Release ROB Entry: **In Order** (Release after commit)
![[Obsidian-Attachments/Screenshot 2026-02-05 at 7.39.31 PM.png]]