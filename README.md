# dev-mac-performance-cleaner
**macOS Performance Cleaner & Diagnostic Suite**

Lightweight, zero-dependency Bash utilities designed to inspect system health, purge redundant system/app caches, optimize memory, and automate periodic maintenance on macOS.

## **Features**

* **`mac_diag.sh` (Health Inspector):** A read-only diagnostic tool that reports on thermal levels, RAM/swap pressure, top CPU/memory consumers, disk snapshots, and bloated container directories without making system changes.
* **`mac_sweep.sh` (Optimization Sweep):** A deep cleanup script that purges user/system caches, log files, Xcode derived data, package manager caches, flushes DNS, and purges inactive RAM. Includes a `--dry-run` safety flag.
* **`com.user.macsweep.plist` (Background Automation):** A native `launchd` configuration to run `mac_sweep.sh` automatically every Sunday at 3:00 AM.

## **Quick Installation (One-Liner)**

To install the scripts into `/usr/local/bin` and activate background automation in one step, run your Gist bootstrapper command in Terminal:

```bash
curl -fsSL https://gist.githubusercontent.com/mmmonowar/6c474f5144071d6aac2bc14dff21f10a/raw/3595cf8c330be63c22f796b2cc12b9d4c8598606/install.sh | bash

```

---

## **Manual Setup & Usage**

### **1. Make Scripts Executable**

Grant execution permissions to the scripts:

```bash
chmod +x mac_diag.sh mac_sweep.sh
```

### **2. Run System Diagnosis**
Inspect real-time system metrics, thermal status, memory consumers, and large Application Support folders:

```bash
./mac_diag.sh
```

### **3. Run Maintenance Sweep**
Preview items to be removed without deleting any files:

```bash
./mac_sweep.sh --dry-run
```

Execute a full system cleanup and RAM purge:
```bash
sudo ./mac_sweep.sh
```

### **4. Enable Weekly Automation**
Copy the sweep script to system binaries and activate the `launchd` daemon:

```bash
sudo cp mac_sweep.sh /usr/local/bin/mac_sweep.sh
cp com.user.macsweep.plist ~/Library/LaunchAgents/
launchctl load ~/Library/LaunchAgents/com.user.macsweep.plist
```

## **Script Details**

### **`mac_diag.sh` Readout Highlights**

* **System Metrics:** macOS version, uptime, architecture, and thermal throttling status.
* **Memory & Swap:** Active page sizes, free/speculative memory calculation, and swap usage.
* **Top Resource Consumers:** Top 5 processes sorted by CPU and RSS RAM usage.
* **Storage Analysis:** Main volume disk usage, active local Time Machine snapshots, and Application Support/Container directories over 300MB/1GB.

### **`mac_sweep.sh` Cleaning Targets**

* **Caches & Logs:** `~/Library/Caches`, `/Library/Caches`, App Sandboxed Container caches, system diagnostic reports, and user logs.
* **Software Updates:** Downloaded installer packages in `/Library/Updates` and staged update files in `/var/db/SoftwareUpdate`.
* **Developer Artifacts:** Xcode DerivedData, Xcode Archives, Homebrew cleanup, NPM cache, and PNPM store pruning.
* **System Operations:** Flushes DNS (`mDNSResponder`) and purges inactive system RAM via `purge`.

### **`com.user.macsweep.plist` Schedule**

* **Execution Interval:** Scheduled using `StartCalendarInterval` for every Sunday at 03:00 AM.
* **Log Outputs:** Logs output to `/tmp/mac_sweep.log` and errors to `/tmp/mac_sweep_err.log`.


## **License**

Distributed under the MIT License.

```
