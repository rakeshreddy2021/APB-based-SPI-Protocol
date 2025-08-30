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

## Connection in the Project

* **CPU → APB interface → SPI Core → External SPI Device**

### On the APB side

* CPU writes to SPI control and data registers using **PADDR, PWRITE, PWDATA, PSEL, PENABLE**.
* CPU reads back data or status using **PRDATA**.
* `PREADY` signals when a transfer is complete.
* `PSLVERR` signals an error if one occurs.

### On the SPI side

* **MOSI** sends data from master to slave.
* **MISO** receives data from slave to master.
* **SCLK** provides timing for bit transfers.
* **SS** activates the chosen slave device.

