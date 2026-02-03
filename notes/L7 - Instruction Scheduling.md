
# Improving IPC
![[Obsidian-Attachments/Screenshot 2026-02-02 at 6.31.08 PM.png]]
- ILP can be really good, over 1
- good branch prediction than control dependency IPC's will be close to their ILP's

These are the focus:
- WAR & WAW false dependencies can be solved with register renaming
	- how does register renaming actually work?
- RAW data deps are helped by Out of Order Execution
	- how does this actually work?
- Structurl Deps: not enough resources in CPU, can be solved by getting a wider issue processor

# Tomasulo's Algorithm
![[Obsidian-Attachments/Screenshot 2026-02-02 at 6.33.28 PM.png]]
- old algo used for Out of Order Execution
- determines which inst is ready to be executed
- also includes register renaming
- similar to what we use today
- this algo focused on floating-point instr, now we do it for all instructions
- this algo only looked at a small window of future instructions. today, we look 100s of instructions into the future
![[Obsidian-Attachments/Screenshot 2026-02-02 at 6.40.58 PM.png]]
- IQ: Instruction Queue - All instructions queue up here to be input into tomasulo's algorithm
- RS: Reservation Station - Where the instructions sit and wait for parameters to become ready
- Regs: Floating point number register file - Values already in registers will be inputted into the RS as needed

Once an instruction is ready to be processed, it is entered into an **Execution Unit**: E.g. ADD, MUL, etc
- Result is broadcast on a bus, which ends up in the register file
	- Also broadcast to instructions in the RS as the values they want are produced.
- Results may not actually be used by instructions if they aren't the correct ones it's waiting for
![[Obsidian-Attachments/Screenshot 2026-02-02 at 6.45.54 PM.png]]
If the instruction is a LOAD or STORE into a FP register file, the instruction will goto the address generation unit, which is just an integer operation.
- Instruction enter either the Load Buffer (LB) or Store Buffer (SB) before going to memory
- LB only provides the data address
- SB provides both address and data to memory
- If Load, the value is broadcasted on the CDB (Common Data Bus) into the registers
	- Values get broadcast to SB as well, for instructions that need to write back to memory
	- ^**These are done in order, modern processors simplify this**
![[Obsidian-Attachments/Screenshot 2026-02-02 at 6.48.53 PM.png]]
- Issue: The part where instructions are sent to the address gen unit or Reservation Station
- Dispatch: When an instruction is sent to execution from RS
- Write Result/Broadcast: When a instruction is ready to broadcast it's result. At this point, instruction is considered completed

## Tomasulo: Issue
![[Obsidian-Attachments/Screenshot 2026-02-02 at 6.52.40 PM.png]]
- take next inst from IQ (in program order)
- determine where inputs come from, and if it needs to wait for results (Register Alias Table (RAT))
- Get free RS slot for the correct executor
	- If all slots are busy, then we don't issue an instruction this cycle
- Put instruction into RS
- Tag destination register so we know where the result goes, and so other instructions know where to look for this value
![[Obsidian-Attachments/Screenshot 2026-02-02 at 6.56.26 PM.png]]
- RAT contains which inst produces that register
	- If nothing, then it points to register file (find value in actual register file)
	- Insts after 1 that require F2 will now wait for RS1 
![[Obsidian-Attachments/Screenshot 2026-02-02 at 6.58.33 PM.png]]
- Take inst2 from IQ, put in RS for MUL, and populate RAT so F1 is now linked to RS4
![[Obsidian-Attachments/Screenshot 2026-02-02 at 7.02.52 PM.png]]
- Inst4 is issued, pulling values for F2 from RS1 and F3 from the reg file
	- It now replaces RS4 to be the reference for F1
- In a real processor, an instruction would be issued every cycle, and some would have completed before they're all issued 

### Quiz
![[Obsidian-Attachments/Screenshot 2026-02-02 at 8.04.10 PM.png]]
- Issue F4=F1/F2
	- MUL RS: DIV, RS4, RS1
	- RAT: F4 -> RS5
- Cannot issue F4, only two slots in MUL RS and both are full
![[Obsidian-Attachments/Screenshot 2026-02-02 at 8.06.19 PM.png]]

