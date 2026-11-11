# The Queue That Loses Patience

**An interactive queue simulation built with Godot 4.7.2**

What happens when people waiting in a queue can run out of patience?

*The Queue That Loses Patience* is an interactive systems experiment exploring how a single behavioral rule can change the dynamics of an entire queue.

Agents arrive, wait for service, and move through a first-in, first-out (FIFO) queue. When the patience mechanism is enabled, agents can abandon the queue after exceeding their individual waiting limits.

The project demonstrates how local decisions can produce visible changes in a larger system.

## ▶ Live Demo

**[Launch the Interactive Simulation](https://kawaii-neko07.github.io/the-queue-that-loses-patience/)**

The simulation runs directly in your browser using the original Godot Web export.

No installation is required.

## Project Overview

The simulation models a service environment with:

- Agents arriving at randomized intervals.
- A single service station.
- FIFO queue management.
- Individual waiting-time limits.
- Optional patience-based abandonment.
- Real-time visual feedback.
- Live statistics tracking system behavior.

The central experiment compares two operating conditions:

**Patience OFF**

Agents continue waiting until they are served. As new agents arrive, the queue can grow when the arrival rate exceeds the service capacity.

**Patience ON**

Agents may abandon the queue when their waiting limits are exceeded. This introduces an additional way for agents to leave the system, changing queue length, service outcomes, and abandonment statistics.

## Controls

| Control | Function |
|---|---|
| Patience ON/OFF | Enables or disables patience-based abandonment |
| Pause / Resume | Pauses or resumes the simulation |
| Restart | Restarts the simulation |

These controls allow users to observe the system under different conditions.

## Visual System

The interface presents agents as colored markers moving through a shared service environment.

The visualization includes:

- An entry point.
- A waiting area.
- A service station.
- Agent states.
- A real-time statistics panel.

Visual feedback makes changes in queue behavior observable without requiring users to inspect the underlying code.

## Live Statistics

The simulation tracks:

| Metric | Description |
|---|---|
| Served | Number of agents who completed service |
| Abandoned | Number of agents who left before receiving service |
| In Queue | Current number of waiting agents |
| Created | Total number of generated agents |
| Time | Elapsed simulation time |

Together, these metrics make it possible to compare system behavior with patience enabled and disabled.

## Experimental Observations

During development, the simulation was tested under different patience conditions.

### Test 1 — Patience Disabled

At approximately 96 seconds:

- Agents created: 96
- Agents served: 29
- Agents abandoned: 0
- Agents waiting: 66

**Observation:** The queue accumulated waiting agents without abandonment.

### Test 2 — Patience Enabled

At approximately 116 seconds:

- Agents created: 117
- Agents served: 36
- Agents abandoned: 56
- Agents waiting: 24

**Observation:** Enabling patience-based abandonment reduced the number of agents remaining in the queue, while increasing the number of agents leaving without service.

### Interpretation

The experiment illustrates a systems-level trade-off.

A shorter queue does not necessarily mean that the service system has become more efficient. It may instead indicate that more agents are leaving before receiving service.

The observed results also highlight the importance of distinguishing system throughput from queue length and abandonment.

**Methodological note:** These observations were recorded at different simulation times and are illustrative rather than a controlled statistical comparison. Randomized arrivals and individual waiting limits can affect the results. Repeated trials under comparable conditions would be needed to estimate the effects more reliably.

## Technology

- **Engine:** Godot 4.7.2
- **Programming language:** GDScript
- **Application type:** Interactive 2D simulation
- **Web deployment:** Godot HTML5/WebAssembly export
- **Version control:** Git
- **Hosting:** GitHub Pages

The browser version is exported from the original Godot project. It is not a separate JavaScript recreation of the simulation.

## Repository Structure

```text
the-queue-that-loses-patience/
├── docs/
│   ├── index.html
│   ├── QueueLab-Web.js
│   ├── QueueLab-Web.wasm
│   ├── QueueLab-Web.pck
│   └── ...additional export assets
├── godot-project/
│   ├── project.godot
│   ├── queue_lab.gd
│   ├── queue_lab.tscn
│   └── ...project configuration
├── README.md
├── LICENSE
└── .gitignore
```

The `docs/` directory contains the playable browser build.

The `godot-project/` directory contains the editable Godot source project.

## Running the Project Locally

### Browser Version

The exported application should be served through a local HTTP server rather than opened directly through the `file://` protocol.

From the `docs/` directory, run:

```bash
python -m http.server 8000
```

Then open:

```text
http://localhost:8000/
```

### Godot Source Project

1. Install a compatible version of Godot.
2. Open Godot Project Manager.
3. Import `godot-project/project.godot`.
4. Open the project.
5. Run the main scene.

## Design Approach

The project was developed as an experiment in interactive systems and emergent behavior.

Its design focuses on three questions:

1. How can individual agent rules influence collective system behavior?
2. How can a simulation communicate changing conditions through visual feedback?
3. How can interactive controls help users explore cause-and-effect relationships?

Rather than treating the queue as a purely decorative animation, the project uses agent states, service progression, and abandonment rules to create observable system behavior.

## Skills Practiced

This project provided practical experience in:

- Interactive simulation design.
- Agent-based behavioral logic.
- State management.
- Queue data structures and FIFO processing.
- Real-time visualization.
- User interaction design.
- Systems thinking.
- Experimental observation and interpretation.
- Godot development with GDScript.
- Web export and deployment.
- Git and GitHub repository management.

## Limitations and Future Development

The current version is a focused simulation prototype rather than a validated operational queueing model.

Potential extensions include:

- Adjustable arrival and service rates.
- Multiple service stations.
- Reproducible random seeds.
- Repeated simulation trials.
- Comparative statistics across experimental conditions.
- Data export for further analysis.
- Additional queue management strategies.

These are possible development directions, not features of the current implementation.

## Project Status

**Functional prototype — browser version available.**

The simulation has been tested locally and deployed through GitHub Pages.

## License

See the [LICENSE](LICENSE) file for the repository's licensing terms.

---

*An interactive experiment in how individual behavior changes collective systems.*

**Built with Godot 4.7.2.**
