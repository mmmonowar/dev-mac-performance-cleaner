# Setup & Installation Guide
## 1: Save and Make Executable

+ Set file permissions via Terminal
+ Save the script contents into files named mac_diag.sh and mac_sweep.sh. Make them executable:

```Bash
chmod +x mac_diag.sh mac_sweep.sh
```

## 2: Run System Diagnosis

+ Inspect current state without changes
+ Execute the diagnostic script to get a real-time health readout:

```Bash
./mac_diag.sh
```

## 3: Test Maintenance Sweep

+ Perform a safe dry-run preview
+ Run a preview sweep to see how much space can be safely reclaimed:

```Bash
./mac_sweep.sh --dry-run
```

+ To execute the actual sweep:

```Bash
sudo ./mac_sweep.sh
```

## 4: Install Periodic Automation (Optional)

+ Configure weekly automatic cleanup via launchd
+ Move the sweep script to system binaries and activate the background daemon:

```Bash
sudo cp mac_sweep.sh /usr/local/bin/mac_sweep.sh
cp com.user.macsweep.plist ~/Library/LaunchAgents/
launchctl load ~/Library/LaunchAgents/com.user.macsweep.plist
```