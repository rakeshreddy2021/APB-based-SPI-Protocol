# APB-based-SPI-Protocol
This project implements an APB-based SPI protocol, where the APB interface configures and controls the SPI core. The CPU programs registers to initiate data transfer, and the SPI master communicates with peripherals via MOSI, MISO, SCLK, and SS. Status and interrupt signals ensure reliable and efficient data exchange.

---

## APB (Advanced Peripheral Bus)

* A part of ARM’s AMBA family.
* Designed for low-power, low-cost peripheral access.
* Used mainly for reading and writing registers of peripherals.
* Works in two phases: **Setup** (address and control signals set) and **Access** (data transfer).
* Commonly used to connect CPU to simple peripherals.

---

## SPI (Serial Peripheral Interface)

* A synchronous serial communication protocol.
* Involves a master (controller) and one or more slaves (devices).
* Main signals:

  * **MOSI**: Master Out, Slave In (data from master).
  * **MISO**: Master In, Slave Out (data from slave).
  * **SCLK**: Serial clock from master.
  * **SS/CS**: Slave Select, active low.

---
## How Connections Work in the Project

### Control path (APB side)

* The **CPU communicates with SPI through APB registers**.
* Control and configuration values (clock mode, baud rate, enable, slave select) are written into SPI registers via APB.
* Data to be transmitted is written into the **SPI transmit register** using **PWDATA**.
* Received data is stored in the **SPI receive register** and read back using **PRDATA**.
* Status signals (busy, done, error) are reported back through APB registers.
* **PREADY** indicates transfer completion, while **PSLVERR** signals errors.

### Data path (SPI side)

* Once configured, the SPI core drives the **external SPI bus**.
* Data written through APB is shifted out on **MOSI**, bit by bit, on each clock edge of **SCLK**.
* The slave simultaneously shifts data back on **MISO**, which is captured by the SPI core and stored for the CPU.
* **SS** ensures only the targeted slave device responds.

---

## System-Level View

1. The CPU acts as the **controller**.
2. The APB interface is used only for **register access and control**.
3. The SPI core converts those register values into **serial transactions** on MOSI/MISO/SCLK/SS.
4. An **interrupt line** from SPI to CPU signals when data transfer is complete, or when errors occur.
5. This design separates **control plane (APB)** from the **data plane (SPI signals)**, ensuring clarity and modularity.

---

## Introduction

This project implements an **APB-based Serial Peripheral Interface (SPI) Core**, designed to provide efficient and reliable communication between a master device (such as a CPU) and various peripherals. The SPI protocol is widely used because of its **simplicity, high-speed data transfer, and flexibility**, making it suitable for applications like embedded systems, sensor interfacing, and communication modules.

The SPI Core integrates with the **AMBA APB3 bus**, allowing easy register-level configuration and control. It includes:

* **Control & Status Registers** – to configure operation modes and monitor communication.
* **Data Registers** – for temporary storage of transmitted and received data.
* **Shifter Logic** – handles serial-to-parallel and parallel-to-serial conversion.
* **Baud Rate Generator** – controls clock frequency for SPI transactions.
* **Slave Select Generator** – manages selection of slave devices.
* **Interrupt Support** – enables efficient event-driven data transfer.

The design supports **full-duplex communication** with synchronous data transfer aligned to the SPI clock. It can operate in multiple SPI modes (Mode 0–3), ensuring compatibility with different peripheral devices. The architecture is optimized for **low power consumption**, making it suitable for both high-performance and battery-powered systems.

---

## Register Description

The SPI Core is controlled and monitored through **five memory-mapped registers**:

| Address | Register               | Access | Purpose                                                                                  |
| ------- | ---------------------- | ------ | ---------------------------------------------------------------------------------------- |
| 0       | SPI Control Register 1 | R/W    | Configures core operation (enable, master/slave, clock polarity/phase, interrupts, etc.) |
| 1       | SPI Control Register 2 | R/W    | Advanced settings (mode fault detection, bidirectional mode, low-power modes, etc.)      |
| 2       | SPI Baud Rate Register | R/W    | Defines the SPI clock frequency using prescaler and divisor values                       |
| 3       | SPI Status Register    | R      | Indicates flags like transfer complete, buffer empty, or mode fault                      |
| 5       | SPI Data Register      | R/W    | Holds transmit data (MOSI) or receive data (MISO)                                        |

---

### 1. SPI Control Register 1 (SPICR1) — **\[7:0]**

