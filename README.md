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

