# Pulse optimization for multi-nuclear fingerprinting (2020) #

This code provides tools to find an optimal pulse train for sodium (23Na) fingerprinting and is extendable to other nuclei.

An optimal pulse train is found using computational optimization based on spin dynamics simulation of sodium nuclei. The goal is to minimize an objective function that takes as input two real number vectors corresponding to simulated signals of gray (GM) and white (WM) matter. The objective function estimates how close the signals are to each other. Thus, minimization of this function allows a better separation between GM and WM signals. Good signal separation enables correct matching to a fingerprinting dictionary and uncovering of corresponding properties (T1, T2, density, ...).

### How to run the code? ###

To run the code, first set all the parameters related to simulation and optimization in the *./settings/global_settings.m* file. Then, execute *Optimization.m* script that will run the optimization, and display its progress and final results.

*This code requires no prior installation, however, some MATLAB modules required for its execution can be missing. In this case, please follow MATLAB instructions.*

### Code structure ###

*Optimization.m* is the main script that runs the entire end-to-end optimization.

The code also includes the following  sub-directories:

*   **settings** - functions to set and update global parameters related to simulation and optimization,

*   **optimizers** - optimization algorithms that can be used to minimize a chosen objective function,

*   **objectives** - a selection of objective functions to minimize,

*   **pulses** - functions that define how a pulse train formed from a candidate solution provided by the optimizer, depending on the chosen type of pulse sequence,

*   **functions** - subroutines used during execution of the main *Optimization.m* script,

*   **penalties** - functions that penalize a candidate solution, if certain pulses of the solution do not respect the defined constraints. The penalty functionality was a part of a legacy code, is not used in the current code version, and kept here only for reference or possible future re-implementation.

*   **utils** - stand alone tools to process final optimization results that were saved at the end of the main script execution.

### Optimization ###

The present code contains 3 optimization algorithms: **Simulated Annealing** (single-objective optimization only), **Genetic Algorithm** (single- and multi-objective optimization), and **Pareto Search** (multi-objective optimization only).

The choice of algorithm and corresponding objective functions to minimize can be made in *./settings/global_settings.m* file. Settings related to each individual algorithm can be found and modified in its own file (see *./optimizers* sub-directory).

*Detailed information about the parameters and implementation can be found in MATLAB documentation.*

### Objective functions ###

The code proposes 3 different objective functions to minimize: **dot (dot product)**, **corr (Pearson correlation)**, **cond (condition number)**. The corresponding files (*gen_\*.m*) can be found in *./objectives*. This sub-directory also contains a *gen_multi.m* file that implements any combination of these three objectives, depending on user's choice. The choice can be made in *./settings/global_settings.m*. 

*Detailed information about objective function computation can also be found in MATLAB documentation.*

### Pulse train ###

Every pulse train contains a sequence of consecutive pulses, each having flip angle amplitude (alpha) and phase (phi).

There are 3 different implementations of pulse train: 1) **multi-shot**, 2) **one-shot interval**, and 3) **one-shot smooth**.

**Multi-shot** is a train where *n* pulses are repeated a certain number of times called shots (usually 2-3 times to get to a steady state). The signal is simulated as if a sequence actually contained *n* x shots pulses, but only the signal from the last shot is retained for computing objective function score. The number of shots can be set to 1 to simulate a normal one-shot train, where all the pulses have distinct values.

**One-shot interval** is a train, where instead of *n* pulses, only *m* points are optimized (*n* > *m*, and *n* mod *m* = 0). The value of *n* corresponds to *gs.pulse.nt* in *./settings/global_settings.m*, and *m* to *gs.pulse.nx* in *./settings/global_settings.m*. Thus, every point sets the same amplitude for *n*/*m* consecutive pulses called intervals. This makes the optimization problem simpler, as less points have to be optimized, but it also restricts the search field to only less flexible solutions. The one-shot interval configuration is transformed to a normal one-shot configuration, when *n* = *m*. For now, no multi-shot interval configuration has been implemented.

**One-shot smooth** is similar to the one-shot interval configuration, but instead of intervals, every point controls a part of a curve in the final pulse train. Thus, the transition between consecutive pulses controlled by the same point is smooth. No multi-shot smooth implementation exists.

The code is also contains functionality for multi-part pulse trains, where a train is divided into equal size blocks that are optimized in order. For every block, pulses in the past blocks are freezed and only the pulses in the current block are optimized. However, this functionality has only been properly tested in the legacy code.

### Authors ###

Optimization - Olga Dergachyova (olga.dergachyova@nyulangone.org).

Spin dynamics simulator - Guillaume Madelin (guillaume.madelin@nyulangone.org).

References: 1) Lee JS et al, J Chem Phys 131, 174501, 2009; 2) Madelin G et al, Prog NMR Spectr 79, 14-47, 2014.