* **\[7] SPIE** – Enable SPI interrupts
* **\[6] SPE** – Enables the SPI system and activates pins
* **\[5] SPTIE** – Enables interrupt when transmit buffer is empty
* **\[4] MSTR** – Selects master mode
* **\[3] CPOL** – Clock polarity (idle high or low)
* **\[2] CPHA** – Clock phase (sample on leading/trailing edge)
* **\[1] SSOE** – Enables slave-select output in master mode
* **\[0] LSBFE** – Transfers data LSB-first if set

---

### 2. SPI Control Register 2 (SPICR2) — **\[7:0]**

* **\[4] MODFEN** – Enables detection of mode fault
* **\[3] BIDIROE** – Enables output in bidirectional mode
* **\[2] SPISWAI** – Conserves power in wait mode
* **\[0] SPC0** – Serial pin control bit

---

### 3. SPI Baud Rate Register (SPIBR) — **\[7:0]**

* **\[6:4] SPPR\[2:0]** – Prescaler bits
* **\[2:0] SPR\[2:0]** – Divider bits

Formula:

```
Baud Rate = PCLK / ((SPPR+1) × 2^(SPR+1))
```

---

### 4. SPI Status Register (SPISR) — **\[7:0]**

* **\[7] SPIF** – Transfer complete flag
* **\[5] SPTEF** – Transmit buffer empty
* **\[4] MODF** – Mode fault flag

---

### 5. SPI Data Register (SPIDR) — **\[7:0]**

* **\[7:0] Data** –

  * Write: Data to be transmitted via MOSI
  * Read: Data received via MISO

Perfect 👍 You don’t want just a README draft — you want a **clear explanation of the SPI Core itself** so you can really understand it (and maybe later summarize it in your GitHub).

Based on your uploaded doc, here’s a breakdown:

---

# 🔎 Explanation of SPI Core

## 1. **What is SPI Core?**

The **SPI (Serial Peripheral Interface) Core** is a hardware module that connects a microcontroller (master) with one or more external devices (slaves).
It follows the **APB (Advanced Peripheral Bus)** protocol on one side and **SPI protocol** on the other.

* **APB Side** → Communicates with CPU (reads/writes registers).
* **SPI Side** → Communicates serially with external peripherals.

---

## 2. **Main Components**

The SPI Core is divided into **four functional blocks**:

1. **APB Slave Interface**

   * Connects SPI to APB bus (CPU side).
   * Handles register read/write.
   * Provides control signals (like enable, mode select, interrupts).

2. **Baud Rate Generator**

   * Generates the **SPI clock (SCLK)** from APB clock (PCLK).
   * Allows programmable speed using prescalers (SPPR, SPR).
   * Supports different **CPOL (polarity)** and **CPHA (phase)** for SPI modes.

3. **Slave Select Generator**

   * Controls the **SS (Slave Select)** signal.
   * Pulls SS low when a transfer starts, and back high when done.
   * Ensures proper timing for slave communication.

4. **Shifter**

   * Converts **parallel data ↔ serial data**.
   * Handles **MOSI** (Master Out Slave In) and **MISO** (Master In Slave Out).
   * Supports **MSB-first or LSB-first transmission**.
   * Synchronizes with clock edges (depends on CPOL/CPHA).

---

## 3. **Registers in SPI Core**

The SPI Core uses control/status/data registers accessible via APB:

| Register               | Function                                                |
| ---------------------- | ------------------------------------------------------- |
| **Control Register 1** | Enables SPI, master/slave mode, CPOL, CPHA, interrupts. |
| **Control Register 2** | Fault detection, bidirectional mode, low-power options. |
| **Baud Rate Register** | Sets clock prescaler/divisor for SCLK.                  |
| **Status Register**    | Flags (Transfer complete, Buffer empty, Mode fault).    |
| **Data Register**      | Holds transmit (TX) and receive (RX) data.              |

---

## 4. **How Data Transfer Works**

Here’s the **sequence of events** in SPI communication:

1. **CPU writes data** into **SPI Data Register** via APB.
2. **SS (Slave Select)** is driven low → selects the SPI slave.
3. **Baud Rate Generator** starts producing the SCLK signal.
4. **Shifter** sends data bit-by-bit on MOSI, while simultaneously reading from MISO.
5. Once all bits are shifted:

   * Data is stored back into **Data Register** for CPU to read.
   * **SS goes high** → end of transfer.
   * **Status flags (SPIF, SPTEF, etc.)** are updated.
   * **Interrupt** may be triggered (if enabled).

