# APB-based-SPI-Protocol
This project implements an APB-based SPI protocol, where the APB interface configures and controls the SPI core. The CPU programs registers to initiate data transfer, and the SPI master communicates with peripherals via MOSI, MISO, SCLK, and SS. Status and interrupt signals ensure reliable and efficient data exchange.
Understood. I’ll keep it simple and direct without using terms like “let’s,” “got it,” or “like this.”

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



