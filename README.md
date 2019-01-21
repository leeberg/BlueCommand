BlueStrike
==================
![](./img/bluestrike.png) 

**BlueStrike** is Threat Tooling and Simulation platform built with the [PowerShell Universal Dashboard](https://universaldashboard.io/) from [Adam Driscoll](https://github.com/adamdriscoll) and [PowerShell Empire](https://github.com/EmpireProject/Empire)to provide a lightweight web UI for execution of attack simulations and providing an integration front end for PowerShell Empire.

**Brought to you by**  
[Lee Berg](https://leealanberg.com)

## Features
* Built on [Universal Dashboard](https://universaldashboard.io/) for modern web based UI
* PowerShell based network scanning/discovery
* PowerShell Network Operations
* [PowerShell Empire](https://www.powershellempire.com/) Integration
    * Rest Integration to retrive Agents, Configs, Modules, Etc.
    * Search and Execute Modules on the fly!
    * Export Action Results / Reports from Empire

## Getting Started
1. Install Universal Dashboard - Install-Module UniversalDashboard -AccecptLicense
2. Install PoshSSH.
    + PoshSSH is used to run SCP commands to extract agent artifacts.
3. Setup Empire
    + Run Empire with --rest command, feed the token to BlueStrike on the empire config page
4. Start ./StartBlueStrike.ps1
5. Follow the Steps on the Empire Configuration Page
6. 
     ![](https://media.giphy.com/media/MGaacoiAlAti0/giphy.gif)


