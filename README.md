# 🛰️ Decentralized Multi-UAV System

A fully decentralized MATLAB-based simulation framework for autonomous coordination and area coverage by multiple UAVs. This system enables robust and scalable swarm-level decision-making without any centralized controller, using real-time peer-to-peer communication.

---

## 📖 Description

This project demonstrates a fault-tolerant and collision-free area coverage system using multiple UAVs (simulated in MATLAB). The key idea is to group UAVs into swarms where each member cooperatively plans and covers its assigned area.

Features include:
- 🚁 **Decentralized Control:** No single point of failure.
- 🔁 **Leader-based Task Assignment:** Leader UAV dynamically assigns subregions.
- 📡 **UDP Communication:** Real-time peer-to-peer messaging between UAVs.
- 🚦 **Failure Recovery:** Lost UAVs are detected and their regions reassigned.
- 🧭 **Snake-Pattern Movement:** Structured, efficient area coverage.
- 🛑 **Collision Avoidance:** Z-axis stratification ensures safe traversal.

---

## ✅ Prerequisites

- MATLAB R2020b or later
- Windows OS (for batch script compatibility)
- Open UDP ports: 6000 for server, 6001–6004 for UAVs (can be changed in server.m and client*.m)
- Working knowledge of MATLAB scripting

---

## ⚙️ Project Setup

1. **Clone the repository**
   ```bash
   git clone git@github.com:aman180601/Decentralized-Multi-UAV-System.git
   ```

2. **Open MATLAB**
   - Set the current folder to the cloned project directory.

3. **Check Configuration**
   - Make sure client*.m , server.m, and all utility scripts are present.

---

## 🚀 How to Run

### 🔸 Option 1: Manual launch (Recommended for debugging)

1. In MATLAB, run the server:
   ```matlab
   server
   ```

2. Open *4 separate MATLAB windows* and run one UAV client in each:
   ```matlab
   client1
   client2
   client3
   client4
   ```

    Each UAV will start, communicate with others, and begin covering its area.


### 🔸 Option 2: Use the Windows batch file

1. First, launch the server manually:
   ```matlab
   server
   ```

2. Then double-click or run from terminal:
   ```
   run_all.bat
   ```

    This will automatically open four MATLAB sessions running each UAV client.

---

## 🧪 Simulating UAV Failures

- To simulate a UAV failure:
  - *Close any client MATLAB window* (e.g., `client3`)
  - Remaining UAVs will detect its absence and *redistribute the remaining area*

- This dynamic reassignment ensures 100% coverage even with mid-mission failures.