This ensures **full-duplex, synchronous data transfer**.

---

## 5. **SPI Modes**

Controlled by **CPOL (Clock Polarity)** and **CPHA (Clock Phase):**

| Mode  | CPOL | CPHA | Sampling Edge | Idle Clock |
| ----- | ---- | ---- | ------------- | ---------- |
| **0** | 0    | 0    | Rising edge   | Low        |
| **1** | 0    | 1    | Falling edge  | Low        |
| **2** | 1    | 0    | Falling edge  | High       |
| **3** | 1    | 1    | Rising edge   | High       |

This makes it compatible with a wide range of slave devices.

---

## 6. **Why is it Useful?**

* **High speed** compared to I²C or UART.
* **Full-duplex** (send and receive at the same time).
* **Simple hardware wiring** (only 4 signals: MOSI, MISO, SCLK, SS).
* **Flexible** → Multiple devices can be connected using multiple SS lines.

---

--> So in short:
The **SPI Core** is like a “bridge” — on one side it talks to the CPU using **APB registers**, and on the other side it talks to external devices using **SPI signals**. It automatically handles clock generation, chip select, shifting of data, and status reporting.

---

# Detailed Working of SPI Core Blocks

## 1. **APB Slave Interface**

* **Role:** Bridge between CPU (APB bus) and SPI core.
* **Working:**

  * CPU reads/writes data through **APB registers** (Control, Status, Baud, Data).
  * Implements a **3-state APB FSM**:

    * **IDLE** → Waits for transaction.
    * **SETUP** → Captures address & control.
    * **ENABLE** → Executes read/write.
  * Generates **wr\_enb (write enable)** and **rd\_enb (read enable)** signals.
  * Updates SPI configuration (CPOL, CPHA, baud, enable bits).
  * Provides **interrupt signals** when flags (SPIF, SPTEF, MODF) are triggered.

--> Think of it as the “control room” where the CPU tells SPI what to do.

---

## 2. **Baud Rate Generator**

* **Role:** Generates **SCLK (SPI clock)** from system clock (PCLK).
* **Working:**

  * Takes **prescaler (SPPR)** and **divider (SPR)** values from Baud Rate Register.
  * Computes divisor:

    $$
    Divisor = (SPPR + 1) \times 2^{(SPR + 1)}
    $$
  * Produces SCLK = **PCLK / Divisor**.
  * Controls clock **polarity (CPOL)** and **phase (CPHA)**:

    * Decides whether data is sampled on rising or falling edge.
  * Provides **flags** for when MOSI/MISO should sample or shift data.

--> Acts like a **speed controller** ensuring the SPI clock matches the required baud rate.

---

## 3. **Slave Select Generator**

* **Role:** Controls **SS (Slave Select)** signal in master mode.
* **Working:**

  * When CPU writes new data → **send\_data signal goes high**.
  * **SS goes low** → selects the slave.
  * Keeps SS low for duration = `16 × BaudRateDivisor`.
  * During this time, data is shifted out/in.
  * Once done:

    * **SS goes high** (deselects slave).
    * **receive\_data flag** asserted (data ready in register).
    * **TIP (Transfer in Progress)** goes low → signals completion.

--> Like a **switch operator**: pulls the line low to talk to a device, then releases when finished.

---

## 4. **Shifter**

* **Role:** Handles **serial-to-parallel and parallel-to-serial conversion**.
* **Working:**

  * Data from CPU (via APB Data Register) is loaded into **shift register**.
  * On each **SCLK edge**:

    * One bit is shifted out on **MOSI**.
    * Simultaneously, one bit is read in from **MISO**.
  * Supports **MSB-first or LSB-first** (based on LSBFE bit).
  * At end of 8 bits:

    * Received data stored in **temp register** → then moved into **SPI Data Register**.
    * Transmitted data has already gone out on MOSI.
  * Works in sync with **CPOL/CPHA** to ensure correct timing.

--> Think of it as the **gearbox**: it shifts the data bits in/out in perfect sync with the clock.

---

--> In short:

* **APB Slave Interface** = Control & register handling.
* **Baud Rate Generator** = Creates SPI clock.
* **Slave Select Generator** = Manages slave enable line.
* **Shifter** = Actually moves data in/out bit by bit.

---
