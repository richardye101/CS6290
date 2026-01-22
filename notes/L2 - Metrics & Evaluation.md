
# Performance 

Latency: Time from start to finish
Throughput: # of completed tasks/second

![[Obsidian-Attachments/Screenshot 2026-01-16 at 10.26.37 PM.png]]

###  Performance quiz
![[Obsidian-Attachments/Screenshot 2026-01-16 at 10.28.57 PM.png]]
- throughput: 2000 orders/second
- latency: ~~0.5~~  1 milliseconds (time to complte a single order)
![[Obsidian-Attachments/Screenshot 2026-01-16 at 10.34.16 PM.png]]

## Comparing Performance
![[Obsidian-Attachments/Screenshot 2026-01-16 at 10.43.00 PM.png]]

Comparing latency, its
$$
N = \frac{LATENCY(OLD/SLOWER)}{LATENCY(NEW/FASTER)}\\
$$
because old is "N" times slower than the new

Comparing throughput, its
$$
N = \frac{THROUGHPUT(NEW/FASTER)}{THROUGPUT(OLD/SLOWER)}\\
$$
because new is "N" times faster than the old

### Quiz
![[Obsidian-Attachments/Screenshot 2026-01-16 at 10.46.18 PM.png]]

Latency = old/new = 4\*6 / 1 = 24x
Throughput = new/old = 1/24 

![[Obsidian-Attachments/Screenshot 2026-01-16 at 10.54.10 PM.png]]
### Quiz 2
![[Obsidian-Attachments/Screenshot 2026-01-16 at 10.50.40 PM.png]]
the old laptop is now the "new" laptop

Speedup = Old/New = 1/24 = 0.04
![[Obsidian-Attachments/Screenshot 2026-01-16 at 10.54.03 PM.png]]

## Speedup
![[Obsidian-Attachments/Screenshot 2026-01-16 at 10.56.15 PM.png]]

- Performance is proportional to throughput
- Performance is proportional to 1/latency

## Measuring Performance
![[Obsidian-Attachments/Screenshot 2026-01-18 at 9.47.56 AM.png]]
- can't do ana ctive user workload for a few reasons, therefore we use benchmarks

## Benchmarks
![[Obsidian-Attachments/Screenshot 2026-01-18 at 9.49.13 AM.png]]

![[Obsidian-Attachments/Screenshot 2026-01-18 at 10.04.43 AM.png]]

- Peak performance isnt useful except for marketing
- Synthetic benchmarks (of an abtraction of a kernel) can be used in the design phase of a system to choose between multiple possible designs
- Actual kernels are used on that system to measure prototype performance
- Real applications are last, and are used to measure actual performance

### Quiz
![[Obsidian-Attachments/Screenshot 2026-01-18 at 10.06.43 AM.png]]
- ~~Synthetic benchmarks? But thats for kernels~~
- ~~Actual workload mix? Mix of apps but not all~~
- ~~App suite? Like above~~
- [ ] Application kernel: Uses real app code but that code has been reduced
![[Obsidian-Attachments/Screenshot 2026-01-18 at 10.08.40 AM.png]]

### Benchmark standards
![[Obsidian-Attachments/Screenshot 2026-01-18 at 10.12.02 AM.png]]
- TPC Benchmarks: for databases, web servers, data mining, transactional processses
- EEMBC: Embedded processing, cars, video players, etc
- SPEC: Engineering workstations, raw processors (not I/O intensive)
	- includes apps:
		- Gcc: software dev, compiler
		- bwaves, lbm: fully dynamic workloads
		- perl: stream processing applications
		- cactus adm: physics sim for relativity
		- xalanc BMK: XML parser
		- Calculix, deall: solvign diff eqs
		- bzip: compression algo

## Summarizing Performance
![[Obsidian-Attachments/Screenshot 2026-01-18 at 10.17.16 AM.png]]
- speed ups are a ratioe of compx/compy
- use average execution time (arithmetic mean) to compute averages of each compx/y, **not on the calculated speed ups/ratios of times**
- shoudldcompute avg exec times, then taking the difference as the speed up
- can use geometric mean on either speed ups or the actual exec times

## Iron law of performance
- in this class, will be mainly focusing on CPU performance
![[Obsidian-Attachments/Screenshot 2026-01-18 at 10.24.42 AM.png]]
- using these three components, we can think about different aspects of performance
![[Obsidian-Attachments/Screenshot 2026-01-18 at 10.29.13 AM.png]]
- computer architecture will affect the instruction set
- instruction set:
	- complex instructions: reduce # instructions, but more cycles per instruction
	- simple instructions: increase # instructions, but less cycles per instruction
- processor design:
	- short clock cycle & more cycles per instruction
	- long clock cycle & less cycles per instruction
### Iron Law Quiz
![[Obsidian-Attachments/Screenshot 2026-01-18 at 11.30.34 AM.png]]
- Exec time = 
	- 3B instructions x 
	- 2 cycles per instruction / 
	- 3B cycles per second =
	- 2 seconds
![[Obsidian-Attachments/Screenshot 2026-01-18 at 11.33.42 AM.png]]