## Dispatch
![[Obsidian-Attachments/Screenshot 2026-02-02 at 8.07.39 PM.png]]
- Latching operation results and deciding which instructions are ready to execute
- When broadcasting result:
	- Decide which RS is producing the result (RS1), and it's value
	- Free the RS that produced the result (RS1), now it's ready to recieve a new instruction
![[Obsidian-Attachments/Screenshot 2026-02-02 at 8.08.35 PM.png]]
- Match with all references to RS1 in existing RS slots
![[Obsidian-Attachments/Screenshot 2026-02-02 at 8.09.26 PM.png]]
- Figure out which instruction have all it's values and ready to execute
	- Assume each execution station can issue one instruction per cycle each, so both RS3 and RS4 can be issued
![[Obsidian-Attachments/Screenshot 2026-02-02 at 8.14.18 PM.png]]
- after this finishes, RS3 and RS4 will be broadcast and the cycle repeats

### More than 1 instruction is ready per RS
![[Obsidian-Attachments/Screenshot 2026-02-02 at 8.15.39 PM.png]]
- Ideally dispatch the instruction that allows the most future instructions
	- Requires knowledge of the future, which hardware cannot do
![[Obsidian-Attachments/Screenshot 2026-02-02 at 8.18.29 PM.png]]
- Use hueristics:
	1. Oldest instruction first (likely that lots of instructions depend on it because its been waiting for a while), usually do this one because its easy and works well
	2. Most dependencies first (check the number of instructions that reference it, but requires searching)
	3. Random (works reasonably well)

### Quiz
![[Obsidian-Attachments/Screenshot 2026-02-02 at 8.20.10 PM.png]]
- if this is the beginning of a cycle, why hasn't RS3 executed?
	- 1 is incorrect, being issued from IQ to RS last cycle doesn't stop it from being executed
	- 2 is plausible, if the executor is already processing something this cycle
	- 3 is plausible, only if we're using the Oldest first hueristic to pick instruction to execute

1. Possibly correct, if it was inserted very late in the last cycle, it could not have had enough time to be considered for execution (arrived after selection)
2. Yup
3. INCORRECT, becuase tomasulo's algo is Out of Order Execution, we don't need to wait for older instructions, especially if the operands are ready
![[Obsidian-Attachments/Screenshot 2026-02-02 at 8.26.26 PM.png]]

## Write Result (Broadcast)