## Iron law for unequal instruction times
![[Obsidian-Attachments/Screenshot 2026-01-18 at 11.34.41 AM.png]]
### Quiz
![[Obsidian-Attachments/Screenshot 2026-01-18 at 12.27.59 PM.png]]
(10 x 10^9 x 4 + 15 B x 2 + 5B x 3 + 20B x 1)/4B = 
$$
\begin{aligned}
\text{Execution time} &= \frac{10 \cdot 10^9 \cdot 4 + 15 B \cdot 2 + 5B \cdot 3 + 20B \cdot 1}{4B}\\ & = 
\frac{40 + 30 + 15 + 20}{4}\\ 
& = \frac{105}{4}\\
& = 26.25s\\
\end{aligned}
$$
![[Obsidian-Attachments/Screenshot 2026-01-18 at 12.52.06 PM.png]]
## Amdahls Law
![[Obsidian-Attachments/Screenshot 2026-01-18 at 12.53.13 PM.png]]
- Frac Enh is calculated as a % on the actual execution TIME, not # instructions or anything else

### Quiz
![[Obsidian-Attachments/Screenshot 2026-01-18 at 1.02.49 PM.png]]
$$
\begin{aligned}
\text{original total execution time} & = \frac{20B + 10B \cdot 4 + 15B \cdot 2 + 5B \cdot 3}{2B}\\
&= \frac{20 + 40 + 30 + 15}{2}\\
&= \frac{105}{2}\\
&= 52.5\\
\text{original exec time of branch} & = \frac{10B \cdot 4}{2B} = 20s\\
\text{new exec time of branch} & = \frac{10B \cdot 4}{4B} = 10s\\
\text{frac of orig time} &= \frac{20s}{52.5s}\\
&= 38.10\%\\
\text{Speedup}_{enh} &= \frac{20}{10} = 2\\ 
\text{Speed up} &= \frac{1}{\frac{32.5}{52.5} \cdot \frac{20}{52.5} \cdot \frac{1}{2}} \\
&= \frac{52.5^{2}\cdot 2}{32.5 \cdot 20}\\
&= 
\end{aligned}
$$
![[Obsidian-Attachments/Screenshot 2026-01-18 at 1.18.38 PM.png]]
$$
\begin{aligned}
\text{Iron Law}&\\
\text{Old Total Exec time} & = (.4 \cdot 1 + .2 \cdot \mathbf{4} + .3 \cdot 2 + .1 \cdot 3) \cdot \frac{50}{2} B = 2.1 \cdot 25 = 52.5\\
\text{New Total Exec time} & = (.4 \cdot 1 + .2 \cdot \mathbf{2} + .3 \cdot 2 + .1 \cdot 3) \cdot \frac{50}{2} B = 1.7 \cdot 25 = 42.5\\
\text{Speed Up} &= \frac{52.5}{42.5} = 1.2352 = 1.24 
\end{aligned}
$$

## Amhadls Law Implications
![[Obsidian-Attachments/Screenshot 2026-01-18 at 1.26.25 PM.png]]
- don't spend too much time optimizing a small part of the entire process, optimize for the common case

### Quiz
![[Obsidian-Attachments/Screenshot 2026-01-18 at 1.27.24 PM.png]]
$$
\begin{aligned}
\text{Old Total Exec time} & = (.4 \cdot 1 + .2 \cdot \mathbf{4} + .3 \cdot 2 + .1 \cdot 3) \cdot \frac{50}{2} B = 2.1 \cdot 25 = 52.5\\
\text{New Total Exec time} & = (.4 \cdot 1 + .2 \cdot \mathbf{3} + .3 \cdot 2 + .1 \cdot 3) \cdot \frac{50}{2} B = 1.9 \cdot 25 = 47.5\\
\text{Speed Up} &= \frac{52.5}{47.5} = 1.11\\ \\

\text{Old Total Exec time} & = (.4 + .2 \cdot 4 + .3 \cdot 2 + .1 \cdot 3) \cdot \frac{50}{\mathbf{2}} B = 2.1 \cdot 25 = 52.5\\
\text{New Total Exec time} & = (.4 + .2 \cdot 4 + .3 \cdot 2 + .1 \cdot 3) \cdot \frac{50}{\mathbf{2.3}} B = 2.1 \cdot 21.74 = 45.65\\
\text{Speed Up} &= \frac{52.5}{45.65} = 1.15\\ \\

\text{Old Total Exec time} & = (.4 + .2 \cdot 4 + .3 \cdot 2 + .1 \cdot \mathbf{3}) \cdot \frac{50}{2} B = 2.1 \cdot 25 = 52.5\\
\text{New Total Exec time} & = (.4 + .2 \cdot 4 + .3 \cdot 2 + .1 \cdot \mathbf{2}) \cdot \frac{50}{2} B = 2 \cdot 25 = 50\\
\text{Speed Up} &= \frac{52.5}{50} = 1.05\\ \\
\end{aligned}
$$
Option 2 is the best
![[Obsidian-Attachments/Screenshot 2026-01-18 at 1.43.01 PM.png]]
**He gave me the % time, so this could've been done much more easily**

## Lhadma's law
- do not make the uncommon case too bad
![[Obsidian-Attachments/Screenshot 2026-01-18 at 1.50.06 PM.png]]
$$
\text{Speed up} = \frac{1}{\frac{\text{Affected \%}}{\text{Slow Down} } + \frac{\text{Affected}}{\text{Speed Up}} } 
$$

## Diminishing Returns
![[Obsidian-Attachments/Screenshot 2026-01-18 at 1.57.00 PM.png]]