- Put tag and resut on bus to broadcast
- Write to register file, know which value to overwrite, linked from RAT
![[Obsidian-Attachments/Screenshot 2026-02-02 at 8.28.09 PM.png]]
- Update RAT so it points to the Reg File
- Free RS which matches this instruction (in hardware, there is a bit that indicates it's free)
![[Obsidian-Attachments/Screenshot 2026-02-02 at 8.28.51 PM.png]]

### Broadcast more than 1 value
![[Obsidian-Attachments/Screenshot 2026-02-02 at 8.32.09 PM.png]]
- two instructions finish executing in the same cycle, what goes first in the broadcast bus?
	- could have separate broadcast bus for each executor, but that means twice the comparisons in each RS slot for each tag
	- usually make one unit/executor the higher priority unit, doesn't matter which honestly
	- Common hueristic: if one unit is known to be slower than the other, (e.g. MUL is slower than ADD), then give priority to slower unit
		- Theory is because it's slower, it's older, and has more instructions waiting on it

### Broadcast stale result
![[Obsidian-Attachments/Screenshot 2026-02-02 at 8.36.35 PM.png]]
- if a broadcasted result is stale, that is the RAT has already been replaced with a newer instruction
	- we still broadcast it to all RS and fill the value
	- no need to fill in the RAT, becuase all instructions looking for F4 will either look at F4 in the RAT or Reg File, and all newer instructions will find RS2 first, to wait for it
- DO NOT PUT IN RAT or Reg File!

## Tomasulo's algorithm review
![[Obsidian-Attachments/Screenshot 2026-02-02 at 8.39.36 PM.png]]
- Tomasulo's algorithm means that a CPU is trying to every step of this process at the same time for different instructions 

- Can we issue an instruction AND dispatch it in the same cycle? (Doesn't need to capture any results)
	- NO, when issuing we are putting stuff in the RS, and to dispatch we need to test those values. That is not possible, the RS is treated as empty and only in the next cycle will it be evaluated
	- Possible to design a processor that allows it
- Can we CAPTURE and DISPATCH in the same cycle?
	- NO, the RS updates its status from missing to available operands DURING the capture cycle
	- Possible, but harder to do 
- Can we update RAT for ISSUE and BROADCAST? Meaning an instruction being issued needs to update RAT with it's RS, while a finished instruction needs to update the RAT with the same RS and it's value
	- YES, only need to ensure the issuing instruction's RS persists in the RAT, bc instructions that will read the RAT will only depend on the most recent version of that register
![[Obsidian-Attachments/Screenshot 2026-02-02 at 8.46.18 PM.png]]

### One Cycle Quiz
![[Obsidian-Attachments/Screenshot 2026-02-02 at 8.47.22 PM.png]]
- What is in the RAT and Reg File?
	- Remove RS0 from RAT, update F1 from RS1 to RS2
	- Update Reg File with RS0
![[Obsidian-Attachments/Screenshot 2026-02-02 at 8.53.46 PM.png]]
- all correct!

### Quiz 2
![[Obsidian-Attachments/Screenshot 2026-02-02 at 8.55.25 PM.png]]
- What is in the RS?
	- Broadcast RS0 = 4.4
	- RS1 updated to SUB, 4.4, 1.2
	- Issue new instruction to RS2: ADD, 4.4, RS1
	- Clear RS0 in RS
![[Obsidian-Attachments/Screenshot 2026-02-02 at 8.57.58 PM.png]]
### Quiz 3
![[Obsidian-Attachments/Screenshot 2026-02-02 at 8.58.33 PM.png]]
- What will dispatch if anything?
	- RS1 can dispatch, it has all it's values
		- Dispatch RS1 to ALU for processing (Capture & Dispatch allowed same cycle)
	- RS2 could **not**, cannot issue & dispatch in the same cycle
![[Obsidian-Attachments/Screenshot 2026-02-02 at 9.00.39 PM.png]]

## Tomasulo's Algo Quiz
![[Obsidian-Attachments/Screenshot 2026-02-02 at 9.01.03 PM.png]]
- True, not checked
- False, checked
- False, checked
![[Obsidian-Attachments/Screenshot 2026-02-02 at 9.02.01 PM.png]]

## Load & Store Instructions
![[Obsidian-Attachments/Screenshot 2026-02-02 at 9.05.49 PM.png]]
- Can be dependencies through memory
	- RAW: Store to A, then load from A 
	- WAR: LW from A, then Store A (must do load first, or load will take what was just stored)
	- WAW: Store 1 to A, then Store 2 to A (need to store 2 last, or the value of A will be stale)
- To deal with this:
	1. Tomasulo's algo does loads and stores **in-order** (Don't do load if a previous store is pending)
	2. Identify dependencies between L & S, and reorder them like we do instructions
		- More complicated than register based dependencies

### Example of Tomasulo for multiple cycles
![[Obsidian-Attachments/Screenshot 2026-02-02 at 9.08.39 PM.png]]
- F4 in purple is actually R4
- Register Status is the RAT
-  Busy = If instruction is in RS
- Qj, Qk = what Vj, Vk are waiting for 
- Disp = where the instruction was dispatched

#### Cycle 1
![[Obsidian-Attachments/Screenshot 2026-02-02 at 9.10.45 PM.png]]
- Inst 1 is Load of R2 + 34 and store it in F6
#### Cycle 2
![[Obsidian-Attachments/Screenshot 2026-02-02 at 9.11.57 PM.png]]
- addition is done by addr unit, not add unit so it's done immediately
- LD1 is dispatched, which takes 2 cyles, and assuming the write happens after, the instruction completes in cycle 4
#### Cycle 3
![[Obsidian-Attachments/Screenshot 2026-02-02 at 9.14.19 PM.png]]
- cannot dispatch LD2 because the addr unit is busy with LD1 until cycle 4
- Issue Inst3 into ML1, depends on LD2

#### Cycle 4
![[Obsidian-Attachments/Screenshot 2026-02-02 at 9.18.22 PM.png]]
- Issue Inst4
- Dispatch LD2
- Write result from LD1, and broadcast to every RS that has LD1 (only AD1 right now)
- Put LD1 value into F6 (the register file)
- Erase valid bit from LD1, freeing the RS

#### Cycle 5
![[Obsidian-Attachments/Screenshot 2026-02-02 at 9.19.45 PM.png]]
- Issue Inst5 into ML2, read F6 and wait for ML1
- Don't dispatch anything as nothing is ready, LD2 has already been dispatched in cycle 4

#### Cycle 6
![[Obsidian-Attachments/Screenshot 2026-02-02 at 9.23.01 PM.png]]
- Issue Inst6 into AD2, with AD1, LD2
	- Populate RAT of F6 with AD2
- LD2 writes/broadcasts result
	- Will populate F2, and all RS that are waiting for LD2
	- Instructions referencing LD2 are now ready to go, but it's the end of the cycle and cannot be dispatched
		- Considering we cannot broadcast + dispatch, we try dispatch THEN broadcast
- Change RAT to Reg File
#### Cycle 7
![[Obsidian-Attachments/Screenshot 2026-02-02 at 9.24.39 PM.png]]
- AD1 and ML1 can both be dispatched, because they goto diff units
	- AD1 takes 2 cycles, will be done in cycle 9
	- ML1 takes 10 cycles, will be done in cycle 17
- Need to wait for these two value to broadcast, everything else depends on them

#### Cycle 9
![[Obsidian-Attachments/Screenshot 2026-02-02 at 9.25.53 PM.png]]
- Can broadcast AD1, write value -9.6 to F8
- Erase F8 in RAT
- Replace AD1 references in RS with value
- Free AD1
#### Cycle 10
![[Obsidian-Attachments/Screenshot 2026-02-02 at 9.26.51 PM.png]]
- Dispatch AD2, finishing in cycle 12
#### Cycle 12
![[Obsidian-Attachments/Screenshot 2026-02-02 at 9.28.16 PM.png]]
- Broadcast AD2 result, remove RAT entry
- Free AD2 RS
#### Cycle 17
![[Obsidian-Attachments/Screenshot 2026-02-02 at 9.28.50 PM.png]]
- Broadcast ML1 result, full in references in the RS
- Free ML1
#### Cycle 18
![[Obsidian-Attachments/Screenshot 2026-02-02 at 9.29.37 PM.png]]
- Dispatch ML2, need to wait to cycle 58 for result
![[Obsidian-Attachments/Screenshot 2026-02-02 at 9.29.52 PM.png]]

### Timing Example
![[Obsidian-Attachments/Screenshot 2026-02-02 at 9.33.24 PM.png]]
- on exams, we only care what cycle something finishes, how many cycles, etc
- need to check after filling out table that **no** instructions are WRITING IN THE SAME CYCLE

### Quiz
![[Obsidian-Attachments/Screenshot 2026-02-02 at 9.34.45 PM.png]]
- Figure out values for first 4 instructions

- I 1, D 2, Wr 3 (Load takes 1 cycle, no dependencies)
- I 2, D 3, Wr 8 (Does not depend on F6, can dispatch immediately)
- I 3, D 9, Wr 10 (Depends on F6 writing in 3 and F2 writing in 8, cannot capture and dispatch in same cycle)
- I 4, D 11, Wr 12 (2 Add units, cannot do this in same cycle as I3, as I3 produces F6 again. Cannot broadcast at the same time)
![[Obsidian-Attachments/Screenshot 2026-02-02 at 9.39.46 PM.png]]
### Quiz 2
- I 11, D 12, Wr 13 (In Cycle 10, both adds are still populated. Only able to write to ADD RS after I3 has been removed in C11)
- I 13, D 14, Wr 15 (Needs to wait for I4 to exit ADD RS, and need to wait for I 11 to write F1 in C13)
![[Obsidian-Attachments/Screenshot 2026-02-02 at 9.43.39 PM.png]]
